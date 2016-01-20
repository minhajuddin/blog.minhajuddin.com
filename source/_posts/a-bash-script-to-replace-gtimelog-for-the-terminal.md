title: A bash script to replace gtimelog for the terminal
date: 2016-01-20 09:38:44
tags:
- bash
- gtimelog
- time
---

I have been using this script to log my time for a long time, thought I would share it.

~~~sh
# Usage:
# log time
# $ gl browsing redding again
# $ gl finished Hugo recipe for zammu.in
#
# check log
# $ gl
#
# check last 2 logs
# $ gl t -n2
#
# edit the timelog file
# $ gl e

function gl() {
gtimelog=~/timelog.txt

[ $# -eq 0 ]  && tail $gtimelog $2 && return

case $1 in
  t|c) tail $gtimelog $2
    ;;
  a) echo "$(date "+%Y-%m-%d %H:%M"): $(tail -1 $gtimelog | sed -e 's/^[0-9 :-]*//g')"  >> $gtimelog
    ;;
  e) vi $gtimelog
    ;;
  *) echo "$(date "+%Y-%m-%d %H:%M"): ${@/jj/**}" >> $gtimelog
    ;;
esac
}
~~~
