title: Solution to Advent of Code 2018 Day 4 in Elixir
date: 2018-12-14 05:24:48
tags:
- Elixir
- Advent of Code
---

```elixir
defmodule Day4 do
  defmodule State do
    defstruct [:guard_id, :start, :sleep]
  end

  defp desc_minutes({_k, ranges}) do
    ranges
    |> Enum.reduce(0, fn x, sum ->
      sum + Enum.count(x)
    end)
    |> Kernel.*(-1)
  end

  def find_sleep_constant(spec) do
    {guard, sleep_durations} =
      spec
      |> parse
      |> Enum.sort_by(&desc_minutes/1)
      |> hd

    guard * most_sleepy_minute(sleep_durations)
  end

  def sleepiest_guard_minute(spec) do
    {guard_id, {min, _count}} =
      spec
      |> parse # => %{ guard_id => [min_start1..min_end1] }
      |> Enum.map(fn {guard_id, durations} ->
        {min, occurences} =
          durations
          |> Enum.flat_map(&Enum.to_list/1)
          |> Enum.group_by(& &1)
          |> Enum.max_by(fn {_min, occurences} -> Enum.count(occurences) end)

        {guard_id, {min, length(occurences)}}
      end)
      |> Enum.max_by(fn {_guard_id, {_min, count}} -> count end)
    {guard_id, min}
  end

  def most_sleepy_minute(sleep_durations) do
    {minute, _} =
      sleep_durations
      |> Enum.flat_map(&Enum.to_list/1)
      |> Enum.group_by(& &1)
      |> Enum.sort_by(fn {_k, v} -> -1 * Enum.count(v) end)
      |> hd

    minute
  end

  def parse(spec) do
    {_state, logs} =
      spec
      |> String.split("\n", trim: true)
      |> Enum.sort()
      |> Enum.map(&parse_line/1)
      |> Enum.reduce({_state = %State{}, _out = %{}}, fn x, {state, out} ->
        case x do
          {:start, guard_id, _minutes} ->
            {%{state | guard_id: guard_id}, out}

          {:sleep, minutes} ->
            {%{state | start: minutes}, out}

          {:wake, minutes} ->
            prev_sleep = out[state.guard_id] || []
            {state, Map.put(out, state.guard_id, [state.start..(minutes - 1) | prev_sleep])}
        end
      end)

    logs
  end

  def parse_line(line) do
    <<"[", _year::32, "-", _month::16, "-", _day::16, " ", _hour::16, ":",
      minutes_bin::binary-size(2), "] ", note::binary>> = line

    parse_note(note, String.to_integer(minutes_bin))
  end

  def parse_note("wakes up", minutes) do
    {:wake, minutes}
  end

  def parse_note("falls asleep", minutes) do
    {:sleep, minutes}
  end

  def parse_note(begin_note, minutes) do
    guard_id =
      Regex.named_captures(~r[Guard #(?<guard_id>\d+) begins shift], begin_note)
      |> Map.get("guard_id")
      |> String.to_integer()

    {:start, guard_id, minutes}
  end
end

defmodule Day4Test do
  use ExUnit.Case

  import Day4

  test "parses the times when each guard sleeps" do
    assert parse("""
           [1518-11-01 00:00] Guard #10 begins shift
           [1518-11-01 00:05] falls asleep
           [1518-11-01 00:25] wakes up
           [1518-11-01 00:30] falls asleep
           [1518-11-01 00:55] wakes up
           [1518-11-01 23:58] Guard #99 begins shift
           [1518-11-02 00:40] falls asleep
           [1518-11-02 00:50] wakes up
           [1518-11-03 00:05] Guard #10 begins shift
           [1518-11-03 00:24] falls asleep
           [1518-11-03 00:29] wakes up
           [1518-11-04 00:02] Guard #99 begins shift
           [1518-11-04 00:36] falls asleep
           [1518-11-04 00:46] wakes up
           [1518-11-05 00:03] Guard #99 begins shift
           [1518-11-05 00:45] falls asleep
           [1518-11-05 00:55] wakes up
           [1518-11-08 00:03] Guard #99334 begins shift
           [1518-11-08 00:45] falls asleep
           [1518-11-08 00:55] wakes up
           """) == %{
             10 => [5..24, 30..54, 24..28] |> Enum.reverse(),
             99 => [40..49, 36..45, 45..54] |> Enum.reverse(),
             99334 => [45..54]
           }
  end

  test "find_sleep_constant" do
    assert find_sleep_constant("""
           [1518-11-01 00:00] Guard #10 begins shift
           [1518-11-01 00:05] falls asleep
           [1518-11-01 00:25] wakes up
           [1518-11-01 00:30] falls asleep
           [1518-11-01 00:55] wakes up
           [1518-11-01 23:58] Guard #99 begins shift
           [1518-11-02 00:40] falls asleep
           [1518-11-02 00:50] wakes up
           [1518-11-03 00:05] Guard #10 begins shift
           [1518-11-03 00:24] falls asleep
           [1518-11-03 00:29] wakes up
           [1518-11-04 00:02] Guard #99 begins shift
           [1518-11-04 00:36] falls asleep
           [1518-11-04 00:46] wakes up
           [1518-11-05 00:03] Guard #99 begins shift
           [1518-11-05 00:45] falls asleep
           [1518-11-05 00:55] wakes up
           """) == 240
  end

  test "parses line" do
    assert parse_line("[1518-11-01 00:08] wakes up") == {:wake, 8}
    assert parse_line("[1518-11-01 00:30] falls asleep") == {:sleep, 30}
    assert parse_line("[1518-11-01 00:23] Guard #10 begins shift") == {:start, 10, 23}
    assert parse_line("[1518-11-01 00:23] Guard #99 begins shift") == {:start, 99, 23}
  end

  test "file" do
    assert 240 ==
             find_sleep_constant("""
             [1518-11-01 00:00] Guard #10 begins shift
             [1518-11-01 00:05] falls asleep
             [1518-11-01 00:25] wakes up
             [1518-11-01 00:30] falls asleep
             [1518-11-01 00:55] wakes up
             [1518-11-01 23:58] Guard #99 begins shift
             [1518-11-02 00:40] falls asleep
             [1518-11-02 00:50] wakes up
             [1518-11-03 00:05] Guard #10 begins shift
             [1518-11-03 00:24] falls asleep
             [1518-11-03 00:29] wakes up
             [1518-11-04 00:02] Guard #99 begins shift
             [1518-11-04 00:36] falls asleep
             [1518-11-04 00:46] wakes up
             [1518-11-05 00:03] Guard #99 begins shift
             [1518-11-05 00:45] falls asleep
             [1518-11-05 00:55] wakes up
             """)

    assert File.read!("./input.txt")
           |> find_sleep_constant == 30630
  end

  test "sleepiest_guard_minute" do
    assert {99, 45} ==
             sleepiest_guard_minute("""
             [1518-11-01 00:00] Guard #10 begins shift
             [1518-11-01 00:05] falls asleep
             [1518-11-01 00:25] wakes up
             [1518-11-01 00:30] falls asleep
             [1518-11-01 00:55] wakes up
             [1518-11-01 23:58] Guard #99 begins shift
             [1518-11-02 00:40] falls asleep
             [1518-11-02 00:50] wakes up
             [1518-11-03 00:05] Guard #10 begins shift
             [1518-11-03 00:24] falls asleep
             [1518-11-03 00:29] wakes up
             [1518-11-04 00:02] Guard #99 begins shift
             [1518-11-04 00:36] falls asleep
             [1518-11-04 00:46] wakes up
             [1518-11-05 00:03] Guard #99 begins shift
             [1518-11-05 00:45] falls asleep
             [1518-11-05 00:55] wakes up
             """)

    assert {guard, min} =
             File.read!("./input.txt")
             |> sleepiest_guard_minute

    assert guard * min == 99
  end
end
```
