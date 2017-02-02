title: Lightweight xml utility to pluck elements
date: 2017-02-02 16:14:42
tags:
- Xml Pluck
- Ruby
---

[jq](https://stedolan.github.io/jq/) is an awesome utility for parsing and transforming json via the command line. I wanted something similar for xml.
The following is a short ruby script which does a tiny tiny (did I say tiny?) bit of what jq does for xml. Hope you find it useful.

```ruby
#!/usr/bin/env ruby
# Author: Khaja Minhajuddin

require 'nokogiri'
require 'parallel'
require 'etc'

if ARGV.count < 2
  puts <<-EOS
  Usage:
    xml_pluck xpath file1.xml file2.xml

  e.g.
    xml_pluck "//children/name/text()" <(echo '<?xml version="1.0"?><children><name>Zainab</name><name>Mujju</name></children>')
    # prints
    Zainab
    Mujju
  EOS
  exit -1
end

xpath = ARGV.shift
Parallel.each(ARGV, in_processes: Etc.nprocessors) do |file|
  doc = Nokogiri::XML(File.read(file))
  puts doc.xpath(xpath)
end
```
