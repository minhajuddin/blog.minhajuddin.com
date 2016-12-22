title: How to show your blog content in your Rails application
date: 2016-12-22 08:19:24
tags:
- Blog
- Rails
- Atom
---

I recently released [LiveForm](https://liveformhq.com/) which is a service which gives you form endpoints (I'd love to have you check it out :) )
I wanted to show my blog's content on the home page, It is pretty straightforward with the rich ruby ecosystem.

 1. First you need a way to get the data from your blog. The LiveForm blog has an atom feed at http://blog.liveformhq.com/atom.xml . I initially used RestClient to get the data from the feed.  
 2. Once we have the feed, we need to parse it to extract the right content. Some quick googling led me to the awesome [feedjira](https://github.com/feedjira/feedjira) gem, (I am not gonna comment about the awesome name:))
 3. feedjira actually has a simple method to parse the feed from a URL `Feedjira::Feed.fetch_and_parse(url)`  
 4. Once I got the entries, I just had to format them properly. However, there was an issue with summaries of blog posts having malformed html. This was due to naively slicing the blog post content at 200 characters by hexo (the blog engine I use), Nokogiri has a simple way of working around this. However, I went one step further and removed all html markup from the summary so that it doesn't mess with the web application's markup: `Nokogiri::HTML(entry.summary).css("body").text`
 5. Finally, I didn't want to fetch and parse my feed for every user that visited my website. So, I used fragment caching to render the feed once every day.

Here is all the relevant code:

The class that fetches and parses the feed

```ruby
class LiveformBlog
  URL = "http://blog.liveformhq.com/atom.xml"
  def entries
    Rails.logger.info "Fetching feed...................."
    feed = Feedjira::Feed.fetch_and_parse(URL)
    feed.entries.take(5).map {|x| parse_entry(x)}
  end

  private
  def parse_entry(entry)
    OpenStruct.new(
      title: entry.title,
      summary: fix_summary(entry),
      url: entry.url,
      published: entry.published,
    )
  end

  def fix_summary(entry)
    doc = Nokogiri::HTML(entry.summary)
    doc.css('body').text
  end
end
```

The view that caches and renders the feed

```erb
<%= cache Date.today.to_s do %>
  <div class='blog-posts'>
    <h2 class='section-heading'>From our Blog</h2>
    <% LiveformBlog.new.entries.each do |entry| %>
      <div class=blog-post>
        <h4><a href='<%= entry.url %>'><%= entry.title %></a></h4>
        <p class='blog-post__published'><%= short_time entry.published %></p>
        <div><%= entry.summary %>...</div>
      </div>
    <% end %>
  </div>
<% end %>
```

Screenshot of the current page

{%asset_img liveform-blog-content.png  Liveform blog%}
