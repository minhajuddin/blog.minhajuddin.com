title: use malcolmx to search for domain names from the command line
date: 2010-12-25
---

The other day I stumbled upon [instantdomainsearch.com](http://instantdomainsearch.com/). 
It's *the* best among the domain name checking apps I have used till now. It's very
zippy and has a clean interface. 

It has just one limitation, it allows you to search domains *one* at a time. And
if you have a bunch of domain names which you want to check in one go, you can't
do it. So, I slapped together a [gem: MalcolmX](https://github.com/minhajuddin/malcolmx) which allows us
to check for multiple domain names in one go. You can checkout it's [code on
github](https://github.com/minhajuddin/malcolmx). Once you install it using `gem
install malcolmx` you can check for multiple domain names like this:

    malcolmx cosmicvent minhajuddin myfunkyfreakydomain
