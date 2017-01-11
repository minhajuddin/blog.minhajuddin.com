title: Case insensitive key retrieval from maps in Elixir
date: 2017-01-11 16:27:40
tags:
- Elixir
- Case insensitive
- Map
- Retrieval
---

I ran into an issue with inconsistent naming of keys in one of my provider's json.
This is really bad data quality, the data that is being sent should have consistent key names.
Either uppper, lower, or capitalized, but consistent. Anyway, this provider was sending data will all kinds of mixed case keys.

Here is some elixir code that I wrote to get keys using a case insensitive match.
There is an issue on the [Poison decoder project](https://github.com/devinus/poison/issues/44) which should render this useless, however till that is fixed you can use the code below:

```elixir
defmodule CaseInsensitiveGetIn do
  def ci_get_in(nil, _), do: nil

  def ci_get_in({_k, val}, []), do: val
  def ci_get_in({_k, val}, key), do: ci_get_in val, key

  def ci_get_in(map, [key|rest]) do
    current_level_map = Enum.find(map, &key_lookup(&1, key))
    ci_get_in current_level_map, rest
  end

  def key_lookup({k, _v}, key) when is_binary(k) do
    String.downcase(k) == String.downcase(key)
  end
end

ExUnit.start

defmodule CaseInsensitiveGetInTest do
  use ExUnit.Case
  import CaseInsensitiveGetIn

  test "gets an exact key" do
    assert ci_get_in(%{"name" => "Mujju"}, ~w(name)) == "Mujju"
  end

  test "gets capitalized key in map" do
    assert ci_get_in(%{"Name" => "Mujju"}, ~w(name)) == "Mujju"
  end

  test "gets capitalized input key in map" do
    assert ci_get_in(%{"Name" => "Mujju"}, ~w(Name)) == "Mujju"
  end

  test "gets mixed input key in map" do
    assert ci_get_in(%{"NaME" => "Mujju"}, ~w(nAme)) == "Mujju"
  end

  test "gets an exact deep key" do
    assert ci_get_in(%{"name" => "Mujju", "sister" => %{"name" => "Zainu"}}, ~w(sister name)) == "Zainu"
  end

  test "gets an mixed case deep map key" do
    assert ci_get_in(%{"name" => "Mujju", "sisTER" => %{"naME" => "Zainu"}}, ~w(sister name)) == "Zainu"
  end

  test "gets an mixed case deep key" do
    assert ci_get_in(%{"name" => "Mujju", "sisTER" => %{"naME" => "Zainu"}}, ~w(sIStER NAme)) == "Zainu"
  end

  test "gets a very deep key" do
    map = %{
      "aB" => %{
        "BC" => 7,
        "c" => %{"DD" => :foo, "Cassandra" => :awesome, "MOO" => %{"name" => "Mujju"}}
      }}
    assert ci_get_in(map, ~w(ab bc)) == 7
    assert ci_get_in(map, ~w(ab c dd)) == :foo
    assert ci_get_in(map, ~w(ab c moo name)) == "Mujju"

    assert ci_get_in(map, ~w(ab Bc)) == 7
    assert ci_get_in(map, ~w(ab C dD)) == :foo
    assert ci_get_in(map, ~w(ab C mOo nAMe)) == "Mujju"
  end
end
```
