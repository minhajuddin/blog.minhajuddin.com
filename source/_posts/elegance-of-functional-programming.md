title: elegance of functional programming
date: 2011-12-12
---

Functional programming allows you to write concise and elegant code. Mainstream
languages like Ruby and C# support a lot of functional programming paradigms,
and learning them makes you a better programmer. Below is a small example which
demonstrates that:


~~~ruby

#6 lines of ugly code
i = 0
tasks = list.tasks
while(i < tasks.length - 2)
  tasks[i].priority.should >= tasks[i + 1].priority
  i += 1
end


#3 lines of elegant functional code
list.tasks.each_cons(2).each do |t1, t2|
  t1.priority.should >= t2.priority
end

~~~

