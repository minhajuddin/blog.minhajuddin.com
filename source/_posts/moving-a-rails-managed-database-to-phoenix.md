title: Moving a Rails managed database to Phoenix
date: 2021-03-07 14:32:11
tags:
- Rails
- Phoenix
- Elixir
- Database
- Migration
- Ecto
---

I am moving my app from Rails to Phoenix and as part of this I have to move my
database from being managed by Rails migrations to Phoenix migrations. Here is
how I did it:

1. Rename the `schema_migrations` table. Phoenix uses Ecto for managing the
   database. Ecto and Rails use a table called `schema_migrations` to store the
   database migration info. So, you'll have to rename it to avoid errors when
   you run Ecto migrations.
   ```
   psql db
   ALTER TABLE schema_migrations RENAME TO rails_schema_migrations
   ```
2. After this, you'll need to create the schema_migrations table for ecto, you
   can do it by running the `mix ecto.create` command. This will set up the
   `schema_migrations` table in the existing database.

Now, you've successfully migrated your database. And, you can run your
Phoenix/Ecto migrations like you would in a normal phoenix app.
