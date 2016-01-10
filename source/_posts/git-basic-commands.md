title: git - basic commands
date: 2010-09-29
---

Before you read this blog entry please read [The git parable][1]. It is a nice read to understand the need and reason for git.

basic commands
----

~~~bash

#create the repository, first thing when creating a project
git init 

#shows you the current status of your repository
git status 

#adds files or directories to the staging area
git add filename 

#commits the changes from the staging area to the repository
git commit -m 'commit message'  

#shows the repositories graph
gitk --all 

# to check the commits
git log 

# get the last commit info
git log -1 

# file which stores the ignore file patterns
.gitignore 

#to checkout a commit
git checkout SHA1ID 

#to check the differences between working dir and latest commit
git diff 

#diff between those two commits
git diff commit_id1 commit_id2 

#server #to push to a server
git push 

#to manager remotes
git remote 

# to get the latest commits
git fetch 

~~~


*I'll update this post with more examples as I get the time*

 [1]:http://tom.preston-werner.com/2009/05/19/the-git-parable.html
