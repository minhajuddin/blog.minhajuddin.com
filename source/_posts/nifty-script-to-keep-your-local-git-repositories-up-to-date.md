title: Nifty script to keep your local git repositories up to date
date: 2012-10-29
tags:
- git
- automatic
- update
---

A lot of times when I try to hack on my code, I find that my git repository doesn't have the latest commits. And in a lot of these instances I don't have an internet connection (either because I am  at a client's location or because there is a power cut). Here is a little script which I use to keep all my local repos up to date automatically.

~~~sh
#!/bin/bash
#Author: Khaja Minhajuddin
#location: $HOME/.scripts/git-update
ROOT_DIR="$HOME/r"

for repo in $(ls $ROOT_DIR)
do
  cd "$ROOT_DIR/$repo"
  for remote in $(git remote)
  do
    echo "fetching $repo $remote"
    git fetch $remote
  done
done
~~~

~~~sh
#crontab entry
@reboot /bin/bash -l -c 'cd /home/minhajuddin/ && $HOME/.scripts/git-update'
~~~

The git-update script should be pretty self explantory. I am looking at all the dirs under my "repos root dir" and for each of those I am finding the remotes and fetching them one at a time. The crontab entry on the other hand makes sure that every time I start my computer this script is executed. Also, I can run `git update` whenever I am online to get fetch all the new commits for my repos.
