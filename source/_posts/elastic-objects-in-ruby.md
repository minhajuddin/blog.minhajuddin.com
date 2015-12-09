title: Elastic objects in ruby
date: 2015-12-09 13:08:30
tags: elastic object, ruby, metaprogramming
---

Here is an example of an elastic object wrapper in ruby

~~~ruby
class ElasticObject

  attr_reader :object
  alias_method :value, :object
  def initialize(object)
    @object = object
  end

  def method_missing(method, *args, &block)
    return ElasticObject.new(object.send(method, *args, &block)) if object.respond_to?(method)

    return ElasticObject.new(nil) if !object.is_a?(Hash)

    result = [method] if key?(method)
    result = [method.to_s] if key?(method.to_s)
    return ElasticObject.new(result)
  end

end

emp = ElasticObject.new({"name" => "Mujju", "age" => 1})


puts emp.dob.month # => nil
puts emp.name # => "Mujju"

~~~
