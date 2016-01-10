title: How to install Command T for vim using rvm on linux
date: 2013-01-09
tags:
- command-t
- vim
- rvm
- linux
---

Use the `vba` package or add the command-t git directory to your vim rtp using pathogen. I use pathogen, hence the following

~~~bash
#download the code
cd ~/.vim/bundle
git clone git://git.wincent.com/command-t.git bundle/command-t
# or if you manage your dotfiles using git
# git submodule add git://git.wincent.com/command-t.git bundle/command-t

# unset your CFLAGS if you have any, may not be necessary, but just in case
unset CFLAGS
# change your ruby version to the version used by vim
# you can check the version with which vim was compiled using
# by running the following from the vim command prompt
# :ruby puts RUBY_VERSION
rvm use ruby-1.8.7-p357
cd ~/.vim/ruby/command-t
ruby extconf.rb
make
~~~
