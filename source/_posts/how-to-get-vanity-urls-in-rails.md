title: how to get vanity urls in rails
date: 2011-04-17
---

Getting vanity urls to work in rails is very simple. Let's say you want to allow
your users to expose their Profiles through a facebook like url
`http://www.facebook.com/GreenDay`. This is what you need to change in your
routes file.

The `except => :show` on line#5 makes the resources helper skip the show route.
And line#9 which should be at the end of the routes file, creates a route called
profile which will be used for all the profile *show* links automatically.
That's it now your application has vanity urls, whenever someone clicks on a
profile#show link they will be taken to /:slug. Obviously in this case the slug
is assumed to be unique.


~~~ruby

Funky::Application.routes.draw do
  .
  .
  .
  resources :profiles, :except => [:show]
  .
  .
  #at the end of the routes file
  get ':slug' => 'profiles#show', :as => 'profile'
end

~~~


###Update###
One of the readers emailed me asking what the controller code would look like. Here it is:


~~~ruby

#app/models/profile.rb
class Profile < ActiveRecord::Base
  #should have a column called "slug"
end
#app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
  def show
    @profile = Profile.find_by_slug(params[:slug])
  end
end

~~~


###References###

 - [http://guides.rubyonrails.org/routing.html#naming-routes](http://guides.rubyonrails.org/routing.html#naming-routes)
 - [http://kconrails.com/2010/01/25/vanity-urls-for-ruby-on-rails-routes/](http://kconrails.com/2010/01/25/vanity-urls-for-ruby-on-rails-routes/)
