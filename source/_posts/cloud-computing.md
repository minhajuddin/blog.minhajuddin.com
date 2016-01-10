title: Cloud Computing / Virtualization
date: 2013-05-19
tags:
- for-sohel
- cloud-computing
- virtualization
---

Cloud computing is mostly a buzzword. In the old days when people wanted a
server to put run their software on it (like a website), they used to order a
dedicated (also called bare metal) server with a hosting company (like
rackspace.com), these companies would setup a server with your configuration and
then give you access to it so that you could put your software and use it anyway
you want. This usually would take days and the server companies needed upfront
payments for setup and monthly fees for server costs. So, if you wanted to put a
website for a week for a small conference you would have to pay for the setup
and the fee for the minimum rent duration (which would typically be a month).

With this kind of setup it used to be hard for website developers/maintainers to
scale their website. Scaling usually means adding more servers to your setup or
adding more resources (CPUs/RAM etc,.) to your existing servers, to be able to
handle an increase in traffic to your website or software.

With the advancement of technologies, and with the inception of virtualization,
hosting providers have become more flexible. Virtualization technologies allow
you to have any number of 'virtual servers' running on any number of
'real/physical servers'. So, you can have one real computer running two 'virtual servers', one
might be a linux operating system and another a windows operating system
simultaneously. Virtualization is useful because not all servers run at their
full capacity all the time. So, if there are two 'virtual servers' running on
one physical server, they share their resources (CPU, RAM etc,.) and since they
are not using all their resources all the time, the resources can be shared. The
important thing about virtualization is that you can create as many virtual
servers as you want (as long as your hardware can handle the load) very easily.
So, this has allowed hosting providers to setup huge clusters of hardware
running virtualized servers on top of them. So, now if you want a virtual
server, it will be ready at the click of a button. You can even create a virtual
server, increase its RAM size by running a simple command. This allows web
developers and administrators to automatically increase the number of servers
when their is an increase in traffic and shutdown servers when there is less
traffic. And since you only pay for the amount of time your servers are running
and not by months, you can have efficient setups without wasting your money. If
you had a supermarket wouldn't it be awesome if you had 100 checkout lanes when
you had a huge amount of customers (on weekends) and only 1 when there are no
customers? Virtualization/Cloud computing allows web administrators to do this.

More information can be found here: 
  - https://en.wikipedia.org/wiki/Cloud_computing
  - https://en.wikipedia.org/wiki/Virtualization
