title: One line command to import prod data to development computer
date: 2014-01-20
tags:
- postgresql,
- import
---

The pg_dump command runs on your prod server streaming all the data into pg_restore which runs locally

~~~sh
ssh user@remote.com pg_dump -Fc --no-acl --no-owner remote_db | pg_restore --verbose --clean --no-acl --no-owner -d localdb
~~~
