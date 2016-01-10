title: Run specs/tests from within vim without blocking your flow
date: 2012-12-25
tags:
- vim
- rspec
- rails
---

Everyone knows how great `Guard` is for running tests automatically. However, I hit `:w` involuntarily all the time, I've spent so much time in `vim` that I cannot go even a few seconds without hitting `:w`. I even do it in text areas on web pages, But I digress. Because of this, I unintentionally trigger my specs even before I complete them. 

I have seen [many](http://joshuadavey.com/2012/01/10/faster-tdd-feedback-with-tmux-tslime-vim-and-turbux/) [people](http://teamcoding.com/blog/vim_tmux_and_rspec) [use tmux](http://henrik.nyh.se/2012/07/tests-on-demand-using-vimux-and-turbux-with-spork-and-guard/) to get it working on demand. However, I use [xmonad](http://xmonad.org/) and I don't want to learn another app to tile/organize my terminals. I can do them easily in xmonad. 

So, my first attempt was to create a daemon in go which would listen for new commands on a unix domain socket. I almost finished it (You can check it here: https://github.com/minhajuddin/cmdrunner). However, it seemed too much work for something simple. We all know that we can run a command in background on linux by appending an `&` to the end. My final setup turned out to be much simpler than I anticipated. Too much thinking cost me a couple of hours. 

The setup contains two parts.

###1. A script to run commands in background by redirecting the stderr and stdout properly

~~~bash
#!/bin/bash
#~/.scripts/runinbg
#Author: Khaja Minhajuddin
#Script to run a command in background redirecting the
#STDERR and STDOUT to /tmp/runinbg.log in a background task

echo "$(date +%Y-%m-%d:%H:%M:%S): started running $@" >> /tmp/runinbg.log
cmd="$1"
shift
$cmd "$@" 1>> /tmp/runinbg.log 2>&1 &
#comment out the above line and use the line below to get get a notification
#when the test is complete
#($cmd "$@" 1>> /tmp/runinbg.log 2>&1; notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$rawcmd")&>/dev/null &

~~~

###2. Vim function to call this script with the current filename
~~~vim
function! RunSpecs()
  :silent!!runinbg bundle exec rspec % "you can tweak this to your liking
  redraw! "without this the screen goes blank
endfunction

nnoremap <C-d> :call RunSpecs()<cr>
~~~

You can check the log of your tests by running `tail -f /tmp/runinbg.log`

Update: Added a version with notification
