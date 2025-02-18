title: That one time when office365 was marking our emails as spam
date: 2025-02-17 21:06:00
tags:
- email
- elixir
- office365
- spam
- erlang
- bug
---

In 2017, I was working for a company that was building an aggregation platform
for hotel bookings. For some weird reason, for all the email we sent,
recipients that used Office365 always had our emails going to their spam
folder. This was a problem because our emails were kind of important with all
the booking information.

This was kind of a head scratcher 😕, because were were using an office 365
SMTP server to send these emails, so it was weird that they were being marked
as spam. Also, gmail and other email providers were not marking our emails as
spam.

After some investigation, I didn't find anything weird about our email content
or how we were using the library which was used to send emails. This was an
Elixir app, and we were using the https://github.com/fewlinesco/bamboo_smtp
library.

The first thing I tried was to send an email to my personal email address and
download the full message to see if there was anything weird going on. I didn't
find anything strange.

Then, I figured, I could use another library to send out emails. I knew ruby,
so I used https://github.com/benprew/pony to send out email from the same SMTP
server. And, NOW the emails were not marked as spam. Bingo, I knew there was
something wrong with our elixir library. I dumped out a few emails from both
the ruby and elixir libraries and compared them side by side using a diff tool.
The only difference between the emails was the multi part delimiter. And, I
also found that the elixir library had a hard-coded it. And, for some reason
this was causing the emails to be marked as spam by office365. (Office 365 was
probably using this as a signal to mark the email as spam).

Once I knew the problem, the fix was easy. I just had to change the delimiter,
which was a short PR:  https://github.com/fewlinesco/bamboo_smtp/pull/39/files

And, that was it. Our emails were no longer marked as spam by office365. 🎉
