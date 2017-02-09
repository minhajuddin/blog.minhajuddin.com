title: How to fix Ecto duplicate name migrations error
date: 2017-02-09 18:36:37
tags:
- Ecto
- Elixir
- Migration
- Error
---

If you run into the following error while running your Ecto migrations

    ReleaseTasks.migrate
    ** (Ecto.MigrationError) migrations can't be executed, migration name foo_bar is duplicated
       (ecto) lib/ecto/migrator.ex:259: Ecto.Migrator.ensure_no_duplication/1
       (ecto) lib/ecto/migrator.ex:235: Ecto.Migrator.migrate/4

You can fix it by running 1 migration at a time

    mix ecto.migrate --step 1

This happens when you are trying to run two migrations with the same name (regardless of the timestamps).
By restricting it to run 1 migration at a time you won't run into this issue.

Ideally you should not have 2 migrations with the same name :)
