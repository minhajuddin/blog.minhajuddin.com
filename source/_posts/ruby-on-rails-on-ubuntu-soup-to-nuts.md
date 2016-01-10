title: ruby on rails soup to nuts
date: 2011-04-02
---

Ruby on Rails Soup to Nuts
====================================
This is the first in a set of screencasts on ruby on rails. The purpose of these
screencasts is to teach you ruby on rails from the ground up using an ubuntu dev
environment.

Here is the first one:

<div>
  <iframe title="YouTube video player" width="630" height="503" src="http://www.youtube.com/embed/71UbXZ0WrCc?rel=0" frameborder="0">
  </iframe>
</div>


Notes for Session 1: Setup an ubuntu machine with the basic software
--------------------------------------------------------------------
 1. [Download and install Ubuntu 10.10](http://www.ubuntu.com/desktop/get-ubuntu/download)
 2. [Install Ruby and Rails via Rails Ready](https://github.com/joshfng/railsready)
 3. Setup gvim (which will be our primary editor)
     - Install through *software center*
     - While we are at it, let's install gnome-do
     - Finally let's configure it: https://github.com/minhajuddin/dotfiles
 4. [Importance of the terminal https://help.ubuntu.com/community/UsingTheTerminal](https://help.ubuntu.com/community/UsingTheTerminal)
 5. Install rvm using railsready
        url:	 https://github.com/joshfng/railsready
        command: wget --no-check-certificate https://github.com/joshfng/railsready/raw/master/railsready.sh && bash railsready.sh
 6. Configure rvm and install ruby
        
~~~bash

        #replace the following which is usually found on line 6 of ~/.bashrc
        [ -z "$PS1" ] && return
        # with 
        if [[ ! -z "$PS1" ]] ; then
        # also put the following line at the end of the file
        [[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm
        fi
        
~~~


 7. Install rails: gem install rails

Next screencast: 
----------------
How to build a simple rails application 
*Things that will make it easy for you to follow the next session: html, http, basics of ruby programming, basics of css*
