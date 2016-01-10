title: post update hook for gitosis and jekyll
date: 2010-09-28
---

If you have a gitosis server on which you host blog using jekyll (that would be 0.00001% of the bloggers I guess ;) ). 
You can use the following file as a post-update hook to update your jekyll blog.

So, let's say your git repository is named *example.com*, browse to /home/git/repositories/example.com/hooks and create
a file with the name *post-update*, copy the content below to your *post-update* file. That's it you are set, the next
time you push to your git repo, your blog will be automatically published.


~~~bash

#post-update
unset GIT_DIR && cd /var/www/blogs/example.com && git pull && jekyll
#/var/www/blogs/example.com is where your blog's repo is cloned
echo "finished deployment"

~~~


Below are a couple of problems I ran into and how I fixed them:
- File permissions issue *cannot write to .git/FETCH_HEAD*, you'll get this error if the 'git' user doesn't have write privileges to your blog's cloned directory, you can fix it by giving write permissions to your git user to this directory
- Permission to *repo* denied to *username*: this means your *git* user doesn't have read priveleges on your repository. Fix it by giving the git user readonly privileges in your gitosis.conf

