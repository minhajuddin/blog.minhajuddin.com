title: Key transformation after decoding json in Elixir
date: 2017-01-24 13:36:26
tags:
- Map
- Elixir
- JSON
- Key Transform
---

In a previous blog post we saw how to do [case insensitive retrieval from maps](http://minhajuddin.com/2017/01/11/case-insensitive-key-retrieval-from-maps-in-elixir/).
A better solution for this if there are many key lookups is to transform the input by lower casing all the keys just after decoding. The solution from the blog post would iterate over each `{key, value}` pair till it found the desired key.
However a proper map lookup doesn't iterate over the keys but uses a hashing algorithm to get to the key's location in constant time regardless of the size of the map.

Anyway, Here is the solution to transform each key for input JSON. Hope you find it useful :)

```elixir
defmodule KeyTransformer do
  def lower_case_keys(input) do
    transform_keys(input, &String.downcase/1)
  end

  def transform_keys(input, tx_key_fun) when is_list(input) do
    Enum.map(input, fn el -> transform_keys(el, tx_key_fun) end)
  end

  def transform_keys(input, tx_key_fun) when is_map(input) do
    Enum.reduce(input, %{}, fn {k, v}, acc ->
      Map.put(acc, tx_key_fun.(k), transform_keys(v, tx_key_fun))
    end)
  end

  def transform_keys(value, _tx_key_fun), do: value
end

ExUnit.start

defmodule KeyTransformerTest do
  use ExUnit.Case
  import KeyTransformer

  test "simple map" do
    assert lower_case_keys(%{"NAME" => "Khaja"}) == %{"name" => "Khaja"}
    assert lower_case_keys(%{"NAME" => "Khaja", "Age" => 3}) == %{"name" => "Khaja", "age" => 3}
  end

  test "nested map" do
    assert lower_case_keys(%{"Mujju" => %{"NAME" => "Khaja"}}) == %{"mujju" => %{"name" => "Khaja"}}
  end

  test "deeply nested map" do
    assert lower_case_keys(%{"Children" => %{"Mujju" => %{"NAME" => "Khaja"}}}) == %{"children" => %{"mujju" => %{"name" => "Khaja"}}}
  end

  test "list of maps" do
    assert lower_case_keys([%{"NAME" => "Zainu"}]) == [%{"name" => "Zainu"}]

    assert lower_case_keys([%{
            "NAME" => "Khaja Muzaffaruddin",
            "agE" => 2,
          }, %{}]) == [%{"age" => 2, "name" => "Khaja Muzaffaruddin"}, %{}]
  end

  test "nested list of maps" do
    assert lower_case_keys(%{
                             "JUlian" => [%{"Movie" => "Madagascar"}]
                           }) == %{"julian" => [%{"movie" => "Madagascar"}]}
  end

  test "deeply nested list of maps" do
    assert lower_case_keys(%{"MovieGenres" => [%{
                             "JUlian" => [%{"Movie" => "Madagascar"}]
                           }, %{"Ho" => 33}], "OK then" => "little story"}) == %{
    "moviegenres" => [%{"julian" => [%{"movie" => "Madagascar"}]}, %{"ho" => 33}], "ok then" => "little story"
  }
  end
end
```
