title: Pearls of Elixir - Interesting patterns from popular Elixir packages
date: 2019-02-01 09:11:16
tags:
- Pearls
- Elixir
---

I had a wonderful time giving a talk at the [Elixir January Tech Meetup](https://www.meetup.com/TorontoElixir/events/258157474/)
here in Toronto. Big thanks to [Mattia](https://twitter.com/ghedamat) for organizing and [PagerDuty](https://twitter.com/pagerduty) for
hosting the meetup!

I wanted to capture the talk in a blog post and here it is.

## 1. Canada
Many of us have used cancan for authorization in our Rails applications. When
I was searching for a similar package in Elixir, I found the awesome [canada](https://github.com/jarednorman/canada)
package.

It's DSL is pretty straightforward

```elixir
# In this example we have a User and a Post entity.
defmodule User do
  defstruct id: nil, name: nil, admin: false
end

defmodule Post do
  defstruct user_id: nil, content: nil
end

# Followed by a protocol definition which allows you to define the rules on what
# is allowed and what is forbidden.

defimpl Canada.Can, for: User do
  def can?(%User{id: user_id}, action, %Post{user_id: user_id})
    when action in [:update, :read, :destroy, :touch], do: true

  def can?(%User{admin: admin}, action, _)
    when action in [:update, :read, :destroy, :touch], do: admin

  def can?(%User{}, :create, Post), do: true
end

# Finally, when we want to use this we just use the following syntax which reads
# very nicely.

import Canada, only: [can?: 2]

if some_user |> can? read(some_post) do
  # render the post
else
  # sorry (raise a 403)
end
```

When using packages, I try to take a peek at the source code and
understand how things work. And, I was *schocked* when I saw just 10 lines of
code in the `lib` folder! See for yourself:

```elixir
# lib/canada.ex
defmodule Canada do
  defmacro can?(subject, {action, _, [argument]}) do
    quote do
      Canada.Can.can? unquote(subject), unquote(action), unquote(argument)
    end
  end
end

# lib/canada/can.ex
defprotocol Canada.Can do
  @doc "Evaluates permissions"
  def can?(subject, action, resource)
end
```

The protocol is what allows you to define your custom rules for authorization
and the `Canada` module defines a neat little macro which allows you to test if
a *user* is authorized to perform an *action* using syntax like: `can? user,
read(post)`. How cool is that!

# 2. Readable binary match specs
Postgrex is another one of those packages which is filled with neat Elixir code.
When I was skimming through the code, I ran into a piece of code which surprised
me:

```elixir
defmodule Postgrex.BinaryUtils do
  @moduledoc false

  defmacro int64 do
    quote do: signed-64
  end

  # ...

  defmacro uint16 do
    quote do: unsigned-16
  end

end
```

I was having a difficult time understanding how `signed-64` could be valid
Elixir code. I quickly spun up an iex console and typed in `signed-64` and
unsurprisingly it threw an error. Upon further searching I found that this was
actually used in binary pattern matches all over the code:

```elixir
defmodule Postgrex.Messages do
  import Postgrex.BinaryUtils
  # ....
  def parse(<<type :: int32, rest :: binary>>, ?R, size) do
  # ....

  def parse(<<pid :: int32, key :: int32>>, ?K, _size) do
  # ....
end
```

So, the macro `int32` would actually be spliced inside of a binary pattern
match. I would never have thought of doing this! And it makes the code so much
more readable and easy to follow.

# 3. Compiling lookup tables in Modules
While browsing through postgrex, I found a text file called `errcodes.txt` which
I thought was a bit strange. Here is a snippet of that file:

```
#
# errcodes.txt
#      PostgreSQL error codes
#
# Copyright (c) 2003-2015, PostgreSQL Global Development Group

# ...

Section: Class 00 - Successful Completion

00000    S    ERRCODE_SUCCESSFUL_COMPLETION                                  successful_completion

Section: Class 01 - Warning

# do not use this class for failure conditions
01000    W    ERRCODE_WARNING                                                warning
0100C    W    ERRCODE_WARNING_DYNAMIC_RESULT_SETS_RETURNED                   dynamic_result_sets_returned
01008    W    ERRCODE_WARNING_IMPLICIT_ZERO_BIT_PADDING                      implicit_zero_bit_padding
01003    W    ERRCODE_WARNING_NULL_VALUE_ELIMINATED_IN_SET_FUNCTION          null_value_eliminated_in_set_function
01007    W    ERRCODE_WARNING_PRIVILEGE_NOT_GRANTED                          privilege_not_granted
01006    W    ERRCODE_WARNING_PRIVILEGE_NOT_REVOKED                          privilege_not_revoked
01004    W    ERRCODE_WARNING_STRING_DATA_RIGHT_TRUNCATION                   string_data_right_truncation
01P01    W    ERRCODE_WARNING_DEPRECATED_FEATURE                             deprecated_feature

# ...

```

This file maps error codes to their symbols. The reason this was in the `lib`
folder was because it was supposed to be used as a source for error codes
mapping. Upon further reading I found that this was being used in a module
called `Postgrex.ErrorCode`. Here are the interesting pieces of that module:

```elixir
defmodule Postgrex.ErrorCode do
  @external_resource errcodes_path = Path.join(__DIR__, "errcodes.txt")

  errcodes = for line <- File.stream!(errcodes_path),
             # ...

  # errcode duplication removal

  # defining a `code_to_name` function for every single error code which maps
  # the code to a name.
  for {code, errcodes} <- Enum.group_by(errcodes, &elem(&1, 0)) do
    [{^code, name}] = errcodes
    def code_to_name(unquote(code)), do: unquote(name)
  end
  def code_to_name(_), do: nil

end
```

This code file uses our errorcodes text file to define around 400 functions which
embed the actual code to name mapping. And whenever you wanted to do the actual lookup you could just use
`Postgrex.ErrorCode.code_to_name(error_code)`

{% asset_img blow-my-mind.gif %}

# 4. Validating UUIDs

Did you know that you don't need the `uuid` package to generate UUIDs? UUID
generation is available in Ecto as part of the `Ecto.UUID` module. And it even
has a function which allows you to validate a UUID. Most of us would quickly
reach for a regex pattern to validate a UUID, However, the Ecto library uses an
interesting approach:


```elixir
defmodule Ecto.UUID do

  @doc """
  Casts to UUID.
  """
  @spec cast(t | raw | any) :: {:ok, t} | :error
  def cast(<< a1, a2, a3, a4, a5, a6, a7, a8, ?-,
              b1, b2, b3, b4, ?-,
              c1, c2, c3, c4, ?-,
              d1, d2, d3, d4, ?-,
              e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12 >>) do
    << c(a1), c(a2), c(a3), c(a4),
       c(a5), c(a6), c(a7), c(a8), ?-,
       c(b1), c(b2), c(b3), c(b4), ?-,
       c(c1), c(c2), c(c3), c(c4), ?-,
       c(d1), c(d2), c(d3), c(d4), ?-,
       c(e1), c(e2), c(e3), c(e4),
       c(e5), c(e6), c(e7), c(e8),
       c(e9), c(e10), c(e11), c(e12) >>
  catch
    :error -> :error
  else
    casted -> {:ok, casted}
  end
  def cast(<< _::128 >> = binary), do: encode(binary)
  def cast(_), do: :error

  @compile {:inline, c: 1}

  defp c(?0), do: ?0
  defp c(?1), do: ?1
  defp c(?2), do: ?2
  defp c(?3), do: ?3
  defp c(?4), do: ?4
  defp c(?5), do: ?5
  defp c(?6), do: ?6
  defp c(?7), do: ?7
  defp c(?8), do: ?8
  defp c(?9), do: ?9
  defp c(?A), do: ?a
  defp c(?B), do: ?b
  defp c(?C), do: ?c
  defp c(?D), do: ?d
  defp c(?E), do: ?e
  defp c(?F), do: ?f
  defp c(?a), do: ?a
  defp c(?b), do: ?b
  defp c(?c), do: ?c
  defp c(?d), do: ?d
  defp c(?e), do: ?e
  defp c(?f), do: ?f
  defp c(_),  do: throw(:error)

end

```

This code is pretty self explanatory and is a *literal* translation of how you
would validate a UUID using a pen and paper.

# 5. Honorable Mentions

### Static struct assertions/checks in functions

With Elixir you can assert that the argument your function receives is of a
specific type by using a pattern like below:

```elixir
defmodule User do
  def authorized?(%User{} = user) do
    # ....
  end
end
```

This code would blow up if the argument passed was not a `User` struct. This is
a nice way of asserting the type. However, you can overdo this by using it
everywhere. A good rule of thumb is to use this pattern in your public API at
the periphery where data comes in.

### Tagged with blocks

You can wrap your `with` matches in tagged tuples like below if you want to
handle errors differently for different failures.

```elixir
with {:parse, {:ok, user_attrs}} <- {:parse, Jason.parse(body)},
     {:persist, {:ok, user}} <- {:persist, Users.create(user_attrs)},
     {:welcome_email, :ok} <- {:welcome_email, Emailer.welcome(user)} do
     :ok
else
  {:parse, err} ->
    # raise an error
    {:error, :parse_error}
  {:persist, {:error, changeset}} ->
    # return validation errors
    {:error, changeset}
  {:welcome_email, err} ->
    # it is ok if email sending failed, we just log this
    Logger.error("SENDING_WELCOME_EMAIL_FAILED")
    :ok
end
```

### Delegating function calls on your root API module

`defdelegate` allows you to delegate function calls to a different module using
the same arguments.

```elixir
defmodule API do
  defdelegate create_customer(customer_json), to: API.CustomerCreator
end

defmodule API.CustomerCreator do
  def create_customer(customer_json) do
    # ...
  end
end
```

### Enforcing Keys

While defining a struct you can also define which keys are mandatory.

```elixir
defmodule User do
  @enforce_keys [:email, :name]
  defstruct [:email, :name]
end
```

### Interpolation in docs

```elixir
defmodule HTTPClient do
  @timeout 60_000
  @doc """
  Times out after #{@timeout} seconds
  """
  def get(url) do
  end
end
```

### Suppressing logs in your tests

```elixir
ExUnit.start

defmodule HTTPTest do
  use ExUnit.Case
  require Logger

  @moduletag :capture_log

  test "suppress logs" do
    Logger.info "AAAAAAAAAAAAAAAAAAAHHHHHHHHH"
  end
end
```

### Links

- [Canada](https://github.com/jarednorman/canada)
- [Postgrex.BinaryUtils](https://github.com/elixir-ecto/postgrex/blob/master/lib/postgrex/binary_utils.ex)
- [Postgrex.ErrorCode](https://github.com/elixir-ecto/postgrex/blob/master/lib/postgrex/error_code.ex)
- [Ecto.UUID](https://github.com/elixir-ecto/ecto/blob/master/lib/ecto/uuid.ex)
