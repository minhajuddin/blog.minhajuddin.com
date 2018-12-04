title: Solution to Advent of Code 2018 Day 3 in Elixir
date: 2018-12-04 11:23:15
tags:
- Elixir
- Advent of Code
---

Solving Day 3 turned out to be a bit more challenging for me as I don't usually
do these kind of exercises, Nevertheless it was fun!

```elixir

defmodule Rect do
  defstruct [:id, :left, :top, :width, :height]

  alias __MODULE__

  def parse(spec) do
    [id, dimensions] = String.split(spec, "@", trim: true)
    [coords, size] = String.split(dimensions, ":", trim: true)

    [left, top] = String.split(coords, ",", trim: true) |> Enum.map(&parse_number/1)

    [width, height] = String.split(size, "x", trim: true) |> Enum.map(&parse_number/1)

    %Rect{
      id: String.trim(id),
      left: left,
      top: top,
      width: width,
      height: height
    }
  end

  defp parse_number(str), do: str |> String.trim() |> String.to_integer()

  def order_horizontal(r1, r2) do
    if r1.left < r2.left do
      {r1, r2}
    else
      {r2, r1}
    end
  end

  def order_vertical(r1, r2) do
    if r1.top < r2.top do
      {r1, r2}
    else
      {r2, r1}
    end
  end

  def squares(%Rect{width: w, height: h}) when w <= 0 or h <= 0, do: []

  def squares(%Rect{} = r) do
    for x <- r.left..(r.left + r.width - 1), y <- r.top..(r.top + r.height - 1), do: {x, y}
  end
end

defmodule Overlap do
  def area(spec) when is_binary(spec) do
    spec
    |> String.split("\n", trim: true)
    |> Enum.map(&Rect.parse/1)
    |> area
  end

  def area(rects, prev_squares \\ [])

  def area([h | tl], prev_squares) do
    squares =
      tl
      |> Enum.map(fn x -> overlap(h, x) |> Rect.squares() end)

    area(tl, [squares | prev_squares])
  end

  def area([], squares),
    do:
      squares
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.count()

  def find_non_overlap(spec) when is_binary(spec) do
    rects =
      spec
      |> String.split("\n", trim: true)
      |> Enum.map(&Rect.parse/1)

    find_non_overlap(rects, rects)
  end

  def find_non_overlap([h | tl], all_rects) do
    if all_rects
       |> Enum.filter(fn x -> x.id != h.id end)
       |> Enum.all?(fn x ->
         o = overlap(h, x)
         o.width <= 0 || o.height <= 0
       end) do
      h
    else
      find_non_overlap(tl, all_rects)
    end
  end

  def find_non_overlap([], _), do: raise("Not found")

  def overlap(%Rect{} = r1, %Rect{} = r2) do
    {l, r} = Rect.order_horizontal(r1, r2)

    width = min(l.left + l.width - r.left, r.width)

    {t, b} = Rect.order_vertical(r1, r2)

    height = min(t.top + t.height - b.top, b.height)

    %Rect{
      left: r.left,
      top: b.top,
      width: width,
      height: height
    }
  end
end

defmodule OverlapTest do
  use ExUnit.Case

  import Overlap

  test "greets the world" do
    assert area("""
           # 1 @ 1,3: 4x4
           # 2 @ 3,1: 4x4
           # 3 @ 5,5: 2x2
           """) == 4

    assert area("""
           # 1 @ 1,3: 4x4
           # 2 @ 3,1: 4x4
           # 3 @ 1,3: 4x4
           """) == 16

    assert File.read!("input.txt") |> area == 0
  end

  test "overlap between 2 rects" do
    assert overlap(
             %Rect{id: "# 1", left: 1, top: 3, width: 4, height: 8},
             %Rect{id: "# 2", left: 3, top: 1, width: 4, height: 4}
           ) == %Rect{id: nil, left: 3, top: 3, width: 2, height: 2}

    assert overlap(
             %Rect{id: "# 1", left: 1, top: 3, width: 4, height: 4},
             %Rect{id: "# 3", left: 5, top: 5, width: 2, height: 2}
           ) == %Rect{height: 2, id: nil, left: 5, top: 5, width: 0}
  end

  test "find_non_overlap" do
    assert find_non_overlap("""
           # 1 @ 1,3: 4x4
           # 2 @ 3,1: 4x4
           # 3 @ 5,5: 2x2
           """).id == "# 3"

    assert File.read!("input.txt") |> find_non_overlap == 0
  end
end

defmodule RectTest do
  use ExUnit.Case

  test "parse" do
    assert Rect.parse("# 1 @ 1,3: 4x3") == %Rect{id: "# 1", left: 1, top: 3, width: 4, height: 3}
  end

  test "order_horizontal" do
    {%{id: "# 1"}, %{id: "# 2"}} =
      Rect.order_horizontal(
        %Rect{id: "# 1", left: 1, top: 3, width: 4, height: 3},
        %Rect{id: "# 2", left: 3, top: 3, width: 4, height: 3}
      )

    {%{id: "# 4"}, %{id: "# 3"}} =
      Rect.order_horizontal(
        %Rect{id: "# 3", left: 10, top: 3, width: 4, height: 3},
        %Rect{id: "# 4", left: 3, top: 3, width: 4, height: 3}
      )
  end

  test "order_vertical" do
    {%{id: "# 1"}, %{id: "# 2"}} =
      Rect.order_vertical(
        %Rect{id: "# 1", left: 1, top: 1, width: 4, height: 1},
        %Rect{id: "# 2", left: 3, top: 3, width: 4, height: 3}
      )

    {%{id: "# 4"}, %{id: "# 3"}} =
      Rect.order_vertical(
        %Rect{id: "# 3", left: 10, top: 10, width: 4, height: 10},
        %Rect{id: "# 4", left: 3, top: 3, width: 4, height: 3}
      )
  end

  test "squares" do
    assert Rect.squares(%Rect{id: "# 1", left: 1, top: 3, width: 2, height: 2}) == [
             {1, 3},
             {1, 4},
             {2, 3},
             {2, 4}
           ]

    assert Rect.squares(%Rect{id: "# 1", left: 1, top: 3, width: 0, height: 0}) == []
    assert Rect.squares(%Rect{id: "# 1", left: 1, top: 3, width: 0, height: 4}) == []
    assert Rect.squares(%Rect{id: "# 1", left: 1, top: 3, width: 4, height: 0}) == []
    assert Rect.squares(%Rect{id: "# 1", left: 1, top: 3, width: 4, height: -4}) == []
    assert Rect.squares(%Rect{id: "# 1", left: 1, top: 3, width: -4, height: 4}) == []
  end
end

```
