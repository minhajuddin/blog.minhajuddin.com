title: Resisting the temptation to be clever
date: 2013-01-18
tags:
- clever-code
- temptation
- mundane-code
---

The temptation to be clever while programming is very high. You want to show off or use your mad skills to create the most clever piece of code. It gives you a sense of satisfaction which very few things do. However, I've found like most people that it's not the best thing to do for the long term maintainability of projects.

![The temptation to be clever while programming is too damn high](https://substancehq.s3.amazonaws.com/static_asset/50f94ccb03b04d32da0007fe/temptation-to-be-clever.jpg)

Languages like ruby, being very powerful, make this very easy. Like they say *with great power comes great responsibilty*. So, this is some advice for young devs: **Create the cleverest piece of code in your personal, fun projects to satiate your hunger, but when it comes to projects for customers, you owe it to them to be sensible and write mundane code**

Here is a small example of clever vs mundane code.

###Clever code
~~~ruby
  def address_is_empty?(customer)
    [:street, :city, :state, :zip].any?{|method| customer.send(method).nil? || customer.send(method).squish.empty? }
  end
~~~

###Mundane code
~~~ruby
  def address_is_empty?(customer)
    [customer.street, customer.city, customer.state, customer.zip].any?{|prop| prop.nil? || prop.squish.empty? }
  end
~~~
