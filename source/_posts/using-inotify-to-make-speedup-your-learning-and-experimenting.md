title: Using inotify to speedup your learning and experimenting
date: 2012-11-08
tags:
- go
- watch
- inotify
- learn
---

Recently I have started learning [go](http://golang.org). It is fun to learn something new, However this time just to make the feedback loop faster, I wrote a small bash script (by collecting fragments from all over the internet) using inotify. Here it is:

~~~~sh
#!/bin/bash
#Author: Khaja Minhajuddin
#Wait for go files to be modified and then execute them
#Dependency: inotify-tools
#Install on ubuntu using: apt-get install inotify-tools


#the command before the pipe is a blocking command, i.e. it doesn't end
inotifywait -mrq --format '%f' -e close_write $1 | while read file
do
  #here we filter any changes to files other than go files
  if (echo $file | grep -E '^.*\.go$')
  then
    #once we know that a go file has been written to we run it
    clear
    echo "executing 'go run $file'"
    go run $file 
  fi
done
~~~~

The script itself is pretty self explanatory, We run inotifywait in `monitor` mode so that it blocks the current process, after that we pipe whatever output comes out of inotifywait which is just the filename to the while loop which doesn't end because of the previous stream. Now, we just filter it to *go* source files and execute them.

This can be used with any other programming language too, you just have to change the filter and the execute command.

###Update:
I started playing with go web apps recently, and the following script has been helping me with recompile and reload. Hope it helps you guys too:

~~~~sh
#!/bin/bash
#Author: Khaja Minhajuddin
#Script to restart the go webserver by building and restarting the binary whenever html or go files change

function __restart_goserver(){
  binary="$(basename $(pwd))"
  echo "building $binary"
  if go build
  then
    echo "killing old process"
    kill -9 $(pidof "$binary") > /dev/null 2>&1
    echo "starting '$binary'"
    ./$binary & #run it in background
    echo "started with pid: $!"
  else
    echo "server restart failed"
  fi
}

#cd to the right directory
cd $1
__restart_goserver
#the command before the pipe is a blocking command, i.e. it doesn't end
inotifywait -mrq --exclude="$(basename $(pwd))" --format '%f' -e close_write $1 | while read file
do
  if (echo $file | grep -E '^(.*\.go)|(.*\.html)$')
  then
    echo "--------------------"
    #once we know that a go file has been written to we run it
    __restart_goserver
  fi
done
~~~~

Screenshot:
![screenshot](https://substancehq.s3.amazonaws.com/static_asset/50a3474b03b04d4c12000fc7/Selection_004.png)

###Update 2
You need `inotify-tools` to get this to work. You can install it on ubuntu by running `sudo apt-get install inotify-tools`
