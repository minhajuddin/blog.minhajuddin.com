title: Elixir IO.inspect to debug pipelines
date: 2016-05-20 15:16:42
tags:
- Elixir
- Pipelines
- Debug
---

While writing multiple pipelines, you may want to debug the intermediate values.
Just insert ` |> IO.inspect ` between your pipelines.

e.g. in the expression below:

~~~elixir
:crypto.strong_rand_bytes(32)
  |> :base64.encode_to_string
  |> :base64.decode
  |> :base64.encode
~~~

If we want to check intermediate values we just need to add a `|> IO.inspect`

~~~elixir
:crypto.strong_rand_bytes(32)
  |> IO.inspect
  |> :base64.encode_to_string
  |> IO.inspect
  |> :base64.decode
  |> IO.inspect
  |> :base64.encode
  |> IO.inspect
~~~

This will print all the intermediate values to the STDOUT. IO.inspect is a function which prints the input and returns it.
