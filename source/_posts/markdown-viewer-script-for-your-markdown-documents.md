title: markdown viewer script for your markdown documents
date: 2012-03-16
tags:
- markdown
- viewer
- util
---

### Update
Made the script more awesome by adding code highlighting using pygments. Download the pygments file from https://substancehq.s3.amazonaws.com/assets/pygments-18ba01c79ccfbe022848bccbb4413b59.css , and the markdown stylesheet from https://substancehq.s3.amazonaws.com/static_asset/4fbd972603b04d30730006da/markdown.css
- - -
Here is a script which I use for reading my markdown documents in the browser. It uses css from [https://github.com/clownfart/Markdown-CSS]( https://github.com/clownfart/Markdown-CSS ). Here is a sample page with that css [http://planetzxy.com/markdown/]( http://planetzxy.com/markdown/). And here is the script:


~~~ruby

#~/.scripts/markdown-viewer

#!/usr/bin/env ruby
require 'rubygems'
require 'redcarpet'
require 'erb'
require 'pygments'

class CustomHtmlRenderer < Redcarpet::Render::HTML
  def block_code(code, lang)
    Pygments.highlight code, :lexer => lang
  end
end

#@markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true)
@markdown = Redcarpet::Markdown.new(CustomHtmlRenderer, autolink: true, fenced_code_blocks: true, tables: true, no_intra_emphasis: true, strikethrough: true, superscript: true)


@template = ERB.new(<<EOF
<!DOCTYPE html>
<html>
  <head>
    <title><%= title %></title>
    <link href="https://raw.github.com/clownfart/Markdown-CSS/master/markdown.css" rel="stylesheet"></link>
    </head>
  <body>
    <%= body %>
  </body>
</html>
EOF
)

def view_markdown(filename)

  if !File.exists?(filename)
    puts "#{filename} does not exist."
  end

  opfilename = "/home/minhajuddin/tmp/mdrendered/#{File.basename(filename)}.html"
  File.open(opfilename, 'w') do |f|
    file_content = File.read(filename)
    title = file_content.lines.first.chomp
    body = @markdown.render(file_content)
    f.write @template.result(binding)
  end

  system("gnome-open #{opfilename}")

end

ARGV.each do |arg|
  view_markdown(arg)
end

~~~

