title: hookup hotkeys to swap active machine  in synergy
date: 2010-12-04
---

I have a Windows workstation and an Ubuntu laptop. And I use them simultaneously
at work. Using two keyboards and mice can be a pain. And that's when I
found [Synergy][1]. Once you setup synergy you can use one keyboard/mouse to
manage both your computers. It works like a dual monitor setup, only that the
other monitor is a different machine.

I am a keyboard person and moving the mouse over to the next screen to use the
other machine is .... well, It's not enjoyable. Synergy makes it very easy to
hookup hotkeys to be able to do things. You can add the following code to the
synergy configy file which is located at `C:\Users\minhajuddin\Documents\synergy.sgc`
if you are using a windows machine as the synergy server.

    section: options
        keystroke(Alt+\u006B) = ; switchInDirection(right)
        keystroke(Alt+\u006A) = ; switchInDirection(left)
    end

Now when you hit Alt+k you're active machine will be changed to the one on the
right, Alt+j will change it to the one on the left. 

By the way, if you don't know anything about synergy and want to get started with it,
checkout [How to configure Synergy in six steps][2]

  [1]: http://synergy-foss.org/
  [2]: http://www.mattcutts.com/blog/how-to-configure-synergy-in-six-steps/
