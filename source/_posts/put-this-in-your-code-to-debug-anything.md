title: Put this in your code to debug anything
date: 2016-03-03 09:24:46
tags:
---

Aaron Patterson wrote [a very nice article on how he does deubgging](https://tenderlovemaking.com/2016/02/05/i-am-a-puts-debuggerer.html).

Here is some more code to make your debugging easier.

~~~ruby

class Object
  def dbg
    self.tap do |x|
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
      puts x
      puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    end
  end
end

# now you can turn the following:
get_csv.find{|x| x[id_column] == row_id}

# into =>
get_csv.dbg.find{|x| x[id_column.dbg] == row_id.dbg}.dbg

~~~
