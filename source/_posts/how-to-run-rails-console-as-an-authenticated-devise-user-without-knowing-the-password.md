title: How to run rails console as an authenticated devise user without knowing the
  password
date: 2012-10-29
tags:
- rails
- devise
- authenticate
- production
- console
---

I maintain a few rails apps for my clients (running in production). And sometimes certain bugs occur only for specific users. There are two ways to debug these issues:

 1. Get the user to show you how the bug occurs
 2. Try it out by signing into the site as that user

Now option 2 isn't practical as your users don't want to share their passwords with you. What I do to get around this fact is test the user interface through `rails console` in production. Now, we use devise for authentication so it wasn't so hard to sign in as the desired user. All you need to run in your production rails console is:

~~~ruby
class User
  def validate_password?(pwd)
    true
  end
end
~~~

where `User` is your devise model. Now to signin as the desired user (foo@mailinator.com) from the console you run

~~~ruby
#to sign in
app.post '/users/sign_in',  user: {email: 'foo@mailinator.com', password: "<doesn't matter>"}
#to test it out
app.get '/desired-url'
puts app.response
~~~

Hope that helps
