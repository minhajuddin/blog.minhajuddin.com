title: An easy way to automate your browser
date: 2012-09-25
tags:
- hack
- javascript
- bookmarklet
---

I build web applications, and use the browser a lot. And there are a few things which I do all the time. For instance, all my web applications have a login page and while developing them, I have to login every time before I start testing them. To make this pain free, I've added a bookmarklet in my bookmark with the following code:

~~~javascript
//Devise login
javascript: (function() {
  document.getElementById("user_email").value = "user@mailinator.com";
  document.getElementById("user_password").value = "please";
  document.getElementById("new_user").submit();
})()
~~~

If you know javascript, you'll know that all this code is doing is filling the username and password and posting the form. This saves me a lot of keystrokes. Another bookmarklet which I use is to remove NSFW videos from youtube's recommendations list

~~~javascript
javascript:var e = document.getElementById('watch-sidebar');
e.parentNode.removeChild(e);
~~~
 
This code just removes the div containing the recommendation videos. These are just a few examples, if you know a little bit of javascript. You can easily create bookmarklets to make your repetitive jobs easy.
