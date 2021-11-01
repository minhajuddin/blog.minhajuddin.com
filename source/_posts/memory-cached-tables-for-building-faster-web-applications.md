title: Memory Cached Tables for building faster web applications
date: 2021-10-31 21:29:22
tags:
- Memory Cached Tables
- Speed
- Performance
- Elixir
- Ruby
- Python
- Web apps
- Fast
- Lookup tables
---

Most web apps have a few small tables which don't change a lot but are read a
lot from, tables like `settings` or `plans` or `products` (some apps have less than 1000
products). You can do a quick size check of your tables by running the following
query:

```sql
-- https://stackoverflow.com/a/21738732/24105
SELECT
  pg_catalog.pg_namespace.nspname AS schema_name,
  relname,
  pg_size_pretty(pg_relation_size(pg_catalog.pg_class.oid)) AS tablesize
FROM pg_catalog.pg_class
INNER JOIN pg_catalog.pg_namespace ON relnamespace = pg_catalog.pg_namespace.oid
WHERE pg_catalog.pg_namespace.nspname = 'public' AND pg_catalog.pg_class.reltype
<> 0 AND relname NOT LIKE '%_id_seq'
ORDER BY 3 DESC;
```

At this point you need to decide how much memory in your app you can allocate
for these lookup tables. In my experience for a moderately sized app you could
go as high as 100MB tables. Make sure you add some metrics and benchmark
this before and after doing any optimiztions.

Say you have 4 tables which are small enough to fit in memory, and which you
read a lot from, the first thought that comes to mind is to use caching, and
when someone says caching you reach for redis or memcache or some other network
service. I would ask you to stop and think at this point, How would you cache
in a way that is faster than redis or memcache?

Once you ask that question, the answer becomes obvious, you cache things in your
app's memory, if you have any data in your app's memory you can just reach for
it. Read this [excellent gist to get a sense of the latency of different kinds of storage strategies](https://gist.github.com/jboner/2841832).

When using your app's memory you don't have to pay the network cost plus the
serialization/deserialization tax. Everytime you cache something in redis or
memcached, your app has to make a network call to these services and push out a
serialized version of the data while saving it and do the opposite while reading
it. This cost adds up if you do it on every page load.

I work with an app which keeps a website maintenance flag in memcache and this
ends up adding 30ms to every request that hits our servers. There is a better
way! Move your settings to your app's memory. This can easily be done by
defining something like below(in ruby):

```ruby
# config/initializers/settings.rb
$settings_hash = Setting.all.map{|x| [x.key, x]}.to_h
module Settings
  module_function

  def find(key)
    $settings_hash[key]
  end
end
```

However, as they say one of the two hard problems in computer science is cache
invalidation. What do you do when your data changes? This is the hard part.

## Just restart it!
The easiest strategy for this is to restart the server. This might be a
perfectly valid strategy. We do restart our apps when config values change, so
restarting for lookup tables with low frequency changes is a fair strategy.

## Poll for changes
If that doesn't work for your app because your lookup data changes frequently,
let us say every 5 minutes, another strategy is to poll for this data. The
idea is simple:

1. You load your data into a global variable.
2. You poll for changes in a separate thread using something like
   [suckerpunch](https://github.com/brandonhilkert/sucker_punch#executing-jobs-in-the-future)
   in ruby and
   [APScheduler](https://viniciuschiele.github.io/flask-apscheduler/rst/usage.html)
   in python.

### Content hash of your table
Fortunately there is an easy way to see if there is any change on a table in
postgres, aggregate the whole table into a single text column and then compute
the md5sum of it. This should change any time there is a change to the data.

```sql
SELECT
    /* to avoid random sorting */
    MD5(CAST((ARRAY_AGG(t.* ORDER BY t)) AS text)) content_hash
FROM
settings t;
```

Output of this query
```
┌──────────────────────────────────┐
│           content_hash           │
├──────────────────────────────────┤
│ 337f91e1e09b09e96b3413d27102c761 │
└──────────────────────────────────┘
(1 row)
```

Now, all you do is keep a tab on this content hash every 5 minutes or so and
reload the tables when it changes.

## Use Postgres Subscriptions
Postgres has support for subscriptions, so you could add a mechanism where each
table has a subscription that you push to whenever you modify data using
triggers.
https://www.postgresql.org/docs/10/sql-createsubscription.html

## Use app based pub/sub
If all your changes go through the app through some kind of admin webpage, you
could also add pub/sub to broadcast an update whenever data is modified to which
all your app servers listen to and refresh the data.

Since elixir and erlang are all about concurrency, they lend themselves nicely
to this idiom. Let us see how this can be done in Elixir.

## Manual cache invalidation
You could also build a button on your admin console which just pings a specific
endpoint e.g. `/admin/:table/cache-invalidate` and allow for manual cache
invalidation. The handler for this would just reload the global data.

I feel like the polling strategy is the most robust with the least number of
moving pieces. Please try this out in your app and let me know how this impacts
your performance.

In a future blog post, I'll explain [the elixir implemenation](https://github.com/minhajuddin/memory_cached_tables/blob/main/lib/memory_cached_tables/cached_settings.ex)
