title: How to setup mutt to fetchmail every minute
date: 2016-02-03 11:50:03
tags:
- mutt
- How to
---

I have recently started using mutt to access my gmail via POP3. I followed the awesome setup by Andrew: http://www.andrews-corner.org/mutt.html

However, I had to hit `I` to make mutt fetch the email, Here is a crontab entry I setup to automatically retreive the email every minute.

~~~bash
* * * * * /bin/bash -l -c '/usr/bin/fetchmail -v >> /home/minhajuddin/log/fetchmail.log 2>&1'
~~~
