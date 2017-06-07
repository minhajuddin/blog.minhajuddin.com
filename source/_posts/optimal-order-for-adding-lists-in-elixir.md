title: Optimal order for adding lists in Elixir
date: 2017-06-08 00:41:50
tags:
- Elixir
- Lists
- Order
- Concatenate
---

Lists are the bread and butter of a functional language and Elixir is no different.

Elixir uses linked lists to represent lists. Which means, if a list is `n` elements long it will
take `n` dereferences to get to the last element of the list. This understanding is very important
for writing efficient code in Elixir. Because of this adding to the head of a list is nearly instantaneous.


## Adding to the beginning of a list

Let us take the following list as an example:

    el1 -> el2 -> el3 -> el4

It has 4 elements and `el1` is the head of the list. To add a new element `el0`
to the beginning of the list, All you need to do is create a node to store `el0`
and set its `next` pointer to `el1`. This changes the representation to:

    el0 -> el1 -> el2 -> el3 -> el4

Now, one thing to note is: if a previous variable has a reference to `el1` it will
still have a reference to the earlier 4 element list. So, we are not *mutating/chaning* the existing list/references.

## Adding to the end of a list

However, adding something to the end is not the same. Let us take the previous example:

    el1 -> el2 -> el3 -> el4

Now, if this list is referenced by a binding `foo`. And if we want to create a new list `bar` with a new element `el5` at the end.
We can't just traverse the list, create a new node with value `el5` and set a reference from `el4` to `el5`.
If we did that, the reference `foo` would also get a new element at the end. And this is not how Elixir/Erlang work. The BEAM
does not allow mutation to existing data. So, to work within this framework, we have to create a *brand new* list containing
a copy of all elements `el1..el4` and a new node `el5`. That is why adding elements to the tail of a linked list is slow in Elixir.
Because we end up copying the list and appending a new element.

Now, with this understanding. Let us think of the most efficient way of combining two lists when the order of elements doesn't matter.
For instance, when you send http requests using `httpoison` the order of the headers doesn't matter.
So, when you have the following implementations available:

```elixir
# ...

# A: First list is small most of the time
@default_headers [{"content-type", "application/json"}, {"authorization", "Bearer Foo"}, {"accept", "application/json"}]
def get(url, headers \\ []) do
  headers ++ @default_headers
end

# B: Second list is small most of the time
@default_headers [{"content-type", "application/json"}, {"authorization", "Bearer Foo"}, {"accept", "application/json"}]
def get(url, headers \\ []) do
  @default_headers ++ headers
end

# ...
```

Pick the one where the first list has lesser elements. In this example that would be the **A** implementation.

I did a quick benchmark just for kicks (Full code available at https://github.com/minhajuddin/bench_list_cat):

## Benchmark

    Elixir 1.4.4
    Erlang 20.0-rc2
    Benchmark suite executing with the following configuration:
    warmup: 2.00 s
    time: 5.00 s
    parallel: 1
    inputs: none specified
    Estimated total run time: 14.00 s


    Benchmarking big_list_first...
    Benchmarking small_list_first...

    Name                       ips        average  deviation         median
    small_list_first        6.49 K       0.154 ms   ±371.63%      0.0560 ms
    big_list_first       0.00313 K      319.87 ms    ±37.78%      326.10 ms

    Comparison:
    small_list_first        6.49 K
    big_list_first       0.00313 K - 2077.49x slower

## Code used for benchmarking

    small_list = Enum.to_list(1..10_000)
    big_list = Enum.to_list(1..10_000_000)

    Benchee.run(%{
      "small_list_first" => fn -> small_list ++ big_list end,
      "big_list_first" => fn -> big_list ++ small_list end
    })

## Note that this is an outrageous benchmark, no one is adding lists containing 10 million elements this way ;). But it demonstrates my point.
