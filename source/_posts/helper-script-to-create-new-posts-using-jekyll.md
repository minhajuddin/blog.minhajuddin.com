title: helper script to create new posts using jekyll
date: 2010-10-01
---

Alright, so, whenever I try to write up a blog post Jekyll wants me to do a lot of redundant 
and painful stuff. To create a blog post, you'll have to do the following:

- Create a filename called 2010-10-01-helper-script-to-create-new-posts-using-jekyll.markdown
  which has a timestamp, hyphens and a title which is kind of a pain to type.
- And once you have this file you'll have to put up some yaml front matter: the
  title, and the layout is the minimum, Here you are typing the title again.

It's not a big deal, but it's still annoying. So, I came up with a small ruby
script called new.rb, which basically automates this stuff.


~~~ruby

#!/usr/bin/env ruby

# Script to create a blog post using a template. It takes one input parameter
# which is the title of the blog post
# e.g. command:
# $ ./new.rb "helper script to create new posts using jekyll"
#
# Author:Khaja Minhajuddin (http://minhajuddin.com)

# Some constants
TEMPLATE = "template.markdown"
TARGET_DIR = "_posts"

# Get the title which was passed as an argument
title = ARGV[0]
# Get the filename
filename = title.gsub(' ','-')
filename = "#{ Time.now.strftime('%Y-%m-%d') }-#{filename}.markdown" 
filepath = File.join(TARGET_DIR, filename)

# Create a copy of the template with the title replaced
new_post = File.read(TEMPLATE)
new_post.gsub!('TITLE', title);

# Write out the file to the target directory
new_post_file = File.open(filepath, 'w')
new_post_file.puts new_post
new_post_file.close

puts "created => #{filepath}"

~~~



[Download the gist][1]

  [1]:http://gist.github.com/604999#comments
