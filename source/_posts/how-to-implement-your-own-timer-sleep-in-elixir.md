title: 'How to implement your own :timer.sleep in Elixir'
date: 2018-05-11 16:41:17
tags:
- Elixir
- Sleep
---

Elixir has `:timer.sleep(ms)`, a function which allows you to pause a process's execution for an
arbitrary number of milliseconds.

We can implement the same using messages and a timeout in the following ways.


```elixir
defmodule SleepTimeout do
  def sleep(milliseconds) do
    # use a receive block with no matching blocks and an after block
    # which times out after the input number of milliseconds
    receive do
    after
      milliseconds ->
        :ok
    end
  end
end

defmodule SleepMsg do
  def sleep(milliseconds) do
    # create a unique ref, so that we don't stop on any random `:timeout` message.
    ref = make_ref()
    # schedule a message to be sent to ourselves in the input number of milliseconds
    Process.send_after(self(), {:timeout, ref}, milliseconds)

    receive do
      # wait for our message to arrive
      {:timeout, ^ref} ->
        :ok
    end
  end
end

{microseconds, _} = :timer.tc(fn -> SleepTimeout.sleep(1000) end)
IO.puts("slept for #{round(microseconds / 1000)} microseconds")
# => slept for 1000 microseconds


{microseconds, _} = :timer.tc(fn -> SleepMsg.sleep(1000) end)
IO.puts("slept for #{round(microseconds / 1000)} microseconds")
# => slept for 1001 microseconds

```

You may ask, what is the frigging point of all of this when we have `:timer.sleep`?
Well, there is no point. This was just a fun little exercise :D
