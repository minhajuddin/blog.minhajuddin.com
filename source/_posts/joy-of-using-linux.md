title: joy of using linux
date: 2011-06-09
---

I've been using [ linux ](http://en.wikipedia.org/wiki/Linux) for a 
long time now, and I have been loving it since the first day. However when
someone asks me *Why linux?* I find it difficult to explain. And then, I give up
and fallback to *Linux is free* (as in free beer). Well, I have had a series of
fortunate events yesterday, which (I hope) will explain my love for linux.

So, yesterday was a special day for me, we launched a webapp specifically
designed to publish *results* of different exams (You can check it out at
[Ramanujan Result Engine](http://resultengine.net "Ramanujan Result Engine")). To publish the results we
(me and my colleague Nagaraju) had to go the university at 08:30 in the morning to get the CDs which had the results' data.
Now, we were given the format of the data (just the column names) 
one day in advance. And we tested our data importing utility assuming that the
data would be a simple [CSV file](http://en.wikipedia.org/wiki/Comma-separated_values "Comma Seperated Value files").
And as soon as the CDs were handed out we tried to extract the data, but it turned out that the zipped
files which had the data were password protected and that some minister
would release the password at 09:00. At this point I checked if I could unzip
the data through the command prompt (I was just thinking of creating a script
which would automate the unzipping and uploading once the password was given).
That's when a good and a bad thing happened, when we entered the wrong password it didn't
extract the files but it printed a messages telling us which files it was unable
to extract. We were happy that we atleast knew the directory structure and filenames and that we could
just write a script to automate everything, but to our horror we found out that
the university folks had given us the data as [mdb files](http://en.wikipedia.org/wiki/MDB "Microsoft Access Database files").
I was stumped, I thought I had to get to a windows machine with *microsoft
access* on it and then export it to a csv file and then run it through our
uploader, this seemed like a long process which would atleast take a few hours.

As a last resort, I googled for *mdb to csv conversion* to see if someone knew a way
 to do it on linux, and voila I found [an awesome page which documented the use of
 mdb-export](http://manpages.ubuntu.com/manpages/hardy/man1/mdb-export.1.html "mdb-export man page") which looked like it would do our job. 
 I was stoked with happiness. Here we were trying to be the first guys who could
 get the results online, disillusioned by the format of data given to us and in
 no time we found a way back into the game, thanks to the *awesome linux community*.
 
 I quickly ran `sudo apt-get install mdb-export` on the terminal, 
 I got a message `no package found`, Hmm, I
 thought it might have already been installed (by the ubuntu default packages)
 and ran `mdb-export` and ubuntu says please install `mdbtools`, Sweet :).
 Ran `sudo apt-get install mdbtools`, read the manpages, found out that it
 needed to know the name of the table to export. Googled again, found out that
 mdb-tables (which is part of mdb-tools) would give me the table names. Now,
 finally when the password was released by the minister, I did my mdb-export
 dance, and uploaded the results to our servers. 
 
 It is an experience I'll cherish for a long time. I am sure we were the first guys 
 who published the EAMCET results (we did it within 5 minutes). Other linux users 
 may just give a big *meh* to this incident, but I am sure you have many such 
 small incidents where the *uber awesome linux community* helped you out. 
 One of the biggest things that I love about linux is it's *community*. 
 Linux wouldn't have been what it is without it's community, and I am forever indebted to it.
