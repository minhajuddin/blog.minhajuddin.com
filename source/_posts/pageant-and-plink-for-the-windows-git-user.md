title: pageant and plink for the windows git user
date: 2010-11-08
---

Alright, pushing and pulling can be a pain if you are using git (through msysGit) on *windows*. 
You'll have to enter the password *every* time you want to pull or push, And if you are working in a
team where you need to sync your stuff a lot, this is really painful. 

I use ubuntu for half of my work and Windows for the other half. And this is one
of the many places where ubuntu shines, It remembers the passwords of my private
keys in a keyring. Once you configure it, it doesn't ask you for the password of
your private key, it just works.

If you want to do the same with windows, you'll need plink, putty and pageant
which you can [dowload here][1]. Once you have it copied to a directory, you
need to do the following:
  
  1. Create an environment variable called `GIT_SSH` and copy the absolute path
     of plink to it, e.g. d:\utilities\putty_stuff\plink.exe
  2. Create a shortcut of pageant on your desktop
  3. Right click and open up the properties of this shortcut and and append the
     path of your key to the target of this shortcut. ()
  4. Copy this shortcut to the *startup* directory in your windows programs menu 
     to start it automatically when you login to windows

Now, whenever you login to your computer it will start pageant automatically and
ask you for the password of your private key. Once you do that you can pull and
push as much as you want, you won't be pestered for your password anymore :)


  [1]: http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html
