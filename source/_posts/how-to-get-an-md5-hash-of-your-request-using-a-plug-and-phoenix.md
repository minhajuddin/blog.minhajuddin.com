title: How to get an MD5 hash of your request using a Plug and Phoenix
date: 2018-11-22 14:42:06
tags:
  - Elixir
  - Phoenix
  - Plug
  - MD5
  - HMAC
  - Sign Request
---

In a recent project, I had to implement idempotent API endpoints in a Phoenix
application. And as a part of this, I had to store the MD5 hash of each request
body along with its idempotency key and other request data. And the latest Plug
makes this easier [thanks to this PR](https://github.com/elixir-plug/plug/pull/698).

So, let us take a step back and see what is required. We want to plug into the
request pipeline, read the body, compute its md5 hash and store it in a private
variable on the connection. Before [Plug
1.5.1](https://github.com/elixir-plug/plug/blob/v1.6/CHANGELOG.md#v151-2018-05-17),
if you wanted to read the requested body you had to duplicate your request
  parsers as they directly read from the connection using `Plug.Conn.read_body`
  which read the content, parsed it and discarded it. If you ended up putting
  your plug before the parsers and read the body, the JSON parser would fail to
  see any request data as the request would already have been read.

To work around this limitation a new option called `body_reader` was added to
the `Plug.Parsers` plug. This allows you to get in the middle of the parser and
the connection and have custom code which can read the request body, cache it
and hand over the request body to the parsers which ends up in a clean
implementation. So, let us take a look at the code that is required to add MD5
hashing to our requests.

The first thing we need is a custom request body reader which can be used by our
parsers. From the example in the Plug documentation, it can be as simple as the
code below:


```elixir
defmodule BodyReader do

  def read_body(conn, opts) do
    # read the body from the connection
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)

    # compute our md5 hash
    md5sum = :crypto.hash(:md5, body) |> Base.encode16()

    # shove the md5sum into a private key on the connection
    conn = Plug.Conn.put_private(conn, :md5sum, md5sum)

    {:ok, body, conn}
  end

end
```

The above module has a `read_body` function which takes a connection, reads
the request body, computes its md5 hash and shoves it into a private key on the
connection and returns the body and connection to the parsers to pass them
along.

Once we have this custom reader, we just need to configure our parsers to use
this by changing our endpoint to have the following code:

```elixir
plug Plug.Parsers,
  parsers: [:urlencoded, :multipart, :json],
  pass: ["*/*"],
  body_reader: {BodyReader, :read_body, []},
  json_decoder: Phoenix.json_library()
```

Once you set this up your actions can access the md5sum of a request using
`conn.private[:md5sum]`. And that is all you need to compute the MD5 sum of your
requests.

The same technique can be used to authenticate webhook requests from [GitHub](https://developer.github.com/webhooks/securing/),
[Dropbox](https://www.dropbox.com/developers/reference/webhooks) and other services which sign their requests with an HMAC key.
