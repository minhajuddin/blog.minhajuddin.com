title: 7 ways of doing Fizz Buzz in Elixir and other clickbaity stuff
date: 2018-07-06 10:58:36
tags:
- Elixir
- FizzBuzz
---
Every developer "worth their salt" knows how to implement FizzBuzz, It is a program which prints the following:

```
defmodule FizzBuzz do
  def run(count) do
    Enum.map(1..20, &fizzbuzz/1)
  end

  def fizzbuzz(n) do
    # ...
  end
end
iex> FizzBuzz.run(16)
# => 1, 2, Fizz, 4, Buzz, Fizz, 7, 8, Fizz, Buzz, 11, Fizz, 13, 14, FizzBuzz, 16
```

Let us see a few possible ways to do this in Elixir!

## 1. Use if

```elixir
def fb_if(n) do
  if rem(n, 3) == 0 and rem(n, 5) == 0 do
    "FizzBuzz"
  else
    if rem(n, 3) == 0 do
      "Fizz"
    else
      if rem(n, 5) == 0 do
        "Buzz"
      else
        n
      end
    end
  end
end
```

That is some real ugly code, it is exacerbated by the fact that Elixir doesn't allow early returns.

## 2. Use cond

```elixir
def fb_cond1(n) do
  cond do
    rem(n, 3) == 0 and rem(n, 5) == 0 -> "FizzBuzz"
    rem(n, 3) == 0 -> "Fizz"
    rem(n, 5) == 0 -> "Buzz"
    true -> n
  end
end
```

This is a huge improvement, I really think this captures the problem the solution in a very readable way.

## 3. Use cond with better predicates

```elixir
def divisible_by_3?(n), do: rem(n, 3) == 0
def divisible_by_5?(n), do: rem(n, 5) == 0

def fb_cond2(n) do
  cond do
    divisible_by_3?(n) and divisible_by_5?(n) -> "FizzBuzz"
    divisible_by_3?(n) -> "Fizz"
    divisible_by_5?(n) -> "Buzz"
    true -> n
  end
end
```
Using separate predicates improves the readability further.

## 4. Use case

```elixir
def fb_case(n) do
  case {rem(n, 3), rem(n,5)} do
    {0, 0} -> "FizzBuzz"
    {0, _} -> "Fizz"
    {_, 0} -> "Buzz"
    _ -> n
  end
end
```

This is a concise chunk of code but isn't as readable as the one that uses cond.

## 5. Use pattern matching in functions

```elixir
def fb_fun1(n) do
  fb_fun(n, rem(n, 3), rem(n, 5))
end

def fb_fun(_, 0, 0), do: "FizzBuzz"
def fb_fun(_, 0, _), do: "Fizz"
def fb_fun(_, _, 0), do: "Buzz"
def fb_fun(n, _, _), do: n
```

I think this is actually less readable than the one that uses case as the logic.

## 6. Use guard clauses in functions

```
def fb_fun2(n) when rem(n, 3) == 0 and rem(n, 5) == 0, do: "FizzBuzz"
def fb_fun2(n) when rem(n, 3) == 0, do: "Fizz"
def fb_fun2(n) when rem(n, 5) == 0, do: "Buzz"
def fb_fun2(n), do: n
```

This feels like an improvement to the previous implementation readability wise.

## 7. Use custom made guard clauses in functions

```elixir
defguard is_divisible_by_3(n) when rem(n, 3) == 0
defguard is_divisible_by_5(n) when rem(n, 5) == 0

def fb_fun3(n) when is_divisible_by_3(n) and is_divisible_by_5(n), do: "FizzBuzz"
def fb_fun3(n) when is_divisible_by_3(n), do: "Fizz"
def fb_fun3(n) when is_divisible_by_5(n), do: "Buzz"
def fb_fun3(n), do: n
```

I like this one a lot, it feels very terse and reads like a mathematical equation.

Which version do you personally find more readable? I feel like the last one
and the implementation using cond are the more readable versions.

Here is the piece of code containing all implementations:

```
defmodule Fizzbuzz do
  def fb_if(n) do
    if rem(n, 3) == 0 and rem(n, 5) == 0 do
      "FizzBuzz"
    else
      if rem(n, 3) == 0 do
        "Fizz"
      else
        if rem(n, 5) == 0 do
          "Buzz"
        else
          n
        end
      end
    end
  end

  def fb_cond1(n) do
    cond do
      rem(n, 3) == 0 and rem(n, 5) == 0 -> "FizzBuzz"
      rem(n, 3) == 0 -> "Fizz"
      rem(n, 5) == 0 -> "Buzz"
      true -> n
    end
  end

  def divisible_by_3?(n), do: rem(n, 3) == 0
  def divisible_by_5?(n), do: rem(n, 5) == 0

  def fb_cond2(n) do
    cond do
      divisible_by_3?(n) and divisible_by_5?(n) -> "FizzBuzz"
      divisible_by_3?(n) -> "Fizz"
      divisible_by_5?(n) -> "Buzz"
      true -> n
    end
  end

  def fb_case(n) do
    case {rem(n, 3), rem(n, 5)} do
      {0, 0} -> "FizzBuzz"
      {0, _} -> "Fizz"
      {_, 0} -> "Buzz"
      _ -> n
    end
  end

  def fb_fun1(n) do
    fb_fun1(n, rem(n, 3), rem(n, 5))
  end

  def fb_fun1(_, 0, 0), do: "FizzBuzz"
  def fb_fun1(_, 0, _), do: "Fizz"
  def fb_fun1(_, _, 0), do: "Buzz"
  def fb_fun1(n, _, _), do: n

  def fb_fun2(n) when rem(n, 3) == 0 and rem(n, 5) == 0, do: "FizzBuzz"
  def fb_fun2(n) when rem(n, 3) == 0, do: "Fizz"
  def fb_fun2(n) when rem(n, 5) == 0, do: "Buzz"
  def fb_fun2(n), do: n

  defguard is_divisible_by_3(n) when rem(n, 3) == 0
  defguard is_divisible_by_5(n) when rem(n, 5) == 0

  def fb_fun3(n) when is_divisible_by_3(n) and is_divisible_by_5(n), do: "FizzBuzz"
  def fb_fun3(n) when is_divisible_by_3(n), do: "Fizz"
  def fb_fun3(n) when is_divisible_by_5(n), do: "Buzz"
  def fb_fun3(n), do: n

end


ExUnit.start()

defmodule FizzbuzzTest do
  use ExUnit.Case

  @run_20_out [
    1,
    2,
    "Fizz",
    4,
    "Buzz",
    "Fizz",
    7,
    8,
    "Fizz",
    "Buzz",
    11,
    "Fizz",
    13,
    14,
    "FizzBuzz",
    16,
    17,
    "Fizz",
    19,
    "Buzz"
  ]

  def assert_fizzbuzz(fun) do
    assert 1..20 |> Enum.map(fn x -> apply(Fizzbuzz, fun, [x]) end) == @run_20_out
  end

  test "run" do
    assert_fizzbuzz(:fb_if)
    assert_fizzbuzz(:fb_cond1)
    assert_fizzbuzz(:fb_cond2)
    assert_fizzbuzz(:fb_case)
    assert_fizzbuzz(:fb_fun1)
    assert_fizzbuzz(:fb_fun2)
    assert_fizzbuzz(:fb_fun3)
  end
end

```
