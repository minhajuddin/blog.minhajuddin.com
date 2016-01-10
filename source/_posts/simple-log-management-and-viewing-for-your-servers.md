title: simple log management and viewing for your servers
date: 2011-11-08
---

As a guy who develops, deploys and maintains webapps, I had to login to my servers
and *tail the logs to see issues* too many times. It's a real pain, And anybody who maintains
any servers knows this.

I've recently found a bunch of very good apps, which make this job very pleasant: [ PaperTrail ](https://papertrailapp.com/) is
an awesome app which makes it very simple to setup a logging daemon and view
all your logs (from all your servers) on their website, It's a very neat
implementation. But, you might not want to send your logs to other apps as they usually have sensitive information.
![PaperTrail](https://substancehq.s3.amazonaws.com/static_asset/4f99dd0d03b04d2e03000037/2v721l.png)

[logstash](http://logstash.net/) is another awesome open source implementation for
log management. With logstash, you can setup a small central server which collects all your logs
and allows you to access them through a [variety of interfaces](http://logstash.net/docs/1.0.17/). Another advantage of logstash
is that the logs stay on *your* server under *your* control, plus it's open source. The only downside is the one time setup, which, is not that hard.
It is very [versatile in ways it allows you access to your logs](http://logstash.net/docs/1.0.17/).
![LogStash](http://i.imgur.com/HklrW.png)

If none of them seem to be your thing, here is a small script which I use to tail
remote log files. It runs `tail -f` over an ssh connection.
It's very simple to setup and use. Once you set it up, you can just `cd` into
your application directory and run `rt` and it will start tailing your log files
instantly. If you have any improvements you can [fork this gist and update it](https://gist.github.com/1348074).

~~~ruby

#~/.scripts/rt
#!/usr/bin/env ruby
require 'rubygems'
require 'yaml'
require 'erb'

ConfigFilePath = File.expand_path("~/.remote-tail.yml")

#will be written out to ConfigFilePath if not present
SampleConfig=<<EOS
---
defaults: &defaults
  host: c3
foonginx:
  file: /var/log/nginx/*.log
barapp:
  host: foo@bar.com
  file: /var/www/apps/railsfooapp/shared/log/*.log
EOS

Usage=<<EOS
Usage:
  1. cd to into the directory whose name is the same as the name of the config and run
     rt

  2. rt <name of the app>

  3. rt <host> <file>
EOS

def tail(opts)
  cmd = "ssh #{opts['host']} 'tail -f #{opts['file']}'"
  puts "running: '#{cmd}'"
  system(cmd)
end

def config(app)
  puts "using app:#{app}"
  config = YAML::load_file ConfigFilePath
  return config[app] if config[app]
  puts "app:#{app} not found in #{ConfigFilePath}"
  puts Usage
  exit 2
end

def setup
  return if File.exist? ConfigFilePath
  puts "creating a sample config at: #{ConfigFilePath}"
  File.open(ConfigFilePath, 'w') do |f|
    f.print SampleConfig
  end
end

def init
  setup
  case ARGV.length
  when 0
    #usage:
    #cd to the app root directory, usually this would be the name with which you
    #setup the configuration and run
    #$ rt
    tail config(File.basename(Dir.pwd))
  when 1
    #usage:
    #from any directory
    #$ rt <name of the app>
    tail config(ARGV.first)
  when 2
    #usage:
    #from any directory
    #$ rt <host> <file>
    tail :host => ARGV.first, :file => ARGV.last
  else
    puts "Invalid number of arguments"
    puts Usage
    exit 1
  end
end

init

~~~

