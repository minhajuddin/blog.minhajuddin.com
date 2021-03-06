title: How to get a git archive including submodules
tags:
  - git
  - submodules
  - bash
date: 2016-01-10 21:28:29
---


Here is a small script I wrote to get a git archive of your repository containing all the submodules with the root repository.


~~~sh
#!/bin/bash
#
# Author Khaja Minhajuddin
# File name: git-archive-all
# cd root-git-repo; git-archive-all

set -e
set -C # noclobber

echo "> creating root archive"
export ROOT_ARCHIVE_DIR="$(pwd)"
# create root archive
git archive --verbose --prefix "repo/" --format "tar" --output "$ROOT_ARCHIVE_DIR/repo-output.tar" "master"

echo "> appending submodule archives"
# for each of git submodules append to the root archive
git submodule foreach --recursive 'git archive --verbose --prefix=repo/$path/ --format tar master --output $ROOT_ARCHIVE_DIR/repo-output-sub-$sha1.tar'

if [[ $(ls repo-output-sub*.tar | wc -l) != 0  ]]; then
  # combine all archives into one tar
  echo "> combining all tars"
  tar --concatenate --file repo-output.tar repo-output-sub*.tar

  # remove sub tars
  echo "> removing all sub tars"
  rm -rf repo-output-sub*.tar
fi

# gzip the tar
echo "> gzipping final tar"
gzip --force --verbose repo-output.tar

echo "> moving output file to $OUTPUT_FILE"
mv repo-output.tar.gz $OUTPUT_FILE

echo "> git-archive-all done"
~~~
