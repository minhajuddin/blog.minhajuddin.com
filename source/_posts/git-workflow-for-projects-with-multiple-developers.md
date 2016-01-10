title: Git workflow for projects with multiple developers
date: 2013-01-31
tags:
- git
- workflow
---

For the trainees :)

    B <= current branch
    D <= Commands to run on developer's computer
    R <= Commands to run on reviewer's computer
    # <= comment

    1  Update your master
        B: master   D: git checkout master
        B: master   D: git fetch origin
        B: master   D: git merge origin/master #this will never create merge conflicts
                                                because it is a fast forward (straight line)

    2  Create topical branch and add features/commits
        B: master   D: git checkout -b foo
        B: foo      D: #make all your feature commits

    2.1 This is an optional step, which you can do if your feature is taking a long time.
        This will reduce your merge conflict pain down the line

                    D: Update master, see step #1
        B: master   D: git checkout foo
        B: foo      D: git merge master
        

    3  Review
        B: foo      D: git push origin foo
        B: foo      R: git fetch
        B: foo      R: git checkout -t origin/foo
        B: foo      R: #add notes or refactor
        B: foo      R: #add commits on foo
        B: foo      R: git push origin foo

    4  Merge review notes or refactored code
        B: foo      D: git fetch origin
        B: foo      D: git merge origin/foo
        B: foo      D: #make more commits/features
        #Repeat 3-4 as many times as you need

    5  Merge into master
                    D: Update master, see step #1
        #Merge topical branch into master
        B: master   D: git checkout foo
        B: foo      D: git merge master #this step might cause merge conflicts
        B: foo      D: #resolve the conflicts
        B: foo      D: git checkout master
        B: master   D: git merge foo #this won't cause any conflicts

    6  Push your code to origin
        B: master   D: git push origin master

**Steps #5 and #6 should be done in a small time window**

Update: Changed `git checkout origin/foo -b foo` to `git checkout -t origin/foo` from a [tip on HN](https://news.ycombinator.com/item?id=5144737)
