title: How to create a web server using Cowboy without Plug or Phoenix - Part 01
date: 2020-06-05 17:33:48
tags:
- Cowboy
- Webpipe
- Elixir
- Phoenix
- Plug
---

Cowboy is an amazing web server that is used by Plug/Phoenix out of the box, I
don't think Phoenix supports any other web servers at the moment. However, the
[plug
adapter](https://github.com/elixir-plug/plug/blob/master/lib/plug/conn/adapter.ex)
is fairly abstracted, and plug implements this adapter for cowboy through the
[plug_cowboy](https://github.com/elixir-plug/plug_cowboy/) hex package. In
theory, you should be able to write a new adapter if you just implement the [Plug
adapter <abbr title="That's not a typo :) it comes from the british heritage of
Erlang">behaviour</abbr>](https://github.com/elixir-plug/plug/blob/master/lib/plug/conn/adapter.ex).
The plug cowboy adapter has a lot of interesting code and you'll learn a lot
from reading it. Anyway, this blog post isn't about Plug or Phoenix. I wanted to
show off how you can create a simple Cowboy server without using Plug or Phoenix
(I had to learn how to do this while creating my side project
[webpipe](https://webpipe.hyperngn.com/))

We want an application which spins up a cowboy server and renders a hello world
message. Here is the required code for that:

```elixir
defmodule Hello do
  # The handler module which handles all requests, its `init` function is called
  # by Cowboy for all matching requests.
  defmodule Handler do
    def init(req, _opts) do
      resp =
        :cowboy_req.reply(
          _status = 200,
          _headers = %{"content-type" => "text/html; charset=utf-8"},
          _body = "<!doctype html><h1>Hello, Cowboy!</h1>",
          _request = req
        )

      {:ok, resp, []}
    end
  end

  def start do
    # compile the routes
    routes =
      :cowboy_router.compile([
        {:_,
         [
           # { wildcard, handler module (needs to have an init function), options }
           {:_, Handler, []}
         ]}
      ])

    require Logger
    Logger.info("Staring server at http://localhost:4001/")

    # start an http server
    :cowboy.start_clear(
      :hello_http,
      [port: 4001],
      %{env: %{dispatch: routes}}
    )
  end
end
```

And, here is a quick test to assert that it works!

```elixir
defmodule HelloTest do
  use ExUnit.Case

  test "returns hello world" do
    assert {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, '<!doctype html><h1>Hello, Cowboy!</h1>'}} =
             :httpc.request('http://localhost:4001/')
  end
end
```

[Full code on GitHub](https://github.com/hyperngn/cowboy-examples/tree/master/hello)
