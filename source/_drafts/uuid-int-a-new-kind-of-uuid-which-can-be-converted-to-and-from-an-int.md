title: 'uuid_int: A new kind of uuid which can be converted to and from an int'
date: 2018-12-23 17:37:23
tags:
- UUID
- Int
- uuid_int
---

I ran into an interesting problem at my work where we are transitioning all
our ids to UUIDs. And our current primary keys are stored as auto incrementing
integers. This seemed like a common problem which should have been solved by a
lot of other folks but I couldn't find a good working solution, so here is my
take on it:

A UUID is really a 16 byte binary value which is usually encoded using hex. An
example of a uuid encoded as hex is `2862e397-d3ce-4d6a-a5ff-b20779f43230` which
is really one way to represent the following bytes:
`40, 98, 227, 151, 211, 206, 77, 106, 165, 255, 178, 7, 121, 244, 50, 48`.

## Left padding with zeros

With this knowledge, all we need to convert an integer to a uuid is pad it
to 16 bytes. A typical int is 4 bytes long and a big int is 8 bytes long. Let us
pad a few ints with zeros and look at their hex representations.

Here is an elixir version of the padder in Elixir:

```elixir
def pad_int32(int32) do
  <<
    0::size(12)-unit(8), # 0's padded for the first 12 bytes
    int32::size(4)-unit(8)
  >>
  |> Ecto.UUID.load # Use the ecto library to convert this into a hex representation
end

def pad_int64(int64) do
  <<
    0::size(8)-unit(8), # 0's padded for the first 12 bytes
    int32::size(8)-unit(8)
  >>
  |> Ecto.UUID.load # Use the ecto library to convert this into a hex representation
end
```

```
int32       ===> hex representation of the UUID
841413853   ===> 00000000-0000-0000-0000-00003226f4dd
3239930114  ===> 00000000-0000-0000-0000-0000c11d6902
896897640   ===> 00000000-0000-0000-0000-000035759268
3984706223  ===> 00000000-0000-0000-0000-0000ed81caaf
2621717637  ===> 00000000-0000-0000-0000-00009c443c85


int64                 ===> hex representation of the UUID
1973874164639048025   ===> 00000000-0000-0000-1b64-9c183ea1a159
6764766640840646298   ===> 00000000-0000-0000-5de1-476b27b81e9a
354964277050654748    ===> 00000000-0000-0000-04ed-1621198ec01c
15357724167905241994  ===> 00000000-0000-0000-d521-98c3126c6b8a
12609305280280912604  ===> 00000000-0000-0000-aefd-40586f99e2dc

```

This may be all you need. However, If you have an index on these keys or if you
use these keys to shard your database you'll run into hot partitions where a few
of your shards will have all the data and you don't have an even distribution
across shards.

## Prefixing an MD5 sum to your UUIDs

This is a simple way of adding predictable randomness to your integer to UUID
conversion
