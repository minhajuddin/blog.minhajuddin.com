title: How to open the most recent file created in Vim
date: 2016-02-19 19:14:11
tags:
- Tip
- Vim
- Static Sites
- Rails Migrations
---

When working with Static Site Blogs, you end up creating files with very long
names for your blog posts. For example, this very post has a filename
`source/_posts/how-to-open-the-most-recent-file-created-in-vim.md`.

Now finding this exact file in hundreds of other files and opening them is a
pain. Here is a small script which I wrote by piecing together stuff from the
internet.

~~~bash
# takes 1 argument
function latest(){
# finding latest file from the directory and ignoring hidden files
echo $(find $1 -type f -printf "%T@|%p\n" | sort -n | grep -Ev '^\.|/\.' | tail -n 1 | cut -d '|' -f2)
}

function openlatest(){
${EDITOR-vim} "$(latest $1)"
}
~~~

Now, I can just run `openlatest source` to open up the file
`source/_posts/how-to-open-the-most-recent-file-created-in-vim.md` in vim and
start writing.

This technique can also be used to open the latest rails migration. Hope, this
function finds a home in your `~/.bashrc` :)
