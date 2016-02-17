title: 'Script your tmux to maximize awesome!'
date: 2016-02-17 20:21:23
tags:
- tmux
- script
- automate
---

[tmux](https://tmux.github.io/) is an awesome terminal multiplexer. I have been
an Xmonad user about 4 years, and everytime I heard about tmux in the past I
used to think that my window manager was powerful and I din't need another
terminal manager. But, tmux is much more than that.

If you spend a lot of time on your terminal, I urge you to take some time to
learn tmux, you'll be surprised by it. Anyway, the point of this post is to show
you its scriptability.

I hacked together the following script from various sources online.

This script is to manage my workspace for [Zammu](https://zammu.in)(Zammu an
awesome continuous delivery app that I am currently working on, Go check it out
at https://zammu.in/). Zammu is a rails app, it is architected to use a bunch of
microservices, so to start any meaningful work I need to fire up those agents
too. Doing this manually is very tedious, with tmux I have one command to do it:

I just run `tmz` and it does the following:

  1. Opens my editor with my TODO file in the first window.
  2. Opens a pry console in the second window.
  3. Creates a split pane in the second window with a bash terminal, also runs
     the git log command, git status command and launches a browser with my
     server's url.
  4. Creates a third window with `rails server` in the first pane, `sidekiq` in
     the second pane, `foreman start` in the third pane which starts all the
     agents and a `guard` agent for livereload in a tiny 2 line pane.
  5. Finally it switches to the first window and puts me in my editor.

This has been saving me a lot of time, I hope you find it useful.

I have similar workspace setter uppers for my communication (mutt,
rainbowstream, irssi) and other projects.

I just ran the command `history | grep  '2016-02-17' | wc` and it gave me `591 3066 23269`
That is 591 commands in 3066 words and 23269 characters and that's just the terminal.
Do yourself a favor and use tmux.

I have also created a short screencast for it, check it out.

{% youtube na_FMtOinVw %}

~~~bash
#!/bin/bash
#filepath: ~/bin/tmz

SESSION_NAME='zammu'
ROOT_DIR="$HOME/r/webcore/web"

tmux has-session -t ${SESSION_NAME}

# open these only if we don't already have a session
# if we do just attach to that session
if [ $? != 0 ]
then
  # -n => name of window
  tmux new-session -d -s ${SESSION_NAME} -c ${ROOT_DIR} -n src

  # 0 full-window with vim
  tmux send-keys -t ${SESSION_NAME} "vim TODO" C-m
  # - - - - - - - - - - - - - - - - - - - -

  # 1 pry+terminal
  tmux new-window -n pry -t ${SESSION_NAME} -c ${ROOT_DIR}
  # >> pry
  tmux send-keys -t ${SESSION_NAME}:1 'bundle exec rails console' C-m
  # >> terminal 1index window 1index pane => 1.1
  tmux split-window -h -t ${SESSION_NAME}:1 -c ${ROOT_DIR}
  tmux send-keys -t ${SESSION_NAME}:1.1 '(/usr/bin/chromium-browser http://localhost:3000/ &> /dev/null &);git ll;git s' C-m

  # - - - - - - - - - - - - - - - - - - - -

  # 1 server+logs
  tmux new-window -n server -t ${SESSION_NAME} -c ${ROOT_DIR}
  # >> server
  tmux send-keys -t ${SESSION_NAME}:2 'bundle exec rails server' C-m
  # >> sidekiq
  tmux split-window -v -t ${SESSION_NAME}:2 -c ${ROOT_DIR}
  tmux send-keys -t ${SESSION_NAME}:2.1 'bundle exec sidekiq' C-m
  # >> agents
  tmux split-window -v -t ${SESSION_NAME}:2 -c "${ROOT_DIR}/.."
  tmux send-keys -t ${SESSION_NAME}:2.2 'foreman start' C-m
  # >> guard
  tmux split-window -v -t ${SESSION_NAME}:2 -c "${ROOT_DIR}" -l 1
  tmux send-keys -t ${SESSION_NAME}:2.3 'guard --debug --no-interactions' C-m
  # - - - - - - - - - - - - - - - - - - - -

  # start out on the first window when we attach
  tmux select-window -t ${SESSION_NAME}:0
fi

tmux attach-session -t ${SESSION_NAME}
~~~
