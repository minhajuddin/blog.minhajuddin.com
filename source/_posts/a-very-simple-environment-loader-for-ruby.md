title: A very simple environment loader for ruby
date: 2016-02-10 21:11:18
tags:
- Environment Loader
---

There are [many](https://github.com/laserlemon/figaro) [gems](https://github.com/bkeepers/dotenv)
which do app configuration loading for ruby.
However, you don't really need a gem to do environment loading. Here is a
snippet of code which does most of what you want.


~~~ruby
class EnvLoader
  def load(path)
    YAML.load_file(path).each do |k, v|
      ENV[k] = v.to_s
    end
  end
end
~~~

And put this at the top of your application

~~~ruby
require_relative '../app/classes/env_loader.rb'
EnvLoader.new.load(File.expand_path('../../env', __FILE__))
~~~

Here are some specs

~~~ruby
# specs for it
require 'rails_helper'

describe EnvLoader do
  describe '#load' do
    it 'imports stuff into ENV' do
      temp = "/tmp/#{Time.now.to_i}"
      File.write(temp, <<-EOS.strip_heredoc)
      SECRET: This is awesome
      FOO: 33
      EOS

      EnvLoader.new.load(temp)
      expect(ENV['FOO']).to eq('33')
      expect(ENV['SECRET']).to eq("This is awesome")
    end
  end
end
~~~
