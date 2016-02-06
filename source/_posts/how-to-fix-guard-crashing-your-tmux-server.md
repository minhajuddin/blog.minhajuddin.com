title: How to fix guard crashing your tmux server
date: 2016-02-06 14:39:08
tags:
- Guard
- Tmux
---

[Guard](https://github.com/guard/guard) is an awesome rubygem which allows livereload among other things.
However, when I run guard in tmux it was crashing all my tmux sessions. I guess
that is because I am using Tmux 2.2 and Guard tries to use Tmux notifications
for notifying about stuff. So, an easy way to fix this problem is to use
libnotify for notifications. Just add this line to your Guardfile and you
should be good.

~~~ruby
notification :libnotify
~~~
