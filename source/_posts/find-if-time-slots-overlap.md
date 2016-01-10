title: Find if time slots overlap
date: 2013-02-19
tags:
- algorithm
- time-overlap
---

I had to write some code to see if the input time slots on a given day overlapped.
I gave this problem to my sister, to come up with an algorithm. She came up with
a nice solution which hadn't crossed my mind. See, if your solution is as good
as hers :)


    #sample containing overlapping times
    [{:start_time=>'2013-02-20 00:00:00', :end_time=>'2013-02-20 01:00:00'},
     {:start_time=>'2013-02-20 02:00:00', :end_time=>'2013-02-20 03:00:00'},
     {:start_time=>'2013-02-20 07:30:00', :end_time=>'2013-02-20 09:00:00'},
     {:start_time=>'2013-02-20 04:30:00', :end_time=>'2013-02-20 05:00:00'},
     {:start_time=>'2013-02-20 04:10:00', :end_time=>'2013-02-20 06:00:00'},
     {:start_time=>'2013-02-20 01:00:00', :end_time=>'2013-02-20 02:00:00'},
     {:start_time=>'2013-02-20 03:00:00', :end_time=>'2013-02-20 04:00:00'},
     {:start_time=>'2013-02-20 07:00:00', :end_time=>'2013-02-20 08:00:00'},
     {:start_time=>'2013-02-20 06:00:00', :end_time=>'2013-02-20 07:00:00'},
     {:start_time=>'2013-02-20 09:00:00', :end_time=>'2013-02-20 10:00:00'}]

    #sample without overlapping times
    [{:start_time=>'2013-02-20 00:00:00', :end_time=>'2013-02-20 01:00:00'},
     {:start_time=>'2013-02-20 07:00:00', :end_time=>'2013-02-20 08:00:00'},
     {:start_time=>'2013-02-20 06:00:00', :end_time=>'2013-02-20 07:00:00'},
     {:start_time=>'2013-02-20 01:00:00', :end_time=>'2013-02-20 02:00:00'},
     {:start_time=>'2013-02-20 08:00:00', :end_time=>'2013-02-20 09:00:00'},
     {:start_time=>'2013-02-20 03:00:00', :end_time=>'2013-02-20 04:00:00'},
     {:start_time=>'2013-02-20 04:00:00', :end_time=>'2013-02-20 05:00:00'},
     {:start_time=>'2013-02-20 05:00:00', :end_time=>'2013-02-20 06:00:00'},
     {:start_time=>'2013-02-20 02:00:00', :end_time=>'2013-02-20 03:00:00'},
     {:start_time=>'2013-02-20 09:00:00', :end_time=>'2013-02-20 10:00:00'}]


<a href='#solution' onclick='document.getElementById("solution").className="";'>Click here for the solution</a><div id='solution' class='hidden'>

~~~ruby
    def times_overlap?(times)
      times.sort_by{|x| x[:start_time]}
      times.each_cons(2){|f,s| return false if f[:end_time] > s[:start_time]}
      return true
    end
~~~

</div>
