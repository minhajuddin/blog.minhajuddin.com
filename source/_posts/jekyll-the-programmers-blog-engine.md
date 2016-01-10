title: jekyll the programmers blog engine
date: 2010-06-28
---

I have been using Wordpress quite some time now, and even though I don't blog often, 
I've had a lot of friction working with wordpress to publish blogs (even though
I don't post often). I think the main reason for the friction is because of the
fact that I am a programmer and my desire to control the formatting and stuff of
a blog post. Wordpress allows you to enter the raw html code, but it doesn't work 
out correctly most of the times, by the time I preview the changes and come back
to the html view my painfully crafted html seems to be lost. And this problem is 
compounded by the fact that I post code snippets(By the time I finish editing
the blog post, my code snippet would get *html encoded* 4 times).
I've tried windows live writer too, I must say it's a very good
product. But, what I was really looking for was something which would get out of
my way when I wanted to post a blog. And that's what [jekyll][1] does. From
jekyll's home page:

> Jekyll is a simple, blog aware, static site generator. It takes a template directory 
> (representing the raw form of a website), runs it through Textile or Markdown and Liquid converters,
> and spits out a complete, static website suitable for serving with Apache or your favorite web server.

Jekyll is a shiny gem(no pun intended) which is not known to many people. Jekyll
does exactly what I need, It allows me to write up blog posts in a plain text
editor like [Vim][2]. And all I have to do to publish a post, is, put the text file
which has the contents of the post in a specific folder and run jekyll, that's all. Moreover jekyll
allows you to use [pygments][3] for formatting any code snippets you want, It
also allows you to write your blog code using [markdown][4] or [textile][5]. And
lastly jekyll actually generates the final html content of your blog posts. So
no more database roundtrips and no more crazy performance problems, Your
webserver just serves these static html pages which is crazy fast. I hope this
change allows me to blog more often(Now that I am free from the shackles of
wordpress :) ).

  [1]: http://wiki.github.com/mojombo/jekyll/ "Jekyll a blog aware static site generator"
  [2]: http://vim.org "Well Vim is actually a very powerful editor"
  [3]: http://pygments.org "An awesome Python syntax highlighter"
  [4]: http://daringfireball.net/projects/markdown
  [5]: http://en.wikipedia.org/wiki/Textile_(markup_language)
