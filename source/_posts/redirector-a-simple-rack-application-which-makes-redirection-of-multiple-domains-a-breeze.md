title: Redirector - A simple rack application which makes redirection of multiple
  domains a breeze
date: 2010-06-06
---

The last couple of months I have been dabbling in all kinds of Ruby web frameworks. The choice of web frameworks in ruby is really amazing.

The other day, I had registered a couple of domains for one of my projects. And, I wanted to setup redirects of the '\*.org' and '\*.net' domains to the '\*.com' domain. 
I searched around a bit to see if there was a simple way to do this. But, I didn't find any simple solution. 
If I hadn't known any ruby frameworks, I would have hacked a bunch of php files and would have setup directories for each of the redirects. But, 
I have been digging ruby for a while now, and I am lovin' it :)

So, I thought I could use rack to build a small app which would redirect domains based on a configuration file. The initial code I came up with was very simple. 
Below are the contents of the `config.ru` file

~~~ruby

app = proc do |env|
  [302, {'Content-Type' => 'text','Location' => 'cosmicvent.com'}, ['302 found'] ]
end
run app

~~~


Just four lines of code to get our redirect stuff working!
All I had to do now was to somehow get the status, and location of redirects through some configuration file. I fired up <em>irb</em> and played around with <em>yaml</em> a bit. It's a child's play to get yaml working with ruby. The final code looks something like below:

~~~ruby

#config.ru:
require File.join(File.dirname(__FILE__), 'lib/redirector')

use Rack::ContentLength
use Debugger, false

app = proc do |env|
  app = Redirector.new()
  status, headers, response = app.call(env)
  [ status, headers, response ] 
end

run app

#lib/redirector.rb:
require 'yaml'

class Redirector

  @@config = YAML::load(File.open('config.yaml'))

  def self.config
    @@config
  end


  def call(env)
    host_config = get_host_config(env['HTTP_HOST'])
    [host_config['status'], {'Content-Type' => 'text','Location' => host_config['location']}, get_host_response( host_config ) ]
  end

  private
  def get_host_response(host_config)
    "#{host_config['status']} moved. The document has moved to #{host_config['location']}"
  end

  def get_host_config(host)
    return @@config[host] if @@config[host]
    raise "Configuration for #{host} not available"
  end
end


class Debugger

  def initialize(app, debug)
    @app = app
    @debug = debug
  end

  def call(env)
    if @debug
      puts '==== Config information ===='
      puts Redirector.config.inspect
      puts '============================'
    end
    @app.call(env)
  end

end


~~~


That's all, now all I had to do was set it up on my ubuntu server using 'phusion passenger'. 
You can download all the code from <a href='http://github.com/minhajuddin/redirector' title='A simple rack application which makes redirection of multiple domains a breeze.'>
http://github.com/minhajuddin/redirector</a>. Below, is a part of my config.yaml file.


~~~yaml

cosmicvent.net:
  status: 301
  location: 'http://cosmicvent.com'

cosmicvent.org:
  status: 301
  location: 'http://cosmicvent.com'

www.cosmicvent.net:
  status: 301
  location: 'http://cosmicvent.com'

www.cosmicvent.org:
  status: 301
  location: 'http://cosmicvent.com'

www.cosmicvent.com:
  status: 301
  location: 'http://cosmicvent.com'


~~~

