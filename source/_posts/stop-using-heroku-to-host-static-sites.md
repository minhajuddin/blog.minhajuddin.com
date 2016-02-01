title: Stop using Heroku to host static sites
date: 2016-02-01 22:38:12
tags:
- Heroku
---

I [see](http://blog.teamtreehouse.com/deploy-static-site-heroku#comment-170888) [many](https://github.com/roperzh/heroku-buildpack-hugo)
[posts](https://github.com/spf13/hugo/issues/293) [on the internet](http://byenary.com/blog/2015/04/02/setting-up-a-blog-with-hugo-and-heroku/)
about running static sites using the development server on heroku.

**This is a bad practice**, This goes completely opposite to what static site generators are. Static site generators are meant to spit out the required HTML
to run it from any basic webserver/webhost. Also, there is [Github Pages](https://pages.github.com/) which is an excellent host which provides hosting
for static content. Heck, it even supports building of websites automatically using the Jekyll static site generator.

The servers which come bundled with the static site generators are a conveneince to test your site locally and not something to be hosted on a production server.

If you are a figure with a big following, please don't propagate bad practices. It may seem like a fun/clever exercise for you, but it in the end it sends the wrong message.

P.S: I am building an [Automatic Deployment Solution which can build and deploy websites to Github Pages, it supports Hugo, Jekyll, Middleman, Octopress and Hexo](https://zammu.in/?invitation_code=KHAJA). I would love to hear your feedback on it.
