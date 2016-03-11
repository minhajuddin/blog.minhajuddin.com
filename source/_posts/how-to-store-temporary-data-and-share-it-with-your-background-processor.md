title: How to store temporary data and share it with your background processor
date: 2016-03-11 18:40:36
tags:
- Ruby
- Redis
---

In my current project, I had to store some temporary data for a user and let a few background
processors have access to it. I wrote something small with a dependency on Redis which does the job.

It allows me to use `current_user.tmp[:token_id] = "somedata here"` and then access it
in the background processor using `user.tmp[:token_id]` which I think is pretty neat.

Moreover, since my use case needed this for temporary storage, I set it to auto expire in 1 day.
If yours is different you could change that piece of code.

~~~ruby
# /app/models/user_tmp.rb
class UserTmp
  attr_reader :user
  def initialize(user)
    @user = user
  end

  EXPIRATION_SECONDS = 1.day
  SERIALIZER = Marshal

  def [](key)
    serialized_val = Redis.current.get(namespaced_key(key))
    SERIALIZER.load(serialized_val) if serialized_val
  end
  def []=(key, val)
    serialized_val = SERIALIZER.dump(val)
    Redis.current.setex(namespaced_key(key), EXPIRATION_SECONDS, serialized_val)
  end

  private
  def namespaced_key(key)
    "u:#{user.id}:#{key}"
  end
end
~~~

And here is the user class

~~~ruby
# /app/models/user.rb
class User < ActiveRecord::Base
  #...

  def tmp
    @tmp ||= UserTmp.new(self)
  end

  #...
end
~~~


Hope you find it useful :)
