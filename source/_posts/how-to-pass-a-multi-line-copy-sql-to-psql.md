title: How to pass a multi line copy sql to psql
date: 2017-05-18 14:56:01
tags:
- psql
- Postgresql
- Copy
---

I have been working with a lot of ETL stuff lately and have to import/export data
from our postgresql database frequently.

While writing a script recently, I found that psql doesn't allow using the `\COPY`
directive with a multi line SQL when it is passed to the `psql` command.
The only workaround seemed to be squishing the sql into a single line.
However, this makes it very difficult to read and modify the SQL. This is when bash came to my rescue :)

Here is a hacky way to do use multiline SQL with `\COPY`.

This just strips the newlines before sending it to psql. Have your cake and eat it too :)

```bash

# Using a file
psql -f <(tr -d '\n' < ~/s/test.sql )
# or
psql < <(tr -d '\n' < ~/s/test.sql )

# Putting the SQL using a HEREDOC
cat <<SQL | tr -d '\n'  | \psql mydatabase
\COPY (
  SELECT
    provider_id,
    provider_name,
    ...
) TO './out.tsv' WITH( DELIMITER E'\t', NULL '', )
SQL

```
