title: how to convert html or erb to haml in vim
date: 2012-03-15
---

I use HAML a lot, it's a very nice templating language. And I copy a lot of
html/erb snippets to my haml views. Here is how you can configure vim to convert
your html to haml.


 1) Install the html2haml gem. If you are using rvm, generate a wrapper using the
 code below.

~~~bash

rvm wrapper ruby-1.9.2-p290 vim html2haml

~~~

   2) Add the following mapping to your `~/.vimrc`

~~~vim

" html2haml
:vmap <leader>h :!/home/minhajuddin/.rvm/bin/vim_html2haml<cr>

~~~


 That's it, now you can select a block of text and hit the `<leader>h` command
 to convert your html/erb to haml. You need to make sure that the paths and the
 rvm strings correspond to your machine settings to get this working, also
 html2haml needs a few more gems. Check [html2haml](http://haml-lang.com/docs/yardoc/Haml/Exec/HTML2Haml.html) for more info 
