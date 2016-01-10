title: a simple rake task to ping google, bing, and yahoo about a change in your sitemap
date: 2011-01-21
---

There is an easy way to notify google, bing and yahoo whenever you add content
to your site or blog. All of them expose a url which when called with your
sitemap's url updates their indexes. This fact is known to most developers, I
just wanted to share a simple rake task, which automates this. I use it to ping these 
search engines whenever I write a new blog post.  

All it's doing is looping over all the search engines' urls and using curl to
ping them.



~~~ruby


Sitemap = "http://minhajuddin.com/sitemap.xml"
desc "ping search engines about a change in sitemap"
task :ping do
  [ "http://www.google.com/webmasters/sitemaps/ping?sitemap=",
    "http://www.bing.com/webmaster/ping.aspx?siteMap=" ,
    "http://search.yahooapis.com/SiteExplorerService/V1/updateNotification?appid=YahooDemo&url=" ].each do |url|
    puts `curl #{url}#{Sitemap}`
    end
end


~~~

