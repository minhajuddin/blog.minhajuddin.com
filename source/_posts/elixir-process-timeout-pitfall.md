title: Elixir process timeout pitfall
date: 2016-10-31 17:13:12
tags:
- Elixir
- Process
- Timeout
- Task
---

If you taken a look at Elixir, you may have come across something like the below code

~~~elixir
defmodule HardWorker do
  def work(id) do
    Process.sleep(id * 900)
    {:done, id}
  end
end

defmodule Runner do
  @total_timeout 1000

  def run do
    {us, _} = :timer.tc &work/0
    IO.puts "ELAPSED_TIME: #{us/1000}"
  end


  def work do
    tasks = Enum.map 1..10, fn id ->
      Task.async(HardWorker, :work, [id])
    end

    Enum.map(tasks, fn task ->
      Task.await(task, @total_timeout)
    end)
  end

end

Runner.run
~~~

Looks simple enough, we loop over and create 10 processes and then wait
for them to finish. It also prints out a message `ELAPSED_TIME: _` at the end where
_ is the time taken for it to run all the processes.

**Can you take a guess how long this runner will take in the worst case?**

If you guessed 10 seconds, you are right! I didn't guess 10 seconds when I first
saw this kind of code. I expected it to exit after 1 second. However, the key
here is that `Task.await` is called on 10 tasks and if the 10 tasks finish
at the end of 1s, 2s, ... 10s This code will run just fine.

This is a completely made up example but it should show you that running in parallel
with timeouts is not just a `Task.await` away.

I have coded an example app with proper timeout handling and parallel processing at https://github.com/minhajuddin/parallel_elixir_workers
Check it out.

### Addendum
I posted this on [the elixirforum](https://elixirforum.com/t/elixir-task-timeout-pitfall/2192/11) and got some feedback about it.

~~~elixir
tasks = Enum.map 1..10, fn id ->
  Task.async(HardWorker, :work, [id])
end

# at this point all tasks are running in parallel

Enum.map(tasks, fn task ->
  Task.await(task, @total_timeout)
end)
~~~

Let us take another look at the relevant code. Now, let us say that this is spawning
processes P1 to P10 in that order. Let's say tasks T1 to T10 are created for these processes.
Now all these tasks are running concurrently.

Now, in the second `Enum.map`, in the first iteration the task is set to T1,
so T1 has to finish before 1 second otherwise this code will timeout. However,
while T1 is running T2..T10 are also running. So, when this code runs for T2 and
waits for 1 second, T2 had been running for 2s. So, effectively T1 would be given
a time of 1 second, T2 a time of 2 seconds and T3 a time of 3 seconds and so on.

This may be what you want. However, if you want all the tasks to finish executing within 1 second.
You shouldn't use `Task.await`. You can use `Task.yield_many` which takes a list of tasks
and allows you to specify a timeout after which it returns with the results of whatever
processes finished. The [documentation for Task.yield_many](http://elixir-lang.org/docs/stable/elixir/Task.html#yield_many/2) has a very good
example on how to use it.

[@benwilson512 has a good example on this](https://elixirforum.com/t/elixir-task-timeout-pitfall/2192/7?u=minhajuddin)

> ..suppose you wrote the following code:

~~~elixir
task = Task.async(fn -> Process.sleep(:infinity) end)

Process.sleep(5_000)
Task.await(task, 5_000)
~~~

> How long before it times out? 10 seconds of course. But this is obvious and expected.
> This is exactly what you're doing by making the Task.await calls consecutive.
> It's just that instead of sleeping in the main process you're waiting on a different task.
> Task.await is blocking, this is expected.
