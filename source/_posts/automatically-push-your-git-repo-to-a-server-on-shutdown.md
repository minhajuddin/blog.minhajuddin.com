title: automatically push your git repo to a server on shutdown
date: 2011-11-22
---

Sometimes, I forget to push my git commits to our git server at the end of the day.
This causes inconvenience to others as they can't review my code or build upon
it. So, today I wrote a small script which syncs all my git repositories with a
remote server. Hope it helps you too :)

The setup consists of three files:

###core syncing script at ~/.scripts/sync-repos###

~~~ruby

#!/usr/bin/env ruby
require 'rubygems'
require 'yaml'

#replace google.com with your git servers domain
`ping -c 1 google.com`
if $?.exitstatus != 0
  puts 'UNABLE TO SYNC REPOS AS NW IS DOWN'
  exit $?.exitstatus
end

puts 'syncing repositories'

@repos = YAML::load_file File.expand_path( '~/.sync-repos')

@repos.each do |repo|
  path = File.expand_path repo[:path]
  remotes = repo[:remotes].is_a?(String) ? [repo[:remotes]] : repo[:remotes]
  unless File.exist? path
    puts "skipping #{path} as directory not found"
    next
  end

  remotes.each do |remote|
    cmd = "cd #{path} && git push #{remote}"
    puts "executing: '#{cmd}'"
    system(cmd)
  end
end

puts 'done syncing repositories'

~~~


###config file pointing to all the repos at ~/.sync-repos###

~~~yaml

---
- :path: ~/repos/search
  :remotes:
  - origin
- :path: ~/repos/logbin
  :remotes:
  - origin
  - local

~~~


###upstart shutdown trigger script at /etc/init/syncrepos.conf###

~~~sh

start on runlevel [06]

/bin/bash -l -c /home/minhajuddin/.scripts/sync-repos

~~~

