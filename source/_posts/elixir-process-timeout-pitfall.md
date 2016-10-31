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
