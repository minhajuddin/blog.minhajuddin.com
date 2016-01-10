title: My Substance Template
date: 2012-07-03
tags:
- substance
- template
---

Here is the substance template I use for my blog. You can get a blog with the same style just by copying this content to your substance template.

~~~html

<!DOCTYPE html>
<html>
  <head>
    <link href="https://substancehq.s3.amazonaws.com/assets/themes/basic-ad984f7b012b0c32734a2fe824329238.css" rel="stylesheet" />
    <link href="https://substancehq.s3.amazonaws.com/assets/pygments-18ba01c79ccfbe022848bccbb4413b59.css" rel="stylesheet" />
    <link rel="alternate" type="application/atom+xml" title="Atom feed" href="/atom.xml"/>
    <link rel="sitemap" type="application/xml" title="Sitemap" href="/sitemap.xml" />
    <meta name="author" content="Khaja Minhajuddin" />
    {{^page.indexed}}    
    <meta name="robots" content="noindex" />
     {{/page.indexed}}    
    <style>
  #posts-list{ margin-top: 20px; margin-bottom: 10px; }
#posts-list td.post-date{ margin: 0; text-align: center;padding-right:0; padding-left:0;}
#posts-list td.post-link{ padding-left: 10px; }
#posts-list td.post-date{width: 10%;}
#posts-list td.post-tags{width: 30%;}
#posts-list td{padding-bottom: 20px; }
#post-tags {margin-bottom: 10px;}
   </style>
    <title>
      {{ page.title }} - {{ site.title }}
    </title>
    <link rel="alternate" type="application/atom+xml" href="http://feeds.feedburner.com/shiny-stuff" />
    <link rel="canonical" href="{{ page.absolute_url }}/"/>
    <link rel="shortcut icon" type="image/x-icon" href="http://minhajuddin.com/favicon.ico">
    {{{google_analytics_script}}}
  </head>
  <body>
    <nav>
    <div class="centered">
      <div class="brand">
        <a href='/'>{{ site.title }} »</a>
      </div>
<ul>
        <li><a href="/" title="In search of the next shiny thing">Home</a></li>
        <li><a href="/hire-me" title="Hire Me">Hire Me</a> </li>
        <li><a href="/about" title="About Me">About</a> </li>
        <li><a href="http://feeds.feedburner.com/shiny-stuff" title="Subscribe to the rss feed">Subscribe</a> </li>
      </ul>
     <div style="clear:both;"></div>

    </div>
    </nav>

    <div id="wrapper">

      <div class='content'>

        {{#if_page}}
        {{>content}}
        {{/if_page}}



        {{#if_post}}
        <div id="post">
          <h1><a href="{{ page.url }}" title='{{ page.title }}' class='post-title'>
              {{ page.title }}
          </a></h1>
          <span class='post-date'>{{page.formatted_published_at}}</span>
          {{{ page.markdownified_content }}}
        </div>

        <div id='post-tags'>

          {{#page.tags}}
          <a href='/tagged/{{.}}'>#{{.}}</a>
          {{/page.tags}}
        </div>


        <a href="http://twitter.com/share" class="twitter-share-button" data-count="horizontal" data-via="minhajuddin">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script>
        <g:plusone size="medium"></g:plusone>
        <hr />


<div id='comments'>
  <div id="disqus_thread"></div>
  <script type="text/javascript">
    var disqus_identifier = '{{page.url}}';
    (function() {
     var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
     dsq.src = 'http://minhajuddin.disqus.com/embed.js';
     (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
     })();
   </script>
 </div>
       <script type="text/javascript">
          (function() {
           var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
           po.src = 'https://apis.google.com/js/plusone.js';
           var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
           })();     
</script>
       {{/if_post}}
       </div>
<footer>
<div style="float:left;">
<a href="/" title="In search of the next shiny thing">home</a> ·
     <a href="http://feeds.feedburner.com/shiny-stuff" title="Subscribe to the rss feed">rss</a> ·
     <a href="/archives" title="Archives">archives</a>   ·
     <a href="/hire-me" title="hire me">hire me</a> ·
     <a href="/about" title="about me">about</a> ·
     <a href="/about#disclaimer" title="legal">legal</a> ·
     <a href="http://github.com/minhajuddin" title="me on github">on github</a> ·
     <a href="http://twitter.com/minhajuddin" title="me on twitter">on twitter</a> ·
     <a href="mailto:minhajuddin.k@gmail.com" title="email">email</a> ·
     <a href="http://cosmicvent.com" title="Cosmicvent Software">my company</a>
</div>
<div style="float:right;">
Powered by <a href='http://substancehq.com' title='Substance - The simple blog engine' >Substance</a>
</div>
<div style="clear:both;">
  <div id="footer-sites">
    <span style="color:#0074CC;font-size:140%">■</span>&nbsp;<a href="http://substancehq.com" title='The simple blog engine - Substance'>substancehq.com</a>&nbsp;
    <span style="color:#000;font-size:140%">■</span>&nbsp;<a href="http://getsimpleform.com/" title='Simple Form - Build simple web forms'>getsimpleform.com</a>&nbsp;
    <span style="color:#607848;font-size:140%">■</span>&nbsp;<a href="http://redirectapp.com" title='Easy url redirection for your websites - Redirect App'>redirectapp.com</a>&nbsp;
    <span style="color:#222;font-size:140%">■</span>&nbsp;<a href="http://logb.in" title='Save your cherished private moments for posterity - Logbin'>logb.in</a>&nbsp;
  </div>

</div>
     </footer>
     </div>
   </div>
 </body>
</html>
~~~
