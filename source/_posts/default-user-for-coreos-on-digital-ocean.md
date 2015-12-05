title: Default user for coreos on Digital Ocean
date: 2015-12-05 13:28:51
tags: docker, coreos
---

I just started playing with [Coreos](https://coreos.com) to run my docker containers.
However, when I spun up an instance on Digital Ocean with my private key,
I wasn't able to login using the root account. It turns out that Digital Ocean sets up the private key
for an account with the name `core`. So, the next time you are stuck doing this just try logging in with
  the *core* account.

~~~bash
ssh core@<your-ip>
~~~
