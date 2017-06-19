title: Performance variations of string substitution in Elixir
date: 2017-06-19 17:16:19
tags:
- Elixir
- Bench
- Perf
- String
---

I had to do some string stripping in one of my apps which was a bit performance sensitive.
I ended up benching multiple approaches to see the speed differences. The results are *not that suprising*.

```elixir

path = "/haha/index.html"
subdomain_rx = ~r(^\/[^\/]+)

Benchee.run(%{
  "pattern_match_bytes" => fn ->
    len = byte_size("/haha")
    <<_::bytes-size(len), rest :: binary >> = path
    rest
  end,
  "pattern_match" => fn -> "/haha" <> rest = path; rest end,
  "slice" => fn -> String.slice(path, String.length("/haha")..-1) end,
  "replace_prefix" => fn -> String.replace_prefix(path, "/haha", "") end,
  "split" => fn -> String.splitter(path, "/") |> Enum.drop(1) |> Enum.join("/") end,
  "regex" => fn -> String.replace(path, subdomain_rx, "") end,
})

```



### output of benchee

```
bench [master] $ mix run lib/bench.exs
Operating System: Linux
CPU Information: Intel(R) Core(TM) i7-4700MQ CPU @ 2.40GHz
Number of Available Cores: 8
Available memory: 12.019316 GB
Elixir 1.4.4
Erlang 20.0-rc2
Benchmark suite executing with the following configuration:
warmup: 2.00 s
time: 5.00 s
parallel: 1
inputs: none specified
Estimated total run time: 42.00 s


Benchmarking pattern_match...
Warning: The function you are trying to benchmark is super fast, making measures more unreliable! See: https://github.com/PragTob/benchee/wiki/Benchee-Warnings#fast-execution-warning

You may disable this warning by passing print: [fast_warning: false] as configuration options.

Benchmarking pattern_match_bytes...
Warning: The function you are trying to benchmark is super fast, making measures more unreliable! See: https://github.com/PragTob/benchee/wiki/Benchee-Warnings#fast-execution-warning

You may disable this warning by passing print: [fast_warning: false] as configuration options.

Benchmarking regex...
Benchmarking replace_prefix...
Warning: The function you are trying to benchmark is super fast, making measures more unreliable! See: https://github.com/PragTob/benchee/wiki/Benchee-Warnings#fast-execution-warning

You may disable this warning by passing print: [fast_warning: false] as configuration options.

Benchmarking slice...
Benchmarking split...

Name                          ips        average  deviation         median
pattern_match_bytes       24.05 M      0.0416 μs  ±1797.73%      0.0300 μs
pattern_match             22.37 M      0.0447 μs  ±1546.59%      0.0400 μs
replace_prefix             3.11 M        0.32 μs   ±204.05%        0.22 μs
slice                      1.25 M        0.80 μs  ±6484.21%        1.00 μs
split                      0.75 M        1.34 μs  ±3267.35%        1.00 μs
regex                      0.42 M        2.37 μs  ±1512.77%        2.00 μs

Comparison: 
pattern_match_bytes       24.05 M
pattern_match             22.37 M - 1.08x slower
replace_prefix             3.11 M - 7.73x slower
slice                      1.25 M - 19.30x slower
split                      0.75 M - 32.18x slower
regex                      0.42 M - 57.00x slower
```

**So, the next time you want to strip prefixing stuff, use pattern matching :)**
