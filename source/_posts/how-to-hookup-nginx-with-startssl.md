title: how to hookup nginx with startssl
date: 2011-03-11
---

*This is a note-to-self* 

[StartSSL](http://www.startssl.com) is a certification authority which gives away *free* SSL certificates valid for one year (after which you can renew it again for *free*). They are simply awesome. Anyway, this blog post documents how you can setup an ssl cert on an nginx server using the start ssl free cert.

- Signup for a [StartSSL](http://www.startssl.com) account . StartSSL doesn't give you a username and password, it gives you a client certificate instead (Use firefox to do signup). Make sure to [back up](https://www.startssl.com/?app=25#4) the client cert.
- SSH into your server and run the following commands:
  
~~~bash

  openssl genrsa -des3 -out server.key.secure 2048
  openssl rsa -in server.key.secure -out server.key
  openssl req -new -key server.key -out server.csr
  
~~~

- On startssl browse to the *control panel* and then to the *validations wizard* and validate the domain for which you want to generate your ssl.
- Now go to the *certificates wizard* tab in the *control panel* and create a *web server ssl certificate*. Skip the first step and paste your `server.csr` file in the next step. Finish the rest of the steps of this wizard.
- Browse to the *tool box* in the *control panel* and click on *retrieve certificate*. Copy your certificate and paste it into a file called `server.crt` on the server.
- Download [sub.class1.server.ca.pem](http://www.startssl.com/certs/sub.class1.server.ca.pem) to your server.
- Now run `cat sub.class1.server.ca.pem >> server.crt` to append the intermediate certificate to your cert.
- Run the commands:
  
~~~bash

  sudo cp server.crt /etc/ssl/example.com.crt
  sudo cp server.key /etc/ssl/example.com.key
  
~~~

- Change your nginx conf to:
  
~~~bash

  server {
        .
        .
        listen 80;
        listen 443 ssl;
        ssl on;
        ssl_certificate /etc/ssl/example.com.crt;
        ssl_certificate_key /etc/ssl/example.com.key;
        .
        .
        }
  
~~~

- Restart your nginx server

###References###
- [nginx and startssl](http://stephen.mcquay.me/blog/detail/30/)
- [SSL Certificate Installation - Nginx Server](http://www.digicert.com/ssl-certificate-installation-nginx.htm)
