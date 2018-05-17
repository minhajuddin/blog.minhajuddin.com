title: Your Elixir bucket for debugging
date: 2018-05-17 12:52:02
tags:
- ets
- debug
- iex
---

While debugging and experimenting with apis in javascript, I usually set a variable
on `window` and then play with it in the console.

```javascript

  // ....

  let channel = socket.channel( //...

  window.channel = channel;

```

Once the above code is set, I can just jump into the console and start pushing
messages to the channel and discover how it all works by poking it around.

This led me to think about how this can be done in Elixir. And, in one of my
recent projects, I was spawning a few processes and wanted to get their pids
to play around by sending messages to them. And I just thought why not use `ets`
as global bucket to shove stuff into. Here is my solution:


Just create an `ets` table in your `.iex.exs`

```elixir
# .iex.exs
# A tmp bucket which you can push stuff into and analyze from iex
:ets.new(:tmp, [:named_table, :public])
```

And, wherever you want, just push things into this table:

```elixir
# in my app
def websocket_info(_msg, _conn, state) do
  :ets.insert(:tmp, {self(), :ok})
  # ...
```

Once you have that, you can start poking and prodding your processes/variables

```elixir
# iex>
:ets.tab2list(:tmp)
```

Hope this helps you while debugging your Elixir apps :D
