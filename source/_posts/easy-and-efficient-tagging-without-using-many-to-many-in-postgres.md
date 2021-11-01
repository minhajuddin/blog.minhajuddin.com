title: Easy and efficient tagging without using string arrays in Postgres
date: 2020-05-17 04:48:39
tags:
- Postgres
- Tagging
- Tags
- Many to Many
- Elixir
- Ruby
- Rails
- Ecto
- Array
---

In a [previous post, we looked at how to do tagging properly using Ecto and
Phoenix](https://minhajuddin.com/2020/05/03/many-to-many-relationships-in-ecto-and-phoenix-for-products-and-tags/).
It is a pretty involved approach, However, postgresql is an amazing database and
has a lightweight approach to tagging which can take you all the way!

We are going to take the same example as our previous post where we are building
a blogging engine which allows creation of posts and each post can have multiple
tags and a tag can be present on multiple posts. Before we move on, you need to
know that postgresql has a few complex data types for columns a few of these
are:

1. json
2. jsonb
3. hstore
4. arrays

Our focus on this blog post will be the array type, specifically an array of
strings. Here is what our database table creation sql would look like:

```
create table posts (
id serial primary key,
title varchar,
body text,
tags varchar[]
    )
```

```
minhajuddin=# \d posts
                                   Table "public.posts"
┌────────┬─────────────────────┬───────────┬──────────┬───────────────────────────────────┐
│ Column │        Type         │ Collation │ Nullable │              Default              │
├────────┼─────────────────────┼───────────┼──────────┼───────────────────────────────────┤
│ id     │ integer             │           │ not null │ nextval('posts_id_seq'::regclass) │
│ title  │ character varying   │           │          │                                   │
│ body   │ text                │           │          │                                   │
│ tags   │ character varying[] │           │          │                                   │
└────────┴─────────────────────┴───────────┴──────────┴───────────────────────────────────┘
Indexes:
    "posts_pkey" PRIMARY KEY, btree (id)

```

~ Arrays have a one-based numbering convention which means first element is
`arr[1]`

~ explain analyze after creating an index and before creating an index
~ concatenate to an array using SQL

~ Do it in raw sql first.

~ Do it in Elixir (Blog post#2)
~ Proper search on tags (Proper index, full text search?) performance
comparison?
~ Create a view containing all tags for a user
~ How to do this in Activerecord, Rails (Blog post#3)




    ```
    resources "/notes", NoteController
    ```
    ```
$ mix phx.gen.html Notes Note notes title:string body:text tags:array:string
    ```
    
    ~ using ANY donest make use of the index
    
book_dev=# explain ANALYZE select * from notes where tags @> ARRAY['tag-100']::varchar[];
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   QUERY PLAN                                                    │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Bitmap Heap Scan on notes  (cost=12.39..118.46 rows=50 width=92) (actual time=0.025..0.025 rows=1 loops=1)      │
│   Recheck Cond: (tags @> '{tag-100}'::character varying[])                                                      │
│   Heap Blocks: exact=1                                                                                          │
│   ->  Bitmap Index Scan on notes_tags_index  (cost=0.00..12.37 rows=50 width=0) (actual time=0.019..0.019 rows=…│
│…1 loops=1)                                                                                                      │
│         Index Cond: (tags @> '{tag-100}'::character varying[])                                                  │
│ Planning Time: 0.087 ms                                                                                         │
│ Execution Time: 0.046 ms                                                                                        │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
(7 rows)

Time: 0.461 ms



book_dev=# explain ANALYZE select * from notes where tags @> ARRAY['tag-100']::varchar[];
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   QUERY PLAN                                                    │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Bitmap Heap Scan on notes  (cost=12.39..118.46 rows=50 width=92) (actual time=0.025..0.025 rows=1 loops=1)      │
│   Recheck Cond: (tags @> '{tag-100}'::character varying[])                                                      │
│   Heap Blocks: exact=1                                                                                          │
│   ->  Bitmap Index Scan on notes_tags_index  (cost=0.00..12.37 rows=50 width=0) (actual time=0.019..0.019 rows=…│
│…1 loops=1)                                                                                                      │
│         Index Cond: (tags @> '{tag-100}'::character varying[])                                                  │
│ Planning Time: 0.087 ms                                                                                         │
│ Execution Time: 0.046 ms                                                                                        │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
(7 rows)

Time: 0.461 ms
book_dev=# explain ANALYZE select * from notes where 'fale' = any(tags);
┌───────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                            QUERY PLAN                                             │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Seq Scan on notes  (cost=0.00..379.00 rows=50 width=92) (actual time=2.830..2.830 rows=0 loops=1) │
│   Filter: ('fale'::text = ANY ((tags)::text[]))                                                   │
│   Rows Removed by Filter: 10000                                                                   │
│ Planning Time: 0.054 ms                                                                           │
│ Execution Time: 2.847 ms                                                                          │
└───────────────────────────────────────────────────────────────────────────────────────────────────┘
(5 rows)

Time: 3.167 ms
book_dev=#
