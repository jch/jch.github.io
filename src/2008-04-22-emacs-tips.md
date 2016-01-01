# Emacs Tips #

Earlier, I wrote a quick into of how to [customize your
emacs](/articles/2008/02/14/customizing_emacs), but then I realized
that I had no running list of cool emacs tricks.  This article sets
out to remedy that with a list of my favorite commands.  It's by no
means complete, so I'll keep adding on to when when I learn more
stuff.  The <a
href="http://www.amazon.com/gp/product/1882114868?ie=UTF8&tag=what0d-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=1882114868">Gnu
Emacs Manual</a> is a good reference to flip through from time to time
to learn new tricks.

## Getting Help ##

A good one to start with that I admit I don't use as much as I should
is 'M-x help'.  This presents a menu of help sections available.  I
recommend sticking with 'a' for apropos and guessing what you're
interested in.

## Identing ##

The trick that never grows old is to re-indent a region.  The command
to do it is 'C-M |', but it's really inconsistent and hard to type all
three of those at once.  Fortunately, 'ESC' is a stick meta, so I
generally do 'ESC' [let go] 'C-|' (the pipe character).  This is great
for when you just paste from another buffer with different indents,
because the most recent paste is the selected region that gets
reindented.

## Find and Replace ##

The find and replace can be started with 'M-%'.  You type the string
to find, RET, then the string to replace.  Emacs will highlight each
occurance and prompt you for each replacement.  Space to skip, 'y' to
replace and go to the next replacement, '.' to replace and stop, '!'
to replace all remaining.

The same can be done with regular expression find and replaces with
'M-x query-replace-regexp'.  Remember that to create a group in Emacs
regex, you have you escape your parenthesis.  So to do the Perl
equivalent of s/foo (bar)/\1/, you would do 'M-x
query-replace-regexp', 'foo \(bar\)', '\1'.

## Diffs and Patches ##

Sick and tired of straining your eyes and hands to applying those ever
tedious diffs and patches?  Fear not, diff-mode to the rescue!

It's a pretty common use case to pick specific change in one branch of
subversion and apply it to a stable branch.  The way I work through
this is to:

    svn diff BRANCH_OLD BRANCH_CHANGES > changes.diff
    emacs changes.diff

Immediately, you'll notice a much friendlier, more colorful diff.  You
can jump from hunk to hunk with 'n' and 'p'.  If you RET on a hunk,
then it'll jump to the source file to give you more context.  To apply
or undo a hunk, simply 'C-c C-a'.  Emacs will prompt you if it's an
undo.

If you don't have a diff on hand, you can specify which two files to
diff and use ediff-mode.  Simply open an emacs, M-x ediff-mode, and
specify the two files to diff.  It'll put them in two buffers A, and
B.  Press '?' to bring a menu of keys.  The main ones are n, p, a, b,
wa, wb.

## Macros ##

The most basic usage is to do 'C-x (' to start recording a macro; do
what you need to do; and 'C-x )' to end the macro.  'C-x e' executes a
macro, and you can 'M-x apply-macro-to-region-lines'.  I still need to
learn to use these better ;)

## Managing Buffers ##

To split the window, use 'C-x 2', and 'C-x 3'.  They split the window
horizontally and vertically respectively.  To switch buffers, 'C-x
b'.  You can tab complete the file names here.  To see a list of
buffers, 'C-x C-b'.  Switching to a directory will put you in
dired-mode.  More on that later.

## Cut Copy and Paste ##

Beyond the basics of cut, copy and paste, I also like 'C-x r d' which
deletes a selected block region, and 'C-x r t', which inserts a
selected block region.

## Running Shell Commands ##

The easiest case is when you just want to quickly see the output of a
command without switching to another terminal.  Simply do 'M-!' and
type your command, and the output will show in the minibuffer.
Another clever one that I don't use as much is 'M-|', which runs
shell-command-on-region.  The best part is that if you wanted the
output of the shell command in the buffer you're visiting, just M-! or
M-| with M-5, or any other number.  I use this one all the time when I
have to type a shebang line and I'm not sure where the binary is
located:

    #! M-5 M-! which python

## Debugging ##

I don't use gdb and other debuggers enough to have all this in my
muscle memory yet, but Emacs is a dream when it comes to debugging C.
'M-x gdb' starts gdb in a separate buffer.  Then you can specify
breakpoints in any source buffer by doing 'C-space'.  Other useful
commands basic commands include:

    C-c n - next
    C-c s - step
    C-c f - run to end of frame

I haven't used the other debuggers, but I know there's they're
available for other languages.