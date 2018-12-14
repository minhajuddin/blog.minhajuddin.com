title: Solution to Advent of Code 2018 Day 5 in Elixir
date: 2018-12-14 05:26:18
tags:
- Elixir
- Advent of Code
---

```elixir
defmodule Day5 do
  def scan(polymer) do
    chars =
      polymer
      |> String.to_charlist()

    res =
      chars
      |> Enum.reduce({:none, []}, fn
        c, {:none, acc} ->
          {:prev, c, acc}

        c, {:prev, prev, acc} ->
          if react?(c, prev) do
            {:none, acc}
          else
            {:prev, c, [prev | acc]}
          end
      end)

    reduced_polymer =
      case res do
        {_, acc} -> acc
        {:prev, c, acc} -> [c | acc]
      end
      |> Enum.reverse()
      |> to_string

    if reduced_polymer == polymer do
      polymer
    else
      scan(reduced_polymer)
    end
  end

  def react?(c1, c2), do: abs(c1 - c2) == 32

  @all_units Enum.zip(?a..?z, ?A..?Z) |> Enum.map(fn {c1, c2} -> ~r[#{[c1]}|#{[c2]}] end)
  def smallest(polymer) do
    @all_units
    |> Enum.map(fn unit_to_be_removed ->
      polymer
      |> String.replace(unit_to_be_removed, "")
      |> scan
      |> String.length()
    end)
    |> Enum.min()
  end
end

defmodule Day5Test do
  use ExUnit.Case

  import Day5

  test "reduces 2 reacting units" do
    assert scan("aA") == ""
  end

  test "reduces 2 non reacting units" do
    assert scan("aB") == "aB"
    assert scan("Ba") == "Ba"
  end

  test "reduces 3 non reacting units" do
    assert scan("aBc") == "aBc"
    assert scan("aBA") == "aBA"
    assert scan("BaD") == "BaD"
  end

  test "reduces 3 reacting units" do
    assert scan("aAB") == "B"
    assert scan("abB") == "a"
    assert scan("aBb") == "a"
    assert scan("BaA") == "B"
  end

  test "reduces recursively" do
    assert scan("baAB") == ""
  end

  test "large polymer" do
    assert scan("dabAcCaCBAcCcaDA") == "dabCBAcaDA"
    assert scan("abcdDCBA") == ""
  end

  test "input" do
    assert File.read!("./input.txt") |> String.trim() |> scan |> String.length() == 0
  end

  test "smallest" do
    assert smallest("dabAcCaCBAcCcaDA") == 4
  end

  test "smallest for input" do
    assert File.read!("./input.txt") |> String.trim() |> smallest == 0
  end
end
```
