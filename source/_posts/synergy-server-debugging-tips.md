title: synergy server debugging tips
date: 2010-12-17
---

I've been using [Synergy](http://minhajuddin.com/2010/12/04/hookup-hotkeys-to-swap-active-machine--in-synergy/) 
to work seamlessly across my ubuntu and windows 7 machines. 

Recenty I changed my ubuntu box to the synergy server, and the synergy server was crashing without
all the time. Looking into the logs (`/var/log/syslog`) didn't show anything, I
was left scratching my head for a long time. Then I realized that the `synergys`
can be executed in foreground using the `-f` flag. I executed `synergys -f -c
/etc/synergy.conf` and there it was, when I switched the computer using a hotkey
it crashed. But this time, it wrote the actual error on the screen, so I could
investigate more and fix it. So, the next time your synergy server keeps
crashing and you don't find anything in the logs run it in foreground and see
what's going on :)

By the way, the synergy binaries in the ubuntu repositories are very old, you
should [download the binaries from their site](http://synergy-foss.org/pm/projects/synergy/tabs/download#Linux)
