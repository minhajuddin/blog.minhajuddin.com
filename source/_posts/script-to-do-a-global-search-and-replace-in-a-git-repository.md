title: script to do a global search and replace in a git repository
date: 2011-12-13
---

There are many instances where I had to replace some variable name in all my files.
I use a small script to do this, Hope it helps you too.


~~~bash

#!/bin/bash
#~/.scripts/git-sub
#Author: Khaja Minhajuddin <minhajuddin@cosmicvent.com>
#script which does a global search and replace in the git repository
#it takes two arguments
#e.g. git sub OLD NEW

old=$1
new=$2

for file in $(git grep $old | cut -d':'  -f 1 | uniq)
do
  echo "replacing '$old' with '$new' in '$file'"
  sed -i -e "s/$old/$new/g" $file
done

~~~


Just remember to add it to a directory which is in the `$PATH`. I have it in my
`~/.scripts` directory which is included in the `$PATH`. Name it `git-sub` and give it
executable permissions using `chmod +x ~/.scripts/git-sub`. Now, you can just call `git sub old_var new_var`
on terminal and it will do a global search and replace of all the files in the repository.

