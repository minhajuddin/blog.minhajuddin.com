title: How to learn vim properly
date: 2017-01-19 00:16:17
tags:
- Vim
- Learn
---

Vim is the editor of my choice, I love it a lot. I try to find vim bindings everywhere I can,
A few apps which have good vim bindings

  1. Chrome with vimium
  2. The terminal with a proper `~/.inputrc`. My `~/.inputrc` below
  ```bash
    # ~/.inputrc
    #vim key bindings
    set editing-mode vi
    set keymap vi
    # do not bell on tab-completion
    set bell-style bell

    set expand-tilde off
    set input-meta off
    set convert-meta on
    set output-meta off
    set horizontal-scroll-mode off
    set history-preserve-point on
    set mark-directories on
    set mark-symlinked-directories on
    set match-hidden-files off

    # completion settings
    set page-completions off
    set completion-query-items 2000
    set completion-ignore-case off
    set show-all-if-ambiguous on
    set show-all-if-unmodified on
    set completion-prefix-display-length 10
    set print-completions-horizontally off

    C-n: history-search-forward
    C-p: history-search-backward

    #new stuff
    "\C-a": history-search-forward
  ```

  3. Once you set this up, many repls will respect these bindings. For instance irb, pry respect these. As a matter of fact any good terminal app which use the `readline` library will respect this.
  4. Tmux is another software that has vim bindings

So, whenever I work with someone people always seem to be impressed that vim can do so much so simply.
This is really the power of vim, vim was built for text editing and it is the best for this job. However, learning it can be quite painful and many people will abandon learning it in a few days.

There is a very popular learning curve graph about vim

{%asset_img editor-learning-curve.png Editor learning curves}
[Source](https://blogs.msdn.microsoft.com/steverowe/2004/11/17/code-editor-learning-curves/)

The part about vim is partially true, in that once it *clicks* everything falls into place.

Notepad is an editor which is very easy to use, but if you compare it to programming languages it has the capability of a calculator. You put your cursor in a place type stuff and that is all.
**Vim lets you speak to it, in an intelligent way** Anyway, I am rambling at this point.

The reason I am writing this blog post in the middle of the night is because many people ask me "How should I setup vim?", I'd love to have it look/work like yours.
And many times I [point them to my vimrc](https://github.com/minhajuddin/vimrc/blob/master/vimrc).
However, if you are planning on learning vim, don't go there. Start with the following `~/.vimrc`

```viml

set nocompatible

" plugins
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'kien/ctrlp.vim'
Plug 'matchit.zip'
runtime macros/matchit.vim
call plug#end()

" Ctrlp.vim
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

```

That is all, no more no less.

To finish the installation, you need to do 2 things:
  1. Run `curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim`
  2. Run `vim +PlugInstall` from your terminal

A few simple tips on how to learn vim properly:

 1. Finish `vimtutor` on your terminal 3 to 4 times. Read everything 3 to 4 times and actually practice it.
 2. Learn about vim movements, commands and modes
 3. **Open your vim editor at the root of the project and have just one instance open, don't open more than one instance per project. This is very very important. I can't stress this enough**. To open another file from your project, hit Ctrl+P
 2. Start with a simple vimrc, The one I pasted above is a good start.
 3. Learn about buffers / windows and tabs in vim and how to navigate them.
 4. Add 1 extension that you think might help every month. And put a few sticky notes with its shortcuts/mappings on your monitor.
 5. Use http://vimawesome.com/ to find useful plugins.

** Most important of all: Don't use any plugin other than sensible and CtrlP for the first month**

Once you learn to speak the language of vim, using other editors will make you feel dumb.
