title: how to setup your router to automatically reconnect
date: 2010-11-07
---

At my home I have a DSL router which disconnects whenever it feels like it ;)
To reconnect it, I usually have to open up the router's home page, browse to the
page with the connect link, enter the username and password and then submit the form.
I know just reading the above text makes me sleepy and it's such a distraction.

So, I wrote a small script which reconnects the router if it has disconnected.
you can use it if you have the same problem ;)



~~~ruby


require "net/http"
require "uri"
require 'base64'

def request(page, method = 'get', form_data = nil)
  uri = URI.parse("http://router#{page}")
  http = Net::HTTP.new(uri.host, uri.port)
  request = method == 'get' ? Net::HTTP::Get.new(uri.request_uri) : Net::HTTP::Post.new(uri.request_uri)
  request.set_form_data(form_data) if form_data
  request.basic_auth("username", "password")
  http.request(request)
end

def connect
  connect_url = '/webconfig/quick_start/connect.html/action_qstart_connect?qstart_pppIntf=pppoe_0_35&qstart_pppUserName=username&qstart_pppPassword=password&submit_Connect=Connect'
  res = request('/webconfig/wan/wan.html')
  unless res.body.match "Disconnect"
    puts 'disconnected, connecting ....'
    res = request(connect_url)
  else
    puts 'connected'
  end
end

while(true)
  begin
    connect
  rescue
    puts $!
  end
  sleep 5
end


~~~

