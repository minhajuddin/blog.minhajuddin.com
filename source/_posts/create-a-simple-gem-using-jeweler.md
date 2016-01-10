title: create a simple gem using jeweler
date: 2010-09-30
---

So, you've come up with some awesome re-usable utility in ruby, and you want to use it
across your projects. And you don't want to copy/paste the files across
different projects, cause that's a pain and keeping all your re-usable code
across the projects up to date is not feasible. 

It's obvious at this point that what you want is a gem, which would make sharing of code
across your projects a breeze, with the added benefits of seamless upgrades.
Hopefully this blog post will teach you how to create a simple gem in a few
steps.

Gem creation is very easy if you use the right tools. If you go to
[ruby-toolbox.com][1] you can see that there is more than one tool for gem
creation and management. The top-most on this list is [Jeweler][2], It is an
awesome gem with a lot of nifty features which makes gem management a breeze.

OK, *Enough talk let's fight*. The first thing which you need to do
is install jeweler with the command `[sudo] gem install jeweler`

Once you have jeweler installed just follow the steps below to create your *own*
gem:

  - Run the command `jeweler fixnum_extensions` in the directory where you want
  to create your your gem (fixnum\_extensions here is the name of the gem).
  - With the above command jeweler creates a bunch of files and directories for
  your gem. One of the files which it creates is the `Rakefile` which has a lot
  of predefined tasks which you can use to manager your gems.
  - The file where you need to put your ruby code is  `lib/fixnum_extensions.rb` 
  my file has the code below in it:
  
~~~ruby

  #This is a contrived example but it's fine
  class Fixnum
    def add(number)
      number + self
    end
    def sub(number)
      number - self
    end
    def mul(number)
      number * self
    end
    def div(number)
      number / self
    end
  end
  
~~~

  - Now you need to open up the Rakefile and add a *description* and *summary*
  instead of the TODOs.
  - Note that it fills up the author name and email by
  looking at your git configuration files, it also creates a git repository with
  a nice .gitignore file and makes the initial commit.
  - The last thing you need to do before building your gem is create a VERSION
  file, to do this just run `rake version:write`. This command creates a VERSION
  file in your gem's root folder which holds the version number of your gem.
  - Finally, to build our gem run `rake build` (ignore the warnings when you run
  this command). This will create a folder called `pkg` which holds your final
  gem file `fixnum_extensions-0.0.0.gem`.

Now, you can share this gemfile with anyone you want and they'll get all your
code in a nice gem package. To install it, just run the command `gem install
pkg/fixnum_extensions-0.0.0.gem`

To test it out open an irb session and run the following commands

  
~~~ruby

  require 'rubygems'
  require 'fixnum_extensions'
  1.add(2).mul(3)
  
~~~


  Jeweler adds a lot of nifty tasks which are great, to check them out just run
  `rake -T`

  [1]: http://ruby-toolbox.com/categories/gem_creation.html
  [2]: http://github.com/technicalpickles/jeweler
