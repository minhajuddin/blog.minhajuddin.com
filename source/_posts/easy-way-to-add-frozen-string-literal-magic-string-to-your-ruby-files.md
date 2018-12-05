title: Easy way to add frozen_string_literal magic string to your ruby files
date: 2018-12-05 15:19:29
tags:
- ruby
- magic strings
---


```sh
comm -23 \
  <(git ls-files|sort) \
  <(git grep -l 'frozen_string_literal'|sort) \
  | grep -E '\.rb$' \
  | xargs -n1 sed -i '1s/^/# frozen_string_literal: true\n\n/'
```

The code is pretty self explanatory, we get a list of all the files in our repo
and then remove the ones which already have the magic string and then filter it
to just the ruby files and finally adding the magic string to all the files.
