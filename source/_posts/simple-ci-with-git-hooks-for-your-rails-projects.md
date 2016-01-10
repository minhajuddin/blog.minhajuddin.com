title: Simple CI with git hooks for your rails projects
date: 2012-12-25
tags:
- rails
- ci
- git
- rspec
---

In the past I have used jenkins for CI in my projects with little success. I think it was mainly because of my own sloppy setup.

However this time I wanted to do CI in the most simple way. I did some research and found this good post [http://blog.javabien.net/2009/12/01/serverless-ci-with-git/](http://blog.javabien.net/2009/12/01/serverless-ci-with-git/). The following setup is different that the one in the above blog post, but the idea is the same, have your CI run on your local machine rather than have a server for it.

I have used `pre-commit` hooks in the past. It sounds nice till you want to do a quick commit and you use `--no-verify` and once you do that you start doing the same for subsequent commits. 

For this I use a `post-commit` hook which triggers our CI build in the background logging all the info to `/tmp/ci.log`. This avoids unnecessary friction. So, when I commit it doesn't take forever, it happens instantly. The commit gets recorded. And then, in a background process my `railsci` script runs all the tests.

This is the `post-commit` hook. I tried to keep it minimal so as to make the setup easy and maintainable across different projects.

~~~bash
#!/bin/bash
#.git/hooks/post-commit
#Author: Khaja Minhajuddin

#run our ci script with the right info
railsci "$(git log -1 HEAD --format=%H)" "$(pwd)" 1>> /tmp/ci.log 2>&1  &
echo "TRIGGERED ci build in the background, check /tmp/ci.log"
~~~

The `railsci` script too is pretty straightforward, 

 1. It tags your commit as `processing-#{buildid}`, where buildid is a random hex id.
 2. Creates a folder called `/tmp/#{buildid}`, and clones your git repo there.
 3. Creates a new unique test database with a name `app_name_test_#{buildid}`.
 4. Runs all your tests and tags your commit as `failed-#{buildid}` if the tests fail.
 5. Removes the `processing..` tag

~~~ruby
#!/usr/bin/env ruby
#Author: Khaja Minhajuddin
#Date: 2012 Dec 24
#Script to run a ci build on the local computer after a commit is made


require 'securerandom'
require 'fileutils'

CommitHash = ARGV.shift
Repodir    = ARGV.shift
Buildid    = SecureRandom.hex
DbConfig   = "config/database.yml"
Tmpdir     = File.join('/tmp', Buildid)

FileUtils.mkdir(Tmpdir)

puts "started build for repo:#{Repodir} commit:#{CommitHash} buildid:#{Buildid}"
#helper functions
def run(arg)
  puts "RUNNING #{arg}"
  system("#{arg} 2>&1")
end

def untag(tag)
  Dir.chdir Repodir
  run("git tag -d '#{tag}'")
  Dir.chdir Tmpdir
end
def tag(tag, msg)
  Dir.chdir Repodir
  run("git tag -a '#{tag}' -m '#{msg}'")
  Dir.chdir Tmpdir
end
#checkout a shallow version in a tmp directory
tag "processing-#{Buildid}", "Running tests for build"
run("git clone #{Repodir} #{Tmpdir}")
#cd to this directory
Dir.chdir(Tmpdir)
#trust rvmrc
run("rvm rvmrc trust #{Tmpdir}")
#checkout the right commit
run("git checkout #{CommitHash} -b #{Buildid}")
run("bundle install")
#tweak database.yml
File.write(DbConfig, File.readlines(DbConfig).map {|x| x =~ /database:/ ? x.gsub('test', "test_#{Buildid}") :x }.join)
#migrate db
run("RAILS_ENV=test bundle exec rake db:create db:migrate")
#run specs
puts "Running tests"
if run("RAILS_ENV=test bundle exec rspec spec")
  system("notify-send --urgency=low -i 'terminal' 'Tests passed for the commit - #{CommitHash}'")

else
  #tag the commit as a failure
  tag "failed-#{Buildid}" , "Failed build"
  system("notify-send --urgency=low -i 'error' 'Tests failed for - #{CommitHash}'")
end
untag "processing-#{Buildid}"
#drop database
run("RAILS_ENV=test bundle exec rake db:drop")
#add a pass fail tag to the original repo
puts "Finished build for repo:#{Repodir} commit:#{CommitHash} buildid:#{Buildid}"
~~~

All of this runs behind the scenes without you even noticing it, if everything is good. You would find a `failed-#{buildid}` tag only if the tests fail. It's working great for me. Hope it helps you guys :)

Update: Fixed redirection in git hook and added a way to notify when the tests are executed
