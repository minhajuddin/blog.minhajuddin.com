title: How to control enqueuing speed of Sidekiq jobs and their concurrency
date: 2020-07-13 18:55:04
tags:
- Sidekiq
- Redis
- Concurrency
- Ruby
- Enqueue
- Backpressure
---

At my work, we use ruby heavily and sidekiq is an essential part of our stack.
Sometimes, I long for the concurrency primitives from Elixir, but that's not
what today's post is about.

A few days ago, I caused a minor incident by overloading our databases. Having
been away from ruby for a bit, I had forgotten that sidekiq runs multiple
threads per each worker instance. So, I ended up enqueuing about 10K jobs on
Sidekiq, and Sidekiq started executing them immediately. We have 50 worker
instances and run Sidekiq with a concurrency of 20. So, essentially we had 400
worker threads ready to start crunching these jobs. Coincidentally we have 400
database connections available and my batch background job ended up consuming
all the connections for a period of 5 minutes during which the other parts of
the application were connection starved and started throwing errors 😬.

That was a dumb mistake. Whenever you find yourself making a dumb mistake,
make sure that no one else can repeat that mistake. To fix that, we could set up
our database with multiple users in such a way that the web app would connect
with a user which could only open a maximum of 100 connections, the background
worker with a user with its own limits and so on. This would stop these kind of
problems from happening again. However, we'll get there when we get there, as
this would require infrastructure changes.

I had another batch job lined up which had to process millions of rows in a
similar fashion. And, I started looking for solutions. A few solutions that were
suggested were to run these jobs on a single worker or a small set of workers,
you can do this by having a custom queue for this job and executing a separate
sidekiq instance just for this one queue. However, that would require some
infrastructure work. So, I started looking at other options.


I thought that redis might have something to help us here, and it did! So, redis
allows you to make blocking pops from a list using the `BLPOP` function. So, if
you run `BLPOP myjob 10`, it will pop the first available element in the list,
However, if the list is empty, it will block for 10 seconds during which if an
element is inserted, it will pop it and return its value. Using this knowledge,
I thought we could control the enqueuing based on the elements in the list. The
idea is simple.

1. Before the background job starts, I would seed this list with `n` elements
   where `n` is the desired concurrency. So, if I seed this list with `2`
   elements, Sidekiq would execute only 2 jobs at any point in time, regardless
   of the number of worker instances/concurrency of sidekiq workers.
2. The way this is enforced is by the enqueue function using a `BLPOP` before it
   enqueues, so, as soon as the enqueuer starts, it pops the first 2 elements from
   the redis list and enqueues 2 jobs. At this point the enqueuer is stuck till we
   add more elements to the list.
3. That's where the background jobs come into play, at the end of each
   background job, we add one element back to the list using `LPUSH` and as soon
   as an element is added the enqueuer which is blocked at `BLPOP` pops this
   elemnent and enqueues another job. This goes on till all your background jobs
   are enqueued, all the while making sure that there are never more than 2 jobs
   at any given time.

Let's put this into concrete ruby code.

```ruby
module ControlledConcurrency
  # I love module_function
  module_function

  # The name of our list needs to be constant per worker type, you could
  # probably extract this into a Sidekiq middleware with a little effort
  LIST_NAME = "migrate"

  def setup(concurrency:)
    # if our list already has elements before we start, our concurrency will be
    # screwed, so, this is a safety check!
    slot_count = Redis.current.llen(LIST_NAME)
    raise "Key '#{LIST_NAME}' is being used, it already has #{slot_count} slots" if slot_count > 0

    # Seed our list with as many items as the concurrency, the contents of this
    # list don't matter.
    Redis.current.lpush(LIST_NAME, concurrency.times.to_a)
  end

  # A helper function to bump up concurrency if you need to
  def increase_concurrency(n = 1)
    Redis.current.lpush(LIST_NAME, n.times.to_a)
  end

  # A helper function to bump the concurrency down if you need to
  def decrease_concurrency(n = 1)
    n.times do
      puts "> waiting"
      Redis.current.blpop(LIST_NAME)
      puts "> decrease by 1"
    end
  end

  # This is our core enqueuer, it runs in a loop because our blpop might get a
  # timeout and return nil, we keep trying till it returns a value
  def nq(&block)
    loop do
      puts "> waiting to enqueue"
      slot = Redis.current.blpop(LIST_NAME)
      if slot
        puts "> found slot #{slot}"
        yield
        return
      end
    end
  end

  # Function which allow background workers to signal that a job has been
  # completed, so that the enqueuer can nq more jobs.
  def return_slot
    puts "> returning slot"
    Redis.current.lpush(LIST_NAME, 1)
  end

end

# This is our Sidekiq worker
class HardWorker
  include Sidekiq::Worker

  # Our set up doesn't enforce concurrency across retries, if you want this,
  # you'll probably have to tweak the code a little more :)
  sidekiq_options retry: false

  # the only custom code here is in the ensure block
  def perform(user_id)
    puts "> start: #{user_id}"
    # mock work
    sleep 1
    puts "> finish: #{user_id}"
  ensure
    # make sure that we return this slot at the end of the background job, so
    # that the next job can be enqueued. This doesn't handle retries because of
    # failures, we disabled retries for our job, but if you have them enabled,
    # you might end up having more jobs than the set concurrency because of
    # retried jobs.
    ControlledConcurrency.return_slot
  end
end

# ./concurrency_setter.rb
ControlledConcurrency.setup(concurrency: ARGV.first.to_i)

# ./enqueuer.rb
# Before running the enqueuer, we need to set up the concurrency using the above script
# This our enqueuer and it makes sure that the block passed to
# ControlledConcurrency.nq doesn't enqueue more jobs that our concurrency
# setting.
100.times do |i|
  ControlledConcurrency.nq do
    puts "> enqueuing user_id: #{i}"
    HardWorker.perform_async(i)
  end
end
```

That's all folks! Hope you find this useful!

The full code for this can be found at: https://github.com/minhajuddin/sidekiq-controlled-concurrency
