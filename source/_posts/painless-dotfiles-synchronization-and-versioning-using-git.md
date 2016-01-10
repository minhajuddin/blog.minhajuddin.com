title: painless dotfiles synchronization and versioning using git
date: 2011-05-03
---

Synchronization of dotfiles has been documented to death in many blogs. But, I 
just wanted to show how I do it:

 1. Initialize (`git init`) a repository called *dotfiles* anywhere on your filesystem (I do it in `~/repos/core/`).
 2. Copy your dotfiles to this directory, and arrange them in whatever order you
    want and add them to your git repository.
 3. Now, tweak the line#2 in the following script to include your dotfiles or
    folders and run it. 
 4.  Now, to sync your dotfiles seamlessly between your machines. You just need a remote git server (It can be your own using [ gitosis ](http://scie.nti.st/2007/11/14/hosting-git-repositories-the-easy-and-secure-way), or you can put it on [ github ](https://github.com/)). I use github to store [my dotfiles](https://github.com/minhajuddin/dotfiles). Just push your dotfiles to your remote server clone it on another machine run the `setup.rb` and bam, you're in business.


~~~ruby

    #!/bin/env ruby
    dirs = %w(bash/.bash_aliases bash/.inputrc git/.gitconfig vim/.vim vim/.vimrc .gemrc)
    current_dir = File.expand_path(Dir.pwd)
    home_dir = File.expand_path("~")

    dirs.each do |dir|
      dir = File.join(current_dir, dir)
      symlink = File.join(home_dir, File.basename(dir))
      `ln -ns #{dir} #{symlink}`
    end

~~~



This way you don't have to copy/paste the files when you make changes to them.
Just change the file, commit and push, and pull it on the other machines.
