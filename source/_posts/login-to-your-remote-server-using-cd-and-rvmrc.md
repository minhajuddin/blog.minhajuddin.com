title: login to your remote server using cd and rvmrc
date: 2012-02-08
---

Here is a fun trick which you can use, to simulate that a remote server is on one of
your directories.

Create a folder call ~/m/example.com and in that folder create a file called
.rvmrc with the following command


~~~bash

ssh awesomeuser@example.com -p 2302 -i ~/.ssh/awesomekey_rsa
#or whatever ssh command you use

~~~


Now whenever you run `cd ~/m/example.com` you will automagically be logged into
your remote computer.

Obviously, this is a fun trick. All this can be done in a much nicer way using the `~/.ssh/config`
file.

Here are a few resources to make your ssh config more useful, allowing you to
login to servers using a command like `ssh myserver`

 - [http://linux.die.net/man/5/ssh_config](http://linux.die.net/man/5/ssh_config)
 - [http://www.evilsoft.org/2009/10/23/stupid-ssh-config-tricks](http://www.evilsoft.org/2009/10/23/stupid-ssh-config-tricks)
 - [http://www.linuxjournal.com/article/6602](http://www.linuxjournal.com/article/6602)
 - [http://www.howtogeek.com/75007/stupid-geek-tricks-use-your-ssh-config-file-to-create-aliases-for-hosts/](http://www.howtogeek.com/75007/stupid-geek-tricks-use-your-ssh-config-file-to-create-aliases-for-hosts/)

I wonder what other stuff could be done using rvmrc.
