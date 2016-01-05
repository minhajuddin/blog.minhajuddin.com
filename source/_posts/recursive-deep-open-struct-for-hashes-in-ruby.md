title: Recursive/Deep open struct for hashes in ruby
date: 2015-12-09 11:29:43
tags: open struct, ruby, hash
---

So, I had to convert a hash into an open struct to make accessing things easy. Here is the code.

~~~ruby

require 'ostruct'

module DeepStruct

  def to_ostruct

    case self
    when Hash
      root = OpenStruct.new(self)
      self.each_with_object(root) do |(k,v), o|
        o.send("#{k}=", v.to_ostruct)
      end
      root
    when Array
      self.map do |v|
        v.to_ostruct
      end
    else
      self
    end

  end

end

Object.send(:include, DeepStruct)
~~~
