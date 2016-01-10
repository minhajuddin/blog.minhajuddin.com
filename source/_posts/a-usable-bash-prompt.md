title: A usable bash prompt
date: 2013-02-01
tags:
- bash
- prompt
- ps1
---

I have done my share of [bash scripting](https://github.com/minhajuddin/dotfiles/tree/master/.scripts), but for the life of me I couldn't get a color bash prompt working. I used to wire it with code like: `PS1="\e[0;31m[\u@\h \W]\$ \e[m "` (I got it from sites like [cyberciti](http://www.cyberciti.biz/faq/bash-shell-change-the-color-of-my-shell-prompt-under-linux-or-unix/). And these would never work, it would color the prompt alright, but it would screw up the cursor position. Today, I found that this syntax is actually used to set the cursor position. Anyway, I finally have a bash color prompt working without screwing up my cursor position here it is:

~~~bash
#~/.bashrc
PS1="\[\033[1;31m\]\h\[\033[00m\] \[\033[1;33m\]\W\[\033[00m\] \[\033[0;36m\]\$\[\033[00m\] "
~~~

Most of the code here is for coloring the prompt, you can read more about it at the [excellent archlinux wiki](https://wiki.archlinux.org/index.php/Color_Bash_Prompt)

Screenshot:
![Screenshot](https://substancehq.s3.amazonaws.com/static_asset/510bb12e03b04d32da00233b/Selection_047.jpeg)
