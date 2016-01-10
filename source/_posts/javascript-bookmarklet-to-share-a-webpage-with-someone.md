title: Javascript bookmarklet to share a webpage
date: 2013-02-06
tags:
- javascript
- bookmarklet
---

As a programmer, you should always thinking about automating your grunt work. My family has a private google group where we share/discuss stuff (I know what you are thinking, sharing through email ugh.. but that's how it is). Whenever I wanted to share I used to copy the link, hit Ctrl+D to get the bookmark save box, copy the title from that and then use that as a subject to send an email, so, here is a script I wrote to automate that.

~~~javascript
javascript:(function(){window.location.href = "mailto:fooxxxx@googlegroups.com?subject="+document.title+"&body="+window.location.href;})()
~~~

Just change the email in the above script to be sent to the group you want and add it as a bookmarklet
