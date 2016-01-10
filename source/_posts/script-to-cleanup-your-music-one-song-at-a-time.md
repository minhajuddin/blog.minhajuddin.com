title: Script to cleanup your music one song at a time
date: 2014-01-27
tags:
- banshee,
- music
---

I have a big library of music with a lot of songs I don't like anymore or songs which were a part of an album from which there was one song which I liked. And whenever my music player starts playing these songs, I hit a keyboard combo which goes to the next song. But these songs would be in my library just waiting to annoy me again. Here is a little ruby script which I wrote from an idea by my friend [Abdul Sattar](codingtales.com).

~~~ruby
#!/home/minhajuddin/.rvm/rubies/ruby-1.9.3-p194/bin/ruby
require 'uri'
require 'fileutils'

song = `banshee --query-uri`.chomp
song = song.gsub(/uri:.*file:\/\//,'')
song =  URI.decode(song)

FileUtils.mv(song, '/home/minhajuddin/badmusic/')
system("/usr/bin/banshee --next")
puts "Moved song '#{song}'"

#mv "$(ruby -e 'require "uri"; puts URI.decode(ARGV.join.gsub(/uri:file:\/\//,""))' $(banshee --query-uri))" /home/minhajuddin/badmusic/
~~~

I also have a keyboard shortcut bound to it which triggers it.

~~~haskell
    , ((modMask, xK_x     ), spawn "/home/minhajuddin/Dropbox/private/scripts/remove-current-song &> /tmp/log") -- %! Remove music from library
~~~

Now whenever banshee plays a song which I don't like I can remove it from my library forever by just hitting 'Windowx+x'
