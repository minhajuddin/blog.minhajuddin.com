title: Script to cleanup old directories on a linux server
date: 2016-03-08 12:23:39
tags:
- bash
- cleanup
- server
---

Here is a simple script which can cleanup directories older than `x` days on your server
It is useful for freeing up space by removing temporary directories on your server

~~~sh
#!/bin/bash

# usage
# # deletes dirs inside /opt/builds which are older than 3 days
# delete-old-dirs.sh /opt/builds 3
# cron entry to run this every hour
# 0 * * * * /usr/bin/delete-old-dirs.sh /opt/builds 2 >> /tmp/delete.log 2>&1
# cron entry to run this every day
# 0 0 * * * /usr/bin/delete-old-dirs.sh /opt/builds 2 >> /tmp/delete.log 2>&1

if ! [  $# -eq 2 ]
then
cat <<EOS
  Invalid arguments
  Usage:
    delete-old-dirs.sh /root/directory/to-look/for-temp-dirs days-since-last-modification
    e.g. > delete-old-dirs.sh /opt/builds 3
EOS
  exit 1
fi

root=$1
ctime=$2

for dir in $(find $root -mindepth 1 -maxdepth 1 -type d -ctime +"$ctime")
do
  # --format %n:filename, %A:access rights, %G:Group name of owner, %g: Group ID of owner, %U: User name of owner, %u: User ID of owner, %y: time of last data modification
  echo "removing: $(stat --format="%n %A %G(%g) %U(%u) %y" "$dir")"
  rm -rf "$dir"
done

~~~
