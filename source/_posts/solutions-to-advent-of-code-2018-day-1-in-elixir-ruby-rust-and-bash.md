title: 'Solutions to Advent of Code 2018 Day 1 in Elixir and Ruby'
date: 2018-12-01 21:56:11
tags:
- Advent of Code
- Elixir
- Ruby
---

Day 1 had a simple challenge, compute the sum of a few numbers and find out when
a prev frequency shows up again.

## Part 1

### Elixir

The elixir version is pretty straightforward, we create a stream using the
standard input which creates an entry per line, transform it into a number and
compute the sum:

```elixir
#!/usr/bin/env elixir
# run it as follows:
# $ ./elixir.exs < input.txt
# 484

# read each line
IO.stream(:stdio, :line)
|> Stream.map(fn str ->
  {n, ""} = str |> String.trim() |> Integer.parse()
  n
end)
|> Enum.sum()
|> IO.puts()

```

### Ruby

The ruby version is similar to the elixir version

```ruby
#!/usr/bin/env ruby
# run it as follows:
# $ ./ruby.rb < input.txt
# 484

puts ARGF.each_line
         .map(&:to_i)
         .sum
```

## Part 2

### Elixir

This was a bit tricky as you may have to repeat the input multiple times to get
the answer. To do this in elixir, we use simple recursion if we aren't able to
find a repeating frequency in the current iteration. Also, note that we are
using a `map` to store previous frequencies, I have seen folks use a list which
cause a huge impact on performance as lists don't perform well for lookups
whereas maps really shine in these scenarios.

```elixir
defmodule ChronalCalibration do

  def part_2(input, start_freq \\ 0, prev_freqs \\ %{0 => true}) do
    res =
      input
      |> String.split("\n")
      |> Enum.reduce_while({start_freq, prev_freqs}, fn x, {freq, prev_freqs} ->
        {i, ""} = Integer.parse(x)
        freq = i + freq

        if prev_freqs[freq] do
          {:halt, {:succ, freq}}
        else
          {:cont, {freq, Map.put(prev_freqs, freq, true)}}
        end
      end)

    case res do
      {:succ, freq} -> freq
      {freq, prev_freqs} -> part_2(input, freq, prev_freqs)
    end
  end

end

IO.puts File.read!("input.txt") |> ChronalCalibration.part_2
```

### Ruby

The Ruby implementation is similar to the Elixir implementation.

```ruby
def repeating_freq
  input = File.read("input.txt")
  prev_freqs = { 0 => true }
  freq = 0

  loop do
    input
      .lines
      .each do |curr|
        freq += curr.to_i
        return freq if prev_freqs[freq]
        prev_freqs[freq] = true
      end
  end
end
puts repeating_freq()

```

