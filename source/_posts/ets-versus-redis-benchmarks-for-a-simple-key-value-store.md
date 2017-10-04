title: ets versus redis benchmarks for a simple key value store
date: 2017-10-04 16:41:29
tags:
- Elixir
- ets
- Redis
- Benchmark
- Key-Value
---

The project that I am currently working on has a huge data set of static lookup data.
And, we have been using Redis to store this data since the beginning of the project.
We figured, redis would be the fastest as the whole data is in memory.
However, in our production use we have found redis to be the bottleneck.

This is not really redis' fault as the data access pattern that we have involves a huge number of lookups more than 10K lookups per request.
Also, since redis runs on a single core, it isn't able to use all the cores on our server. Add the network costs and the serialization costs to it and things add up very quickly.

This led me to do some benchmarking of redis against ets with our actual production data and (un)surprisingly we found that ets beats Redis for simple key value data.
So, if you are using redis as a key value store. Please do yourself a favor and use ets (If you are using Elixir or erlang).

I created a simple [mix project which benchmarks ets and redis (https://github.com/minhajuddin/redis_vs_ets_showdown)](https://github.com/minhajuddin/redis_vs_ets_showdown)

Go ahead and try it out by tweaking the count of records or the parallelism.

We found that the ets to redis performance gap actually grows as the parallelism increases.

Checkout the repository for the benchmark data: https://github.com/minhajuddin/redis_vs_ets_showdown

You can also check the reports at:

  1. https://minhajuddin.github.io/redis_vs_ets_showdown/reports/benchmark-1000.html
  2. https://minhajuddin.github.io/redis_vs_ets_showdown/reports/benchmark-1000000.html


Here is the gist of the benchmark:

### Quick explanation of names

*ets_get_1000*: does an ets lookup 1000 times

*redis_get_1000*: does a redis lookup 1000 times using `HGET`

*ets_get_multi*: does an ets lookup 1000 times

*redis_get_multi*: does a single `HMGET` Redis lookup

### Benchmark for 1000_000 records

```
Operating System: Linux
CPU Information: Intel(R) Core(TM) i7-4700MQ CPU @ 2.40GHz
Number of Available Cores: 8
Available memory: 12.019272 GB
Elixir 1.5.1
Erlang 20.1
Benchmark suite executing with the following configuration:
warmup: 2.00 s
time: 30.00 s
parallel: 4
inputs: none specified
Estimated total run time: 2.13 min


Name                      ips        average  deviation         median
ets_get_multi          3.31 K        0.30 ms    ±20.60%        0.28 ms
ets_get_1000           2.87 K        0.35 ms    ±75.38%        0.31 ms
redis_get_multi        0.34 K        2.95 ms    ±17.46%        3.01 ms
redis_get_1000       0.0122 K       82.15 ms    ±15.77%       77.68 ms

Comparison:
ets_get_multi          3.31 K
ets_get_1000           2.87 K - 1.15x slower
redis_get_multi        0.34 K - 9.76x slower
redis_get_1000       0.0122 K - 271.91x slower
```

### Benchmark for 1000 records

```
Name                      ips        average  deviation         median
ets_get_multi          4.06 K        0.25 ms    ±12.31%        0.24 ms
ets_get_1000           3.96 K        0.25 ms    ±18.72%        0.23 ms
redis_get_multi        0.34 K        2.90 ms    ±12.34%        2.99 ms
redis_get_1000       0.0115 K       87.27 ms    ±17.31%       81.36 ms

Comparison:
ets_get_multi          4.06 K
ets_get_1000           3.96 K - 1.02x slower
redis_get_multi        0.34 K - 11.78x slower
redis_get_1000       0.0115 K - 354.04x slower
```
