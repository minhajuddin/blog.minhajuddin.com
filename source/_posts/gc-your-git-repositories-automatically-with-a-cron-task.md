title: gc your git repositories automatically with a cron task
date: 2011-12-09
---

I have a lot of git code repositories, and I usually [*gc* (garbage collect)](http://linux.die.net/man/1/git-gc) them
manually by running the `git gc` command every now and then. Tasks like these
are prime candidates for automating with *cron*. Below is a cron entry and the
script which `gc`s my repositories. Hope you guys find it useful.

###the script

~~~bash

#!/bin/bash
#author: Khaja Minhajuddin
#email: minhajuddin.k@gmail.com
#path /home/minhajuddin/.cron/reboot.sh
#description: script which is executed everytime computer starts

#git gc repos
REPO_DIRS=$(cat <<EOS
$HOME/repos
$HOME/repos/core
EOS
)

for repo_dir in $REPO_DIRS
do
  echo "checking for git repos in $repo_dir"
  for repo in $(ls $repo_dir)
  do
    cd $repo_dir/$repo
    if [[ -d .git ]]
    then
      echo "garbage collecting $repo"
      git gc
    fi
  done
done

~~~


###the crontab entry

~~~bash

$ crontab -e
#add the line below into the editor and save it
@reboot   $HOME/.cron/reboot.sh

~~~


Bonus tip: If you have a gitosis server, put the following script at `~git/.cron/reboot.sh` and
perform the above step for your *git user*.

###the gitosis git user script

~~~bash

#!/bin/bash

for repo in $(ls ~/repositories)
do
  cd ~/repositories/$repo
  echo "garbage collecting $repo"
  git gc
done

~~~

