title: mind stack, a stack of your thoughts and tasks
date: 2011-10-03
---

As a developers, we are always bombarded with information/tasks/thoughts/ideas. And at times, it's very difficult
to remember these things. On a lot of occasions, I start doing
task X and in the middle of it, I remember that I need to "fix something urgently",
so I stop doing X and move to the Urgent task Y, when I am done with Y
I have difficulty remembering what I was doing before that. This is just when I have two tasks, but the level of *nesting* can sometimes go a lot *deeper*.

That's when I read a blog post(can't remember where), which talked
about *saving* your *state of mind*(on post-it notes or notebooks or whatever). And, it has
helped me a lot. I also created a little bash script which helps me *save my state of mind*.
I've been using it for a long time and it has
served me well. I am posting it on github hoping that others may find it
useful. You can check it out at [ Mind::Stack ](https://github.com/minhajuddin/mindstack).

I also have the following line in my `.xmobarrc` so that I can see the top 3
tasks in my status bar.


~~~sh

  , Run Com "/home/minhajuddin/.scripts/s" ["top"] "slotter" 600

~~~


Screenshot of my xmobar

![Mindstack xmobar screenshot](https://substancehq.s3.amazonaws.com/static_asset/4f99dd0c03b04d2e03000034/mindstack-screenshot.png)
