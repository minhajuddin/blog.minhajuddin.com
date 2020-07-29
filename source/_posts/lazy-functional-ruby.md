title: Lazy functional ruby
date: 2020-07-29 07:55:10
tags:
  - lazy
  - functional
  - ruby
---

Today, I was working with some ruby code that had to find the first product in
one of the current contexts. Here is the code:

```ruby
def find_product_in_current_contexts
  context_ids = [1, 2, 3]

  context_ids.each do |context_id|
    product = Product.find_by(context_id: context_id)
    return product if product
  end
end
```

This code tries to find the first product in the current contexts in the order
they are defined. However, the above code has a tiny bug. Can you figure out
what it is?

In cases where there are no products in any of the contexts this function
returns the array `[1, 2, 3]` instead of returning `nil` because `Array.each`
returns the array and in the case where we don't find the product we don't
return early.

We can easily fix this by adding an extra return at the end of the function.

```ruby
def find_product_in_current_contexts
  context_ids = [1, 2, 3]

  context_ids.each do |context_id|
    product = Product.find_by(context_id: context_id)
    return product if product
  end

  # if it reaches this point we haven't found a product
  return nil
end
```

The fix is awkward, let us see if we can improve this.

We could use `.map` to find a product for every context and return the first not
`nil` record like so:

```ruby
def find_product_in_current_contexts
  context_ids = [1, 2, 3]

  context_ids
    .map { |context_id| Product.find_by(context_id: context_id)}
    .find{|x| x }
end
```

This looks much cleaner! And it doesn't have the previous bug either. However,
this code is not efficient, we want to return the first product we find for all
the contexts, and the above code always looks in all contexts even if it finds a
product for the first context. We need to be lazy!

## Lazy enumerator for the win!

Calling `.lazy` on an enumerable gives you a lazy enumerator and the neat thing
about that is it only executes the chain of functions as many times as needed.

Here is a short example which demonstrates its use:

```ruby
def find(id)
  puts "> finding #{id}"
  return :product if id == 2
end

# without lazy
(1..3).map{|id| find(id)}.find{|x| x}
# > finding 1
# > finding 2
# > finding 3
# => :product

# The above `.map` gets executed for every element in the range every time!


# using the lazy enumerator
(1..3).lazy.map{|id| find(id)}.find{|x| x}
# > finding 1
# > finding 2
# => :product
```

As you can see from the above example, the lazy enumerator executes only as many
times as necessary. Here is another example from the ruby docs, to drive the
point home:

```ruby
irb> (1..Float::INFINITY).lazy.select(&:odd?).drop(10).take(2).to_a
# => [21, 23]
# Without the lazy enumerator, this would crash your console!
```

Now applying this to our code is pretty straightforward, we just need to add a
call to `#.lazy` before we map and we are all set!

```ruby
def find_product_in_current_contexts
  context_ids = [1, 2, 3]

  context_ids
    .lazy # this gives us the lazy enumerator
    .map { |context_id| Product.find_by(context_id: context_id)}
    .find{|x| x }
end
```

Ah, nice functional ruby!
