title: How to do batch updates in postgresql for really big updates
date: 2020-10-17 08:30:53
tags:
- psql
- postgresql
- batch
- update
- row_number
- temp table
---

So, you have a ton of records to update in a really large table. Say, you need
to update 3 million records in a table with 100 million rows. And, let's also
assume that you have a way of finding these records. Even, with all of this
info, updating 3M records in a single transaction is troublesome if your table
is being used moderately during this data fix. You have a high probability of
running into a deadlock or your query timing out.

There is a way you can do this by updating your data in small batches. The idea
is to first find the ids of the records you want to update and then updating a
small batch of them in each transaction.

For our example, let us say we have a `users` table which has 3M records created
in the year 2019 whose authentication token needs to be reset. Simple enough!

## 1. Doing this in a single update

Doing this in a single update is the easiest and is possible if you don't use
this table a lot. However, as I said, it is prone to deadlocks and statement
timeouts.

```sql
UPDATE users
SET authentication_token = encode(gen_random_bytes(32), 'base64')
WHERE created_at BETWEEN '2019-01-01' AND '2019-12-31'
```

### 2. Doing this in multiple batches through a CTE

Doing this through a CTE in multiple batches works, but is not the most
efficient.

```sql
-- first get all the records that you want to update by using rolling OFFSETs
-- and limiting to a nice batch size using LIMIT
WITH users_to_be_updated (
  SELECT id
  FROM users
  WHERE created_at BETWEEN '2019-01-01' AND '2019-12-31'
  LIMIT 1000
  OFFSET 0
  ORDER BY id
)
UPDATE users u
SET authentication_token = encode(gen_random_bytes(32), 'base64')
FROM users_to_be_updated utbu
WHERE utbu.id = u.id
```

That works. However, it is not the most efficient update. Because, for every
batch, (in this example a batch of 1000) we perform the filtering and ordering
of all the data. So, we end up making the same query 3M/1K or 3000 times. Not
the most efficient use of our database resources!

### 3.1. Doing this in multiple batches using a temporary table 
So, to remove the inefficiency from the previous step, we can create a temporary table to
store the filtered user ids while we update the records. Also, since this is a
temp table, it is discarded automatically once the session finishes.

```sql
CREATE TEMP TABLE users_to_be_updated AS
  SELECT ROW_NUMBER() OVER(ORDER BY id) row_id, id
  FROM users
  WHERE created_at BETWEEN '2019-01-01' AND '2019-12-31';
  
CREATE INDEX ON users_to_be_updated(row_id);

UPDATE users u
SET authentication_token = encode(gen_random_bytes(32), 'base64')
FROM users_to_be_updated utbu
WHERE utbu.id = u.id
AND utbu.row_id > 0 AND utbu.row_id  <= 1000
```

So, in the above SQL we are creating a temporary table containing a row_id which
is a serial number going from 1 to the total number of rows and also adding an
index on this because we'll be using it in our batch update WHERE clause. And,
finally doing our batch update by selecting the rows from 0..1000 in the first
iteration, 1000..2000 in the second iteration, and so on.

### 3.2. Tying this up via a ruby script to do the full update.

```ruby
# sql_generator.rb
total_count = 3_000_000
batch_size = 10_000

iterations = 1 + total_count / batch_size

puts <<~SQL
-- create our temporary table to avoid running this query for every batch update
CREATE TEMP TABLE users_to_be_updated AS
  SELECT ROW_NUMBER() OVER(ORDER BY id) row_id, id
  FROM users
  WHERE created_at BETWEEN '2019-01-01' AND '2019-12-31';
  
-- create an index on row_id because we'll filter rows by this
CREATE INDEX ON users_to_be_updated(row_id);
SQL

(0..iterations).each do |i|
  start_id = i * batch_size
  end_id = (i + 1) * batch_size
  puts <<~SQL
-- the row below prints out the current iteration which shows us the progress
-- batch: #{i}/#{iterations}

-- start a transaction for this batch update
BEGIN;

-- perform the actual batch update
UPDATE users u
SET authentication_token = encode(gen_random_bytes(32), 'base64')
FROM users_to_be_updated utbu
WHERE utbu.id = u.id
AND utbu.row_id > #{start_id} AND utbu.row_id  <= #{end_id};

-- commit this transaction so that we don't have a single long running transaction
COMMIT;

-- This is optional, sleep for 1 second to stop the database from being overwhelmed.
-- You can tweak this to your desire time based on the resources you have or
-- remove it.
SELECT pg_sleep(1);

SQL

end
```

This tiny script generates a sql file which can then be executed via psql to do
the whole process in one fell swoop.

```bash
# generate the sql file
ruby sql_generator.rb > user_batch_update.sql
```

Once we have the sql file we run it through psql like so

```bash
psql --echo-all --file=user_batch_update.psql "DATABASE_URL"
```

That's all folks, now your updates should be done in batches and shouldn't cause
any deadlocks or statement timeouts.
