title: easily show current version number of your app, stackoverflow style
date: 2011-07-25
---

When your app is deployed in multiple environments (staging, production),
knowing the version number of your deployed app helps a lot, in debugging.
[Stackoverflow](http://stackoverflow.com) does a great job of showing a
meaningful version in it's footer. Currently it shows that it's version number
as `rev 2011.7.22.2`. This tells us that the code running stackoverflow was last 
updated on 2011.7.22, and that it was updated twice on that same day.

You can set up a similar thing pretty easily if you are using git and rails (rails in
not really needed, but my example shows it using rails). All you need to do is
add the following line to your `config/application.rb`

  
~~~ruby

#config/application.rb
module Khalid
  class Application < Rails::Application
  .
  .
  .
    #cache the version as long as the app is alive
    #2011.07.25.4c76f53
    VERSION =`git --git-dir="#{Rails.root.join(".git")}" --work-tree="#{Rails.root}" log -1 --date=short --format="%ad-%h"|sed 's/-/./g'`
  .
  .
  .
  end
end
  
~~~


This gives you a constant called `Khalid::Application::VERSION` which will give you a nice version 
number containing the commit sha id and the date like this: `2011.07.25.4c76f53`
