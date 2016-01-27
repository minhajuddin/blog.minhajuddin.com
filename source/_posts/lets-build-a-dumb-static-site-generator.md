title: Lets build a dumb static site generator
date: 2016-01-27 12:06:52
screencast: dumb-static-site-generator.json
tags:
- Static Site Generator
- How To
---

Static Site Generators are awesome because of their speed and robustness.

There are [many](https://middlemanapp.com/) [static](https://hexo.io/) [site](http://gohugo.io/) [generators](http://octopress.org/).

However, understanding how to use them is not very straightforward to new users. Let us try to build a simple static site generator to better understand the problem.

The problems with managing websites are the issues of publishing, duplication and maintenance. If your website has multiple web pages, then more than 70% of the structure between the pages
is the same. This includes the styling, header, footer, navigation. If you write the html for your pages manually, things become difficult when you need to make changes.
That is why we have static generators to make things more maintainable.

The simplest way to build our generator would be to put the common stuff in one file and the changing content in other files.

For our example we'll put the common markup in a file called `layout.html` and the page specific content in their own pages in a pages folder.

So we are looking for something like below:

~~~
.
├── layout.html
└── pages
    ├── about.html
    └── index.html
~~~

Now with the structure out of the way, we need to decide how we are going to notate the 'changeable area' or 'placeholders' in the layout.
I am using a dumb way to notate placeholder, we'll use `_PAGE_TITLE` for the title and `_PAGE_CONTENT` for the page's content. So our layout looks like this:

~~~html
# layout.html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width">
    <title>_PAGE_TITLE</title>
  </head>
  <body>
    _PAGE_CONTENT
  </body>
</html>
~~~

We can now replace these placeholders with the custom content from pages.

Our index page from our example site looks like below:

~~~html
# pages/index.html
<h1>Welcome to our home</h1>

<p>This is an awesome site</p>
~~~

Now, to finally build the website, we need to do the following:

  1. Read the `layout.html` file.
  2. Read all the individual pages from the `pages` folder
  3. For every page replace the placeholders in the layout page and write it out to `public/page-title.html`

Here is our final script:

~~~ruby
#!/usr/bin/env ruby

require 'fileutils'

# this generates a static site into a public folder for the current directory

# create the folder
FileUtils.mkdir_p "public"

# read the layout
layout = File.read("layout.html")


# read the pages
Dir["pages/*html"].each do |page_filepath|
  page = File.read(page_filepath)
  # replace the page title and page content
  title = File.basename(page_filepath) # we'll use the filename as the title
  rendered_page = layout.gsub("_PAGE_TITLE", title)
  rendered_page = rendered_page.gsub("_PAGE_CONTENT", page)

  # write it out
  File.write("public/#{title}", rendered_page)
  puts "generated #{title}"
end

puts "DONE"
~~~

[By, the way I am building an Automatic Deployment solution which can build and deploy Hugo, Hexo, Middleman and Octopress sites to Github pages](https://zammu.in/?invitation_code=MINHAJUDDIN)

I created a small asciicast too, you can watch it below:

