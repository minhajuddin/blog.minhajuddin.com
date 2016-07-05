title: Algorithm to compute downtime of a service/server
date: 2016-07-05 08:43:42
tags:
- algorithm
- downtime calculation
---

I am working on an open source side project called [webmonitorhq.com](http://webmonitorhq.com/)
It notifies you when your service goes down. It also stores the events when a service goes down
and comes back up. And I wanted to show the uptime of a service for a duration of 24 hours, 7 days etc,.

This is the algorithm I came up with, Please point out any improvements that can be made to it. I'd love to hear them.

The prerequisite to this algorithm is that you have data for the UP events and the DOWN events

I have a table called events with an event string and an event_at datetime

| events                                 |
| ------------------------------------   |
| id                                     |
| event (UP or DOWN)                     |
| event_at (datetime of event occurence) |

## Algorithm to calculate downtime

  1. Decide the duration (24 hours, 7 days, 30 days)
  2. Select all the events in that duration
  3. Add an UP event at the end of the duration
  4. Add a inverse of the first event at the beginning of this duration
    e.g. if the first event is an UP add a DOWN and vice versa
  5. Start from the first UP event after a DOWN event and subtract the DOWN event_at from the UP event_at, do this till you reach the end. This gives you the downtime
  6. Subtract duration from downtime to get uptime duration

e.g.
  1. 24 hour duration. Current Time is 00hours
  2. UPat1 DOWNat5 UPat10
  3. UPat1 DOWNat5 UPat10 UPat24
  4. DOWNat0 UPat1 DOWNat5 UPat10 UPat24
  5. UPat1 - DOWNat0 + UPat10 - DOWNat5
    Downtime = 1 + 5
  6. 24 - 6 => 18

