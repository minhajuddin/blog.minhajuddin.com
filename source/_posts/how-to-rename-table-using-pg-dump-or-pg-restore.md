title: How to rename table using pg_dump or pg_restore
date: 2021-03-14 18:22:43
tags:
- pg_dump
- pg_restore
- postgresql
- rename
- table
---

I am in the process of migrating the data from one of my side projects to a
rewritten schema. While doing this, I wanted to keep the old table around with a
different name and do migrations at run time, only when I see someone is using
it. So, I started looking into how I can rename my table while doing a
pg_restore, turns out there is no way to do it. The following is a hacky way to
get it working.

1. Do a `pg_dump` of your db: `pg_dump -Fc --no-acl --no-owner --table forms my_forms_prod > my_forms_prod.pgdump`
1. Do a `pg_restore` into a temporary `scratch` database `pg_restore --verbose --clean --no-acl --no-owner -d scratch my_forms_prod.dump`
1. Rename your table: `ALTER TABLE forms RENAME TO old_forms;`
2. Do another dump: `pg_dump -Fc --no-acl --no-owner scratch > my_old_forms_prod.pgdump` which will have the "RENAMED" table :D
2. Now, you can import this using pg_restore: `pg_restore --verbose --clean --no-acl --no-owner -d my_new_forms_prod my_old_forms_prod.dump`

This is just a hack though. Hope you find it useful 😀
