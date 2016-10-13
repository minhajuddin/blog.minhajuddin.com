title: Lets encrypt auto renewal for ubuntu and nginx
date: 2016-10-13 10:27:16
tags:
- Lets encrypt
- Auto renew
- Nginx
---

Create a file called `/etc/nginx/le_redirect_include.conf`

~~~
# intercept the challenges
location '/.well-known/acme-challenge' {
  default_type "text/plain";
  root /usr/share/nginx/letsencrypt;
}

# redirect all traffic to the https version
location / {
  return 301 https://$host$request_uri;
}
~~~

In your redirect block include this file

~~~
server {
  server_name www.liveformhq.com liveformhq.com;
  include /etc/nginx/le_redirect_include.conf;
}
~~~

To generate the LE keys run the following

~~~sh
sudo mkdir -p /usr/share/nginx/letsencrypt
# generate the certificate
sudo letsencrypt certonly --webroot=/usr/share/nginx/letsencrypt --domain cosmicvent.com --domain www.cosmicvent.com
# reload nginx
sudo kill -s HUP $(cat /var/run/nginx.pid)
~~~

Put the following in your crontab
~~~sh
$ sudo crontab -e
@weekly /usr/bin/letsencrypt &> /tmp/letsencrypt.log; sudo kill -s HUP $(cat /var/run/nginx.pid)
~~~
