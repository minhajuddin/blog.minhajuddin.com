title: How to control pianobar using global hotkeys using Tmux
date: 2016-10-28 11:22:24
tags:
- Pianobar
- Tmux
- Hotkeys
---

I love pianobar. However, until yesterday I hated pausing and moving to the next video
using pianobar. I had a small terminal dedicated for pianobar and every time I had to
change the song or pause, I used to select the window and then hit the right shortcut.
I love hotkeys, the allow you to control your stuff without opening windows. I also happen
to use tmux a lot. And it hit me yesterday, I could have easily bound hotkeys to send the
right key sequences to pianobar running a tmux session. Here is how I did it.

I use xmonad, so I wired up `Windows + Shift + p` to `tmux send-keys -t scratch:1.0 p &> /tmp/null.log`
So, now whenever I hit the right hotkey it types the letter 'p' in the tmux session `scratch` window 1 and pane 0, where I have pianobar running.

I use xmonad, but you should be able to put these in a wrapper script and wire them up with any window manager or with unity.

~~~haskell
-- relevant configuration
, ((modMask .|. shiftMask, xK_p    ), spawn "tmux send-keys -t scratch:1.0 p &> /tmp/null.log")  -- %! Pause pianobar
, ((modMask .|. shiftMask, xK_v    ), spawn "tmux send-keys -t scratch:1.0 n &> /tmp/null.log") -- %! next pianobar

, ((modMask, xK_c     ), spawn "mpc toggle") -- %! Pause mpd
, ((modMask, xK_z     ), spawn "mpc prev") -- %! previous in mpd
, ((modMask, xK_v     ), spawn "mpc next") -- %! next in mpd
~~~
