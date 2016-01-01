# A Day in Python Library Hell #

I haven't used python as my main day-to-day language, but I've already
run into problems with the tools and libraries that has had me pulling
my hair out.

## Library Management ##

There doesn't appear to be a consensus in the community for how you
distribute or install libraries.  As a result, every library is a
little different, and you have to figure it out per package.
Sometimes it's through python eggs, sometimes through your OS's
package manager, sometimes it's from source, and sometimes it's just
drop in a file.  As if this wasn't bad enough, the method you choose
to install a library might determine whether it works or not.  When I
tried to install the oauth module via an egg, the module didn't work.
From this [blog post
comment](http://agileweb.wordpress.com/2009/04/28/step-by-step-guide-to-use-sign-in-with-twitter-with-django/),
it turns out I wasn't alone:

    I had this problem too. I get it when I used setuptools to install
    an egg of ouath. Instead, just copy oauth.py into your Python path
    and it will work fine.

"just copy oauth.py into your Python path"?  Is this seriously the
solution?  If so, then why even bother to have distribute a broken
egg?

### easy_install is Stupid ###

First of all, what a stupid name for a program.  It doesn't tell me
anything about what it does, and isn't remotely related to 'eggs' nor
python.  The --help message has no short description, and there's no
man page for it.  When you google for 'python egg', the first result
is ['setuptools'](http://pypi.python.org/pypi/setuptools), which is
'easy_install', which happens to install eggs.

Oh, and guess what?  There's no easy_uninstall.  For that, you'll have
to remove it yourself from your local site-packages, or [roll your own
uninstall](http://ubuntuforums.org/showthread.php?t=666698).

## __init__.py is Useless ##

Every init file I've seen so far has been empty.  I understand the
purpose for this file, but requiring it in a directory for something
to be considered a module is annoying.  Java also uses directories for
packages, but doesn't require you to touch a file in every folder.

## Rotten Eggs ##

I'm disappointed something that developers use day in and day out can
be so clunky and vague.  I've singled out the oauth library as an
example, but the problem isn't just a single bad library.  The problem
is how freaking difficult it is to try a new library; Even if you like
the API of the library, there's an additional hurdle of installing and
maintaining it.  I wish the Python community would come to a consensus
and choose a standard way of distributing libraries.
