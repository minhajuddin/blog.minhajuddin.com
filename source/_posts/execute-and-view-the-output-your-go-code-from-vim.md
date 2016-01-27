title: Execute and view the output of your go code from vim
date: 2013-01-01
tags:
- vim
- go
- learn
---

Here is a small script which I created while trying to make my feedback process faster. It runs the current go file using `go run <current filename>` and appends its output as a bunch of comments at the bottom of the file whenever you hit `<Ctrl>d`

~~~vim
function! RunHandler()
  " to save the cursor position
  let l:winview = winsaveview()
  if &ft == "go"
    :silent!$r!go run % 2>&1 | sed 's/^/\/\//g'
    redraw!
    echo "triggered go run " expand("%")
  endif
  call winrestview(l:winview)
endfunction
nnoremap <C-d> :call RunHandler()<cr>
~~~

You can use this with slight changes with other file types. Here is a screenshot:

![vim screenshot](https://substancehq.s3.amazonaws.com/static_asset/50e3354203b04d3567000398/vim-shot.png)

###TODO
Make it overwrite the old output or insert before the previous output
