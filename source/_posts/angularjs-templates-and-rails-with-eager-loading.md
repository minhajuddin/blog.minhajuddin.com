title: Angularjs templates and rails with eager loading
date: 2013-04-28
tags:
- angularjs
- rails
- templates
- eager-load
---

Angularjs loads the templates used through the [ng-include] (http://docs.angularjs.org/api/ng.directive:ngInclude) directive on the fly. This might cause a lot of requests to be made to your server which is not a good thing.

This solution allows you to load all your templates in one go and it will actually shove all your templates into your final application.js file.

**<s>GOTCHA: If you use this approach you will have to change this file whenever a template changes in development, if you don't it won't recompile this file which will cause your app to use old templates. This happens only in development and it's a pain, I don't know how to solve it yet. Anyone who knows can help me out here :)</s>**

Update:
[Steven Harman](https://gist.github.com/stevenharman/8493700) has shared a solution which uses `depend_on`, I have amended my script to use it.

~~~~erb
//app/assets/javascripts/ngapp/templates.js.erb
  <% environment.context_class.instance_eval { include ActionView::Helpers::JavaScriptHelper } %>
angular.module('templates', []).run(function($templateCache) {
  <% Dir.glob(Rails.root.join('app','assets','templates', '*.haml')).each do |f| %>
    <% depend_on(f) %>
    $templateCache.put("<%= File.basename(f).gsub(/\.haml$/, '')  %>", <%= Haml::Engine.new(File.read(f)).render.to_json %>);
  <% end %>
});

~~~~

This loads all the templates from your `/app/assets/templates` directories which have an extension `.haml`. And you can use templates just using their filename without the haml extension. e.g. a template called `app/assets/templates/filter.html.haml` can be included using

~~~~haml
%div(ng-include="'filter.html'")
~~~~

Make sure you have `//= require ./templates` in your `application.js` and that you include `'templates'` as a dependency in your angular module

~~~~javascript
AA.root = angular.module('root', [.., 'templates',..])
~~~~
