title: A simple ticker to receive tick events for every interval in Elixir
date: 2016-10-27 02:26:07
tags:
- Go
- Ticker
- Elixir
---

Go has very utilitarian ticker methods, for instance check: https://gobyexample.com/tickers

~~~go
package main

import "time"
import "fmt"

func main() {

    // Tickers use a similar mechanism to timers: a
    // channel that is sent values. Here we'll use the
    // `range` builtin on the channel to iterate over
    // the values as they arrive every 500ms.
    ticker := time.NewTicker(time.Millisecond * 500)
    go func() {
        for t := range ticker.C {
            fmt.Println("Tick at", t)
        }
    }()

    // Tickers can be stopped like timers. Once a ticker
    // is stopped it won't receive any more values on its
    // channel. We'll stop ours after 1600ms.
    time.Sleep(time.Millisecond * 1600)
    ticker.Stop()
    fmt.Println("Ticker stopped")
}
~~~

These are very nice for running code at every interval. If you want something like this in Elixir,
it can be implemented in a few lines of code.

This code allows you to create a `Ticker` process by calling `Ticker.start` with a `recipient_pid`
which is the process which receives the `:tick` events, a `tick_interval` to specify how often
a `:tick` event should be sent to the recipient_pid and finally a `duration` whose default is
`:infinity` which means it will just keep ticking till the end of time. Once you set this up,
the recipient will keep getting `:tick` events for every `tick_interval`.
Go ahead and read the code, it is pretty self explanatory.

There is also erlang's `:timer.apply_interval(time, module, function, arguments)` which will run
some code for every interval of `time`. However, the code below doesn't create overlapping executions.

I have also created a gist in the interest of collaboration here: https://gist.github.com/minhajuddin/064226d73d5648aa73364218e862a497

~~~elixir
defmodule Ticker do
  require Logger
  # public api
  def start(recipient_pid, tick_interval, duration \\ :infinity) do
    # Process.monitor(pid) # what to do if the process is dead before this?
    # start a process whose only responsibility is to wait for the interval
    ticker_pid = spawn(__MODULE__, :loop, [recipient_pid, tick_interval, 0])
    # and send a tick to the recipient pid and loop back
    send(ticker_pid, :send_tick)
    schedule_terminate(ticker_pid, duration)
    # returns the pid of the ticker, which can be used to stop the ticker
    ticker_pid
  end

  def stop(ticker_pid) do
    send(ticker_pid, :terminate)
  end

  # internal api
  def loop(recipient_pid, tick_interval, current_index) do
    receive do
      :send_tick ->
        send(recipient_pid, {:tick, current_index}) # send the tick event
        Process.send_after(self, :send_tick, tick_interval) # schedule a self event after interval
        loop(recipient_pid, tick_interval, current_index + 1)
      :terminate ->
        :ok # terminating
        # NOTE: we could also optionally wire it up to send a last_tick event when it terminates
        send(recipient_pid, {:last_tick, current_index})
      oops ->
        Logger.error("received unexepcted message #{inspect oops}")
        loop(recipient_pid, tick_interval, current_index + 1)
    end
  end

  defp schedule_terminate(_pid, :infinity), do: :ok
  defp schedule_terminate(ticker_pid, duration), do: Process.send_after(ticker_pid, :terminate, duration)
end


defmodule Listener do
  def start do
    Ticker.start self, 500, 2000 # will send approximately 4 messages
  end

  def run do
    receive do
      {:tick, _index} = message ->
        IO.inspect(message)
        run
      {:last_tick, _index} = message ->
        IO.inspect(message)
        :ok
    end
  end
end

Listener.start
Listener.run
# will output
# => {:tick, 0}
# => {:tick, 1}
# => {:tick, 2}
# => {:tick, 3}
# => {:last_tick, 4}
~~~
