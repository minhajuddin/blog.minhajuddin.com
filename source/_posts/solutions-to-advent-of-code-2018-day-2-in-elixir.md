title: Solutions to Advent of Code 2018 Day 2 in Elixir
date: 2018-12-02 20:07:39
tags:
- Elixir
- Advent Of Code
---

Day 2's problem was a bit tricky for Elixir. Check out the commented code to see
how I tackled it:


```elixir
#! /usr/bin/env elixir

defmodule Day2 do
  def checksum(ids) do
    {two_count, three_count} =
      ids
      |> String.split("\n", trim: true)
      |> Enum.reduce({0, 0}, fn id, {two_count, three_count} ->
        char_counts =
          id
          |> String.graphemes()
          |> Enum.group_by(& &1)
          |> Enum.map(fn {_c, vals} -> Enum.count(vals) end)
          |> Enum.uniq()

        {incr_if_count(char_counts, two_count, 2), incr_if_count(char_counts, three_count, 3)}
      end)

    two_count * three_count
  end

  defp incr_if_count(counts, prev_count, matcher) do
    if matcher in counts do
      prev_count + 1
    else
      prev_count
    end
  end

  def find_common_boxes(ids) do
    ids =
      ids
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)

    {lhs, rhs} = find_similar(ids)


    intersection(lhs, rhs)
  end

  defp intersection(lhs, rhs) do
    Enum.zip(lhs, rhs)
    |> Enum.map(fn {l, l} -> l; _ -> nil end)
    |> Enum.filter(& &1)
    |> Enum.join
  end

  defp find_similar([lhs_id | ids]) do
    matching_id =
      Enum.find(ids, fn rhs_id ->
        diff_count(lhs_id, rhs_id) == 1
      end)

    if matching_id do
      {lhs_id, matching_id}
    else
      find_similar(ids)
    end
  end

  defp diff_count(lhs, rhs) do
    Enum.zip(lhs, rhs)
    |> Enum.map(fn
      {x, x} -> 0
      _ -> 1
    end)
    |> Enum.sum()
  end
end

ExUnit.start()

defmodule Day2Test do
  use ExUnit.Case

  import Day2

  test "#checksum" do
    assert checksum("""
           abcdef
           bababc
           abbcde
           abcccd
           aabcdd
           abcdee
           ababab
           """) == 12

    assert File.read!("input.txt") |> checksum == 4693
  end

  test "#find_common_boxes" do
    assert find_common_boxes("""
           abcde
           fghij
           klmno
           pqrst
           fguij
           axcye
           wvxyz
           """) == "fgij"

    assert File.read!("input.txt") |> find_common_boxes == "pebjqsalrdnckzfihvtxysomg"
  end
end
```
