title: Bash completion script for mix
date: 2016-12-23 17:02:14
tags:
- Elixir
- Mix
- Bash completion
---

Bash completion is very handy for cli tools. You can set it up very easily for `mix` using the following script.

```
#!/bin/bash
# `sudo vim /etc/bash_completion.d/mix.sh` and put this inside of it
# mix bash completion script

complete_mix_command() {
  [ -f mix.exs ] || exit 0
  mix help --search "$2"| cut -f1 -d'#' | cut -f2 -d' '
  return $?
}

complete -C complete_mix_command -o default mix
```
