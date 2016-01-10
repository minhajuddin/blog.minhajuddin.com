title: xclip in a few lines of ruby
date: 2012-09-27
tags:
- xclip
- ruby
- utility
---

**Update**: I happened to check the source code of the 'clipboard' gem and it turns out that it depends on **xclip**. So the code below is just nonsense.

An xclip in a few lines of ruby

~~~ruby
#!/usr/bin/env ruby

require 'clipboard'

if ARGV.empty?
  Clipboard.copy ARGF.readlines.join("\n")
else
  Clipboard.copy ARGV.join(' ')
end
~~~


###Use cases

~~~bash
#copy the html source of cosmicvent.com to clipboard
curl -s http://cosmicvent.com | xc 

#copy date to clipboard
xc $(date)
~~~
