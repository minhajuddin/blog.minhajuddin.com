title: How to know which of the Enum functions to use in Elixir
date: 2020-07-18 09:36:39
tags:
- Enum
- Functional Programming
- map
- reduce
- filter
---

When you are writing functional code, it is sometimes difficult to figure out
which of the `Enum` functions you want to use. Here are a few common use cases.

## Use `Enum.map`
You can use `Enum.map` when you want to *transform* a set of elements into
another set of elements. Also, note that the count of elements remains
unchanged. So, if you transform a list of 5 elements using `Enum.map`, you get
an output list containing exactly 5 elements, However, the shape of the elements
might be different.

### Examples
```elixir
# transform names into their lengths
iex> Enum.map(["jack", "mujju", "danny boy"], fn x -> String.length(x) end)
[4, 5, 9]
```

If you look at the count of input and output elements it remains the same,
However, the shape is different, the input elements are all strings whereas the
output elements are all numbers.

```elixir
# get ids of all users from a list of structs
iex> Enum.map([%{id: 1, name: "Danny"}, %{id: 2, name: "Mujju"}], fn x -> x.id end)
[1, 2]
```
In this example we transform a list of maps to a list of numbers.


## Use `Enum.filter`
When you want to whittle down your input list, use `Enum.filter`, Filtering
doesn't change the shape of the data, i.e. you are not transforming elements,
and the shape of the input data will be the same as the shape of the output
data. However, the count of elements will be different, to be more precise it
will be lesser or the same as the input list count.

### Examples
```elixir
# filter a list to only get names which start with `m`
iex> Enum.filter(["mujju", "danny", "min", "moe", "boe", "joe"], fn x -> String.starts_with?(x, "m") end)
["mujju", "min", "moe"]
```
The shape of data here is the same, we use a list of strings as the input and
get a list of strings as an output, only the count has changed, in this case, we
have fewer elements.

```elixir
# filter a list of users to only get active users
iex> Enum.filter([%{id: 1, name: "Danny", active: true}, %{id: 2, name: "Mujju", active: false}], fn x -> x.active end)
[%{active: true, id: 1, name: "Danny"}]
```
In this example too, the shape of the input elements is a map (user) and the
shape of output elements is still a map.


## Use `Enum.reduce`
The last of the commonly used `Enum` functions is `Enum.reduce` and it is also
one of the most powerful functions. You can use `Enum.reduce` when you need to
change the shape of the input list into something else, for instance a `map` or a
`number`.


### Examples

Change a list of elements into a number by computing its product or sum

```elixir
iex> Enum.reduce(
  _input_enumberable = [1, 2, 3, 4],
  _start_value_of_acc = 1,
  fn x, acc -> x * acc end)
24

iex> Enum.reduce(
  _input_list = [1, 2, 3, 4],
  _start_value_of_acc = 0,
  fn x, acc -> x + acc end)
10
```

`Enum.reduce` takes three arguments, the first is the input enumerable, which is
usually a list or map, the second is the starting value of the accumulator and
the third is a function which is applied for each element
**whose result is then sent to the next function application as the accumulator**.

Let's try and understand this using an equivalent javascript example.

```javascript

// input list
const inputList = [1, 2, 3, 4]

// starting value of accumulator, we want to chose this wisely, for instance
// when we want addition, we should use a `0` as the start value to avoid
// impacting the output and if you want to compute a product we use a `1`, this
// is usually called the identity element for the function: https://en.wikipedia.org/wiki/Identity_element
// It is also the value that is returned when the input list is empty
let acc = 0

// loop over all the input elements and for each element compute the new
// accumulator as the sum of the current accumulator and the current element
for(const x of inputList) {
  // compute the next value of our accumulator, in our Elixir code this is
  // done by the third argument which is a function which gets `x` and `acc`
  acc = acc + x
}

// in Elixir, the final value of the accumulator is returned
```

Let's look at another example of converting an employee list into a map
containing an employee id and their name.

```elixir
iex> Enum.reduce(
  _input_list = [%{id: 1, name: "Danny"}, %{id: 2, name: "Mujju"}],
  _start_value_of_acc = %{},
  fn x, acc -> Map.put(acc, x.id, x.name) end)

%{1 => "Danny", 2 => "Mujju"}
```

So, in a map you end up reducing an input list into one output value.
