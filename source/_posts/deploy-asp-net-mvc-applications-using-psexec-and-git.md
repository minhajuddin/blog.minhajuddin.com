title: deploy asp net mvc applications using psexec and git
date: 2011-02-04
---

I've been managing a couple of asp.net mvc applications, and I have a bunch of [rake/albacore](http://albacorebuild.net/)
tasks to compile the asp.net mvc application on the remote server and update the 
database using [fluent migrator](https://github.com/schambers/fluentmigrator/).

Whenever I need to deploy I do the following:  

 1. RDP into the remote server
 2. Open git bash => cd to the repository's directory => do a `git fetch` and `git merge origin/master`
 3. And then run `rake compile` (to compile the latest changes) and finally `rake db:migrate`(to update the database if there are any db changes)

Even though rake and fluentmigrator make this pretty painless. It's still a pain
to rdp and do this stuff. So, I came up with a couple of batch scripts to make
this process even simpler. Now I have two batch files in the root directory of
my git repo:



~~~bash

#deploy.bat
"C:\Program Files (x86)\Git\cmd\git.cmd" fetch && 
"C:\Program Files (x86)\Git\cmd\git.cmd" reset --hard HEAD && 
"C:\Program Files (x86)\Git\cmd\git.cmd" merge origin/master && 
rake compile && 
rake db:migrate

~~~




~~~bash

#remote_deploy.bat
psexec \\example.com -u userfoo -w "c:\repos\foobar" "c:\repos\foobar\deploy.bat"

~~~


The code should be self explanatory. All we are doing is, instead of running the
command manually automating them.
