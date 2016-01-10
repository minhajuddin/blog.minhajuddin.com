title: how to install a ruby version with rvm when you are offline
date: 2010-07-22
---

This has happened to me manytimes, When I try to install a version of ruby, rvm
crashes unable to download the right version of the ruby source code. Sometimes
because it can't resolve rubyforge.org and other times for other reasons. 

Anyway, when such a thing happens, or when you don't have an internet connection
to the computer on which you want to install a version of ruby, you can copy the
zipped file with the source code to your `$HOME/.rvm/archives/` directory and
then run `rvm install <ruby-version>`. This will install the desired ruby
version skipping the download and using the file present in the archives
direcotry.


~~~bash

cp ruby-enterprise-1.8.7-2010.02.tar.gz /home/minhajuddin/.rvm/archives
rvm install ree-1.8.7

~~~

