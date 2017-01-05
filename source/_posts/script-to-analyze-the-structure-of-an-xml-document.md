title: Script to analyze the structure of an xml document
date: 2017-01-05 16:22:24
tags:
- Nokogiri
- Xml
- Analyze
- Structure
---

While working with XML data, you often don't find the WSDL files and may end up
manually working through the document to understand its structure. At my current project
I ran into a few hundred XML files and had to analyze them to understand the data available.
Here is a script I created which prints all the possible nodes in the input files

```
#!/usr/bin/env ruby
# Author: Khaja Minhajuddin <minhajuddin.k@gmail.com>

require 'nokogiri'

class XmlAnalyze
  def initialize(filepaths)
    @filepaths = filepaths
    @node_paths = {}
  end

  def analyze
    @filepaths.each { |filepath| analyze_file(filepath) }
    @node_paths.keys.sort
  end

  private
  def analyze_file(filepath)
    @doc = File.open(filepath) { |f| Nokogiri::XML(f) }
    analyze_node(@doc.children.first)
  end

  def analyze_node(node)
    return if node.is_a? Nokogiri::XML::Text
    add_path node.path

    node.attributes.keys.each do |attr|
      add_path("#{node.path}:#{attr}")
    end

    node.children.each do |child|
      analyze_node(child)
    end

  end

  def add_path(path)
    path = path.gsub(/\[\d+\]/, '')
    @node_paths[path] = true
  end
end

if ARGV.empty?
  puts 'Usage: ./analyze_xml.rb file1.xml file2.xml ....'
  exit(-1)
end

puts XmlAnalyze.new(ARGV).analyze

```

It outputs the following for the xml below

```xml
<?xml version="1.0" encoding="UTF-8"?>
<root>
  <person>
    <name type="full">Khaja</name>
    <age>31</age>
  </person>
  <person>
    <name type="full">Khaja</name>
    <dob>Jan</dob>
  </person>
</root>
```

```text
/root
/root/person
/root/person/age
/root/person/dob
/root/person/name
/root/person/name:type
```

Hope you find it useful!
