title: rake task to delete untracked files in git
date: 2010-12-09
---

**UPDATE** I should have checked if git has a command for this. Anyway *SomeGuy*
has reminded me once again that I should GTFT (Google the f\*\*\* thing) before
creating a task. Thanks for the tip *SomeGuy* :). Long story short, use `git clean` to [cleanup
untracked files][1]

- - -

Whenever I merge stuff from my colleagues, I end up with a bunch of **\*.orig** files.
So, I created a simple rake task which deletes all the untracked files.


~~~ruby


desc 'deletes untracked files'
task 'git:del' do
  files = `git status -s`
  files.lines.each do |f|
    next unless f.start_with? '??'
    f = f.gsub('??', '').strip
    File.delete(f)
    puts "deleted => #{f}"
  end
end


~~~


This will permanently delete **all** untracked files from your working copy, so
use it with care! :)

  [1]:http://www.gitready.com/beginner/2009/01/16/cleaning-up-untracked-files.html
