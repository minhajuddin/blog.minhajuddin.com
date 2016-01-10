title: rvm and how to install it on ubuntu 10.4 lucid lynx
date: 2010-06-30
---

[RVM][2] (Ruby Version Manger) is an awesome tool which allows 
you to manage different versions of ruby on the same machine. I've worked in the
.net world for quite some time. And coming into ruby I was very frustrated with
the fact that I couldn't have multiple versions of ruby or that of rails. This
made playing around with edge stuff a PITA. In .net I would be able to install
different versions of the framework side by side and not having that in ruby or
rails was really frustrating. 

Enter [RVM][2] a tool to manage different ruby installations, the ruby story
gets better than the .net stuff :) With [RVM][2] you can not only install different
versions of ruby but also different patch levels of ruby. So, now you can have
ruby 1.8.7 patchlevel 249, and ruby 1.8.7 patchlevel 299 happily working off
your computer.

Alright, so you've decided to install rvm on your ubuntu (lucid lynx) box. There
are a a lot of good tutorials on how to do this. [Installing RVM][3] is the one
on the rvm website, [Setup Ruby and Rails][3] is a good one which actually tells 
you how to install rails and stuff with [RVM][2]. I did the following stuff to
get it working on my machine.

 1. Do a fresh installation of ubuntu lucid lynx and install a basic version of
    ruby using apt-get. You might already have a computer with ruby installed if
    that's the case you don't need anything for the first step.

 2. Run the following on your bash prompt to install a few libraries which are
    needed by rvm to compile ruby
 
~~~bash

    sudo apt-get install curl git-core bison build-essential zlib1g-dev libssl-dev libreadline6-dev libxml2-dev autoconf libxslt1-dev libpq-dev postgresql
 
~~~


 3. Install [RVM][2] by running the following:
 
~~~bash

bash < <( curl http://rvm.beginrescueend.com/releases/rvm-install-head )
 
~~~


 4. Fix your `.bashrc`.
 
~~~bash

 #replace the following which is usually found on line 6
 [ -z "$PS1" ] && return
# with 
if [[ ! -z "$PS1" ]] ; then
# also put the following line at the end of the file
[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm
fi
 
~~~

 5. Finally change the ownership of "~/.gem" using `sudo chown minhajuddin
    /home/minhajuddin/.gems`

Now you should be able to install new versions of rvm using `rvm install
ruby<version>` like `rvm install ruby-1.9.2` and change the rvm version using
`rvm use ruby-1.9.2` 

[RVM][2] is a just the right amount of crazy which was needed in the ruby world
at this point of time. And if you find it useful please donate some dough to the
guys working on RVM, they are making the lives of a lot of guys like us more
enjoyable.

  [1]: http://www.wildblueether.com/category/on-the-ground/ "Setup Ruby and Rails" 
  [2]: http://rvm.beginrescueend.com/ "Ruby Version Manager"
  [3]: http://rvm.beginrescueend.com/rvm/install/ "Installing RVM"
