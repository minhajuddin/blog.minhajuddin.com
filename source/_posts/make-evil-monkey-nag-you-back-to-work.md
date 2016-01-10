title: make evil monkey nag you back to work
date: 2011-12-16
---

###Update: fixed the cron entry

I've read a very interesting article about ["Why programmers work at night"]( http://swizec.com/blog/why-programmers-work-at-night/swizec/3198 ).
One of the points the author talks about is "how we get engrossed in
twitter/hacker news/reddit". I've felt the same. I think one of the reasons why
we(programmers/developers) spend a lot of our time on twitter/hacker news/reddit
is, because, we don't have any idea of the time. Time just flies by. So, I
created a small ruby script which nags you to get back to work :)

##~/.scripts/nagger

~~~ruby

#!/usr/bin/env ruby
require 'time'

exit if File.exists?("/tmp/stop-nagging")
#see what I did here ;)

#run the below command to find your display
#env | grep DISPLAY
ENV['DISPLAY'] = ':0.0'

last_line = `tail -2 ~/.gtimelog/timelog.txt`.lines.map{|x| x.chomp}.reject{|x| x.empty?}.reverse.first
minutes = ((Time.now - Time.parse(last_line[11, 5])) / 60).round
evil_monkey = File.expand_path File.join(File.dirname(__FILE__), 'evil-monkey.gif')

if minutes > 30
  `notify-send -i '#{evil_monkey}' "It's been #{minutes} minutes since your last log"`
end

~~~


##cron entry

~~~bash

0,5,10,15,20,25,30,35,40,45,50,55 * * * * /bin/bash -l -c '/home/minhajuddin/.scripts/nagger'

~~~


![Evil monkey nagging me to get back to work](https://substancehq.s3.amazonaws.com/static_asset/4f99dd1003b04d2e0300003f/evil-monkey-nagger.png)


Hope it helps you get back to work too :). By the way, I use the awesome
[gtimelog](http://mg.pov.lt/gtimelog/) app to log my time.
