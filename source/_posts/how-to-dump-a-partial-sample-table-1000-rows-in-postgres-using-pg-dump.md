title: How to dump a partial/sample table(1000 rows) in postgres using pg_dump
date: 2019-11-30 00:36:13
tags:
- postgresql
- pg_dump
- limit
- partial table
- sample
---

The other day, I wanted to export a sample of one of my big Postgres tables from
the production server to my local computer. This was a huge table and I didn't
want to move around a few GBs just to get a sample onto my local environment.
Unfortunately `pg_dump` doesn't support exporting of partial tables. I looked
around and found a utility called [pg_sample](https://github.com/mla/pg_sample)
which is supposed to help you with this. However, I wasn't comfortable with
installing this on my production server or letting my production data through
this script. Thinking a little more made the solution obvious. The idea was
simple:

1. Create a table called `tmp_page_caches` where `page_caches` is the table that
   you want to copy using `pg_dump` using the following SQL in `psql`, this
   gives you a lot of freedom on SELECTing just the rows you want.
   ```sql
   CREATE TABLE tmp_page_caches AS (SELECT * FROM page_caches LIMIT 1000);
   ```
2. Export this table using `pg_dump` as below. Here we are exporting the data to
   a sql file and transforming our table name to the original table name
   midstream.
  ```bash
  pg_dump app_production --table tmp_page_caches | sed 's/public.tmp_/public./' > page_caches.sql
  ```
3. Copy this file to the local server using `scp` and now run it against the
   local database:
   ```bash
   scp minhajuddin@server.prod:page_caches.sql .
   psql app_development < page_caches.sql
   ```
4. Get rid of the temporary table on the production server
  ```sql
  DROP TABLE tmp_page_caches; -- be careful not to drop the real table!
  ```

Voila! We have successfully copied over a sample of our production table to our
local environment. Hope you find it useful.
