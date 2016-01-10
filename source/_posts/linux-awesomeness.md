title: linux awesomeness
date: 2011-05-03
---

A few minutes ago I learnt that adding *linenos* to the end of the highlight tag
in jekyll adds line numbers to a code snippet. I wanted to add this to all the
hightlight blocks in my blog. I came up with this command:


~~~bash

grep highlight _posts/*.* \
| awk -F : ' { print $1}' \
|  uniq \
| xargs sed -i 's/% *highlight *\([a-z]*\) *%/% highlight \1 linenos %/'

~~~

