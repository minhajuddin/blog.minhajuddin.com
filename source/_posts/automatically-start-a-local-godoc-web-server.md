title: 'Automatically start a local godoc web server '
date: 2012-11-30
tags:
- go
- godoc
- upstart
---

Godoc is awesome, It allows you to browse all the documentation on your local machine by running the following command

~~~bash
godoc -http=:8090
~~~

Once you do this you can happily browse through all the documentation offline. However, you can start this process as an upstart daemon and let it run in the background. All you have to do is create a file called `/etc/init/godoc.conf` with the following content

~~~bash
#Upstart script to start godoc server
#Author: Khaja Minhajuddin
#*This obviously works on machines with upstart*
start on runlevel [2345]
stop on runlevel [06]

script
  export HOME=/home/minhajuddin
  export GOROOT=$HOME/go
  export GOBIN=$GOROOT/bin
  export GOPATH=$HOME/gocode
  $GOBIN/godoc -http=:8090 -index=true
end script
~~~

You just need to make sure that the env vars are adjusted to your setup. Also, using `-index=true` runs a full text search on all your documentation (which is simply awesome). Now, you will have your godoc server at http://localhost:8090/ all the time.

On a related note, godoc can be used from the command line like:

~~~bash
#godoc <pkg name> Type/Func
godoc net Listener
~~~
