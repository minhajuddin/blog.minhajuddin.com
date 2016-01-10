title: how to change the rails root url based on the current user or role
date: 2011-10-24
---

In my latest rails app, I needed the root url to be different based on the logged in user, i.e. if the user was logged in I wanted to show one page, if not I wanted to show a generic page. Rails 3 makes this very easy.

While drawing routes, rails gives you ability to [*constrain*](http://edgeguides.rubyonrails.org/routing.html#advanced-constraints) the route based on *anything* in the incoming request. As it happens, I was using [devise](https://github.com/plataformatec/devise) for my authentication needs and devise uses [warden](https://github.com/hassox/warden) which fills up the request's **env** with the current user, Once I had the current user it was a simple conditional statement was all that was needed to get my routes working. Checkout the below implementation to see how it's done:


~~~ruby

#lib/role_constraint.rb

class RoleConstraint
  def initialize(*roles)
    @roles = roles
  end

  def matches?(request)
    @roles.include? request.env['warden'].user.try(:role)
  end
end

#config/routes.rb
root :to => 'admin#index', :constraints => RoleConstraint.new(:admin) #matches this route when the current user is an admin
root :to => 'sites#index', :constraints => RoleConstraint.new(:user) #matches this route when the current user is an user
root :to => 'home#index' #matches this route when the above two matches don't pass

~~~

