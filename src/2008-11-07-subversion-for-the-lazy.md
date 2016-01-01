# Subversion for the Lazy #

I've been asked about subversion enough times to justify writing this
quick and dirty article to save me future time.  Read this guide if
you absolutely need to get subversion working ASAP.  Otherwise I
highly recommend going through the [svn
book](http://svnbook.red-bean.com/) for more background information
and advanced usage.

## Bare Minimum Background ##

You will NOT be able to do anything right in subversion unless you
understand WHY it exists.  Subversion might be a pain in the ass, but
that wasn't why it was created.  Subversion is [version control
software](http://en.wikipedia.org/wiki/Revision_control) that is
supposed to help programmers organize their code.  If you use it
correctly, it'll fix all of the following problems:

* taking notes about the changes you were working on.
* going backwards in time to an older non-broken copy of a file.
* merging changes from multiple programmers on the same file.

This all starts with a subversion <span
class='repository-address'>repository</span>.  Think of the repo as
the original copy of your files.  Instead of making changes on the
original copy, you <span class='command'>checkout</span> a <span
class='arg1'>working copy</span> and make changes to that.  When
you're satisfied with the changes you made in your working copy, you
_commit_ the changes back to the repository.  Here is the absolute
simplest case of using svn:

<style type='text/css'>
  .command { color: #63831F }
  .repository-address { color: #FD6A08 }
  .arg1 { color: #6F86C0 }

  .subversion-command { margin-left: 20px; }
</style>

### Checkout a Working Copy ###

    svn checkout svn+ssh://address.to.subversion/repository myworkingcopy

The <span class="command">'checkout'</span> command makes a copy of
the <span class="repository-address">repository</span> and puts it
into a folder named <span class="arg1">myworkingcopy</span>.

### Make Your Changes ###

Edit any of the files in your working copy.  These changes will only
be in your working copy until you commit them back to the <span
class="repository-address">repository</span>.  This means that if you
make changes, and *another* person does a fresh checkout, they will
_not_ see your changes.  If you decide to create any new files in the
working copy, you need to let svn know with the 'svn add' command.

    svn add new_file1.txt new_file2.java new_file3.avi

You can add any number of arbitrary new files.

### Commit Your Changes ###

Before you commit, you want to double check the changes you made.
First type:

    svn status

This lets you know what's being committed.  'M' means modified, 'A'
means added, and '?' means it's a new file that hasn't been added.
Read the last section for adding.

When you're happy with the files to be committed, type

    svn commit

This will bring up your editor to type a note about what the changes
in this commit are.  If it says that no editor is set, google how to
set EDITOR in bash.  After the commit succeeds, anyone else who does a
fresh checkout or an 'svn update' will get the changes you just
committed.

### Pulling Changes from the Repository ###

If multiple programmers are using the same <span
class="repository-address">repository</span>, then at some point
you'll have to pull changes from other programmers.  Instead of doing
a fresh checkout every time, simply run

    svn update

to bring in all the changes from the remote repository.  It's a good
idea to get in the habit of updating before you make your changes
because otherwise you'll have to do unnecessary merging.  Read about
merging in the svn redbook.

### Cheatsheet ###

To summarize:

    svn checkout http://svn.somehost.com/path/to/repository my_own_copy
    cd my_own_copy
    (edit the files in my_own_copy)
    svn add my_own_copy/new_file1.txt
    svn status
    svn commit

### Common Issues ###

If svn ever says, '.' is not a working directory, then it means you
are not currently in a <span class="arg1">working copy</span>.  The
working copy is what you named the folder when you originally checked
it out.  See section about 'checking out'.

*Never* mix and match folders from different working copies.  If you
want to use mv, or cp, or copies files in and out of the working
folder, read about 'svn copy' and 'svn move'.

If you try to add a folder, and it says it's already been added, then
you probably meant to add the files within the folder.  Simply do a
'svn add -R folder_name' to do a recursive add of all files in the
folder.

All subversion commands start with 'svn'.  To get a list of all
commands, type 'svn help'.  To get help on a command foo, do 'svn help
foo'.

If you're on a Mac and you suck at Terminal, then go get
[svnX](http://www.apple.com/downloads/macosx/development_tools/svnx.html).
If you're on windows, get [Tortoise
SVN](http://tortoisesvn.tigris.org).

### Final Hints ###

This guide is for lazy people who won't spend 20 minutes to read and
understand the subversion guide.  I guarantee you'll save hours and
hours of headache if you just take the time to learn it properly.
This is the bare minimum to get started, and if you still have
questions after this, go and read the [svn red
book](http://svnbook.red-bean.com/).  Learn about merging, learn about
diff's, and learn how version control works.  You'll not only help
yourself in the long run, but you'll save the people you work with
lots of time too.
