# Customizing Emacs #

My editor of choice is eight megs and constantly swapping.  I didn't
meticulously choose my editor, but rather had one forced upon me
freshman year in CS61A.  Being young and impressionable at the time, I
saw no downsides to the editor and kept using it more and more day
after day.  First it was coding, then notes, then email.  Now four
years later, I'm basically married to my editor, for better or for
worse.  For a complete reference of my .emacs file, see [this
link](https://github.com/jch/dotfiles).

## Movement ##

One of the most important features of an editor for a developer is
ease to move point, emacs terminology for cursor, within a file and
between files.  I'm glad I took that hour in 61A lab to go through the
emacs tutorial (M-x tutorial) and learn the basics of movement.  In
terms of customization, the only option I changed is mapping M-g  to
'goto-line'.

    (global-set-key "\M-g" 'goto-line)

Two feature I still tend to neglect to use are 'bookmarks' and 'tags'.
Bookmarks allow you to save a specific location in a specific buffer,
but the keybinding to set a bookmark is *hrm*, rather cumbersome.
Tags are this magical feature that I've had mixed results with.  It
allows you to index and quickly jump to interesting places like
function and class definitions.  Unfortunately, sometimes it also
likes to index *uninteresting* places and jumps you to those.

## Text Manipulation ##

Ever wanted to leverage the power of unix on some region of text?
Trying using M-! (shell command), or M-| (shell command on region).
As if that's not enough, if you prefix either of them with M-[k] for
some number k, then the output of the command gets inserted at point.
This is great for sorting (sort -n) on a bunch of imports or includes,
and also for inserting useful snippets of text (which perl, date)

Another amazing feature is rectangular editing:

    C-x r t
    C-x r d

These two commands mean insert and delete respectively.  The two
complementary use cases are to select the beginning of several lines
and use 't' to insert a comment character and then use 'd' to delete
them when you're done.  Sure you could use `M-x comment-region`, but
sometimes that doesn't act quite right, and these two are better
built-in to my muscle memory.

Another super lazy trick is `M-/`.  This tries to complete the current
word you're typing with words that are in other buffers.  If it's not
the right one, just `M-/` to cycle to the next one.

## Look and Feel ##

Let's face it, to become a true hacker, you have to adopt some obscure
interface that's so catered to you that it'll wow and gag everyone
else who dares try to use it.  Such is the case of my own settings.  I
didn't do too much to it, but even little things can make a big
difference.

My favorite quick thing is to change the text to be white on black:

    (set-background-color "black")
    (set-foreground-color "white")

Next, I like syntax highlighting so I turn on the extremely poorly
named:

    (global-font-lock-mode t)

Then, I turn off a few things that I know I won't use:

    (setq inhibit-startup-message t) ; I'm using emacs, duh
    (menu-bar-mode -1) ; menus can still be seen with M-`

## Broken Things ##

Even though emacs can be all things to all people, there have been a
few annoyances I can't figure out.  My worst beef is how backspace has
different behavior wherever I go.  I understand that it's most likely
because of the different shells and environments I'm using, but it's
too bad emacs can't just magically figure it out for me.  Right now I
have a line in my .emacs:

    ; fix annoying shell backspace problem
    ; 0 for ibook, 1 for imac
    (normal-erase-is-backspace-mode 1)

Note how I have to edit that value by hand or otherwise be doomed to
forward-delete instead of backwards.

## Modularizing .emacs ##

.emacs is the config file that lives in your homedir and is loaded
when Emacs starts.  I'll be honest and admit that my .emacs is pretty
messy at the moment and needs a serious *refactor*.  I'm both
delighted and exasperated that my config needs to be *programmed*.  I
read [this
post](http://a-nickels-worth.blogspot.com/2007/11/effective-emacs.html)
talking about some emacs tips, and I'm interested in learning more
about autoload and optimizing some of the calls.