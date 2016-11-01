title: How to extract bits from a binary in elixir
date: 2016-11-01 10:58:50
tags:
- Elixir
- Binary
- Bits
- Pattern matching
---

Erlang and by extension Elixir have powerful pattern matching constructs, which
allow you to easily extract bits from a binary. Here is an example which takes
a binary and returns their bits

~~~elixir
defmodule Bits do
  # this is the public api which allows you to pass any binary representation
  def extract(str) when is_binary(str) do
    extract(str, [])
  end

  # this function does the heavy lifting by matching the input binary to
  # a single bit and sends the rest of the bits recursively back to itself
  defp extract(<<b :: size(1), bits :: bitstring>>, acc) when is_bitstring(bits) do
    extract(bits, [b | acc])
  end

  # this is the terminal condition when we don't have anything more to extract
  defp extract(<<>>, acc), do: acc |> Enum.reverse
end

IO.inspect Bits.extract("!!") # => [0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1]
IO.inspect Bits.extract(<< 99 >>) #=> [0, 1, 1, 0, 0, 0, 1, 1]
~~~

The code is pretty self explanatory
