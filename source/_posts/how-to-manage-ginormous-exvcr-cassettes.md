title: How to manage ginormous ExVCR cassettes
date: 2018-06-18 08:39:08
tags:
- ExVCR
- Large
- Cassette
---

[ExVCR](https://github.com/parroty/exvcr) is an awesome elixir package which
helps you create repeatable integration tests. It works by saving the requests
and responses you make to external services, in json files called cassettes. These
cassettes are created the first time you run the tests. Here is an example from
one of my projects:


```elixir
defmodule X.AuthControllerTest do
  use X.ConnCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  test "google redirect creates the user", %{conn: conn} do
    conn =
      use_cassette "google_oauth_challenge" do
        conn
        |> get(
          "/auth/google/callback?code=....................."
        )
      end

    assert ...
    # ...

  end
end
```

The first time I run this test it creates a file at `fixture/vcr_cassettes/google_oauth_challenge.json`.
This contains the request and response data from this test. Now, whenever you rerun
this test it just loads this request and response data and replays the response if the request
matches the saved request. So, your tests will pass even when you don't have network connectivity!

This is all nice as long as you have small responses. However, when you need to do this
for responses whose size is in MBs you run into a few issues:

  1. Your tests become slower.
  2. You don't want to haul around MBs of fixtures in your source control (you must check in the cassettes i.e. the `fixture/` directory).

I recently ran into this situation with one of my projects where I was downloading
a gzipped csv file which was ~50MB. The way I fixed it is:

  1. Let ExVCR record the cassettes with all the large data.
  2. Download the same response from outside using curl.
  3. Take a tiny sample of the response data
  4. Replace the `response.body` in the cassette with my sample response data

This fixes the slow tests and also reduces the size of cassettes.

Another thing to remember is if your response is binary and not a valid string, ExVCR stores it differently.
Its [json serializer](https://github.com/parroty/exvcr/blob/master/lib/exvcr/json.ex#L22) runs binary
data through the following functions

```elixir
response.body
|> :erlang.term_to_binary()
|> Base.encode64()
```

So, if you have gzipped (or any other binary) data, load it into IEx from step *2* above and run it through
the same functions as above and use this data to replace the `response.body`. You can also skip *2*
and use the data from your large cassette before trimming it down by running it through:

```
cassette = File.read!("fixture/vcr_cassettes/cassette.json") |> Poison.decode! |> hd
cassette["response"]["body"]
|> Base.decode64!
|> :erlang.binary_to_term # you'll have the raw response binary data at this point
|> :zlib.gunzip # if your response is gzipped you'll need this to extract the actual data
```

P.S
My editor froze while trying to edit such a large cassette, so I used jq to remove
the large body keys from the response using the following command:

```
jq 'walk(if type == "object" and has("body") then del(.body) else . end)' mycassette.json  > cassette_without_body.json
```

To get the above working you need jq > 1.5 and the following in your `~/.jq`

```
# Apply f to composite entities recursively, and to atoms
def walk(f):
  . as $in
  | if type == "object" then
      reduce keys_unsorted[] as $key
        ( {}; . + { ($key):  ($in[$key] | walk(f)) } ) | f
  elif type == "array" then map( walk(f) ) | f
  else f
  end;
```
