# Tips of the Day #

* backspace in GNU screen with Apple Terminal, SSH, and Ubuntu
* jquery tooltip plugins
* django stuff

## It's just a backspace ##

Is it too much to ask for backspace to mean backwards-delete?
Apparently it is, because there are entire bug threads and forum posts
dedicated to the issue.  I finally got mine working with the following
in my .screenrc:

    bindkey -d ^? stuff ^H

Thanks to [this blog
post](http://www.deadlock.it/linux/fix-gnu-screen-backspace-misinterpretation/).
The original post also maps ^@, but that conflicts with ctrl-space
set-mark in emacs. It also appears to be working for me without that
second line.

The other solution that made backspace work was

    alias screen='TERM=screen screen'

But this solution screwed up the status bar colors on the bottom of my
screen.

Something that was somewhat useful in helping debug this problem was
figuring out what backspace actually mapped to in Terminal, in a ssh
shell, and in screen.  To display a non-printing character, start with
^v (control-v), then type the non-printing letter (backspace).  What I
got were:

    Terminal: ^?
    SSH:      ^?
    screen:   ^[[3~

It's amazing how many mappings people suggested in the forums, and how
all of them didn't work.  My guess is that YMMV and you just need to
try all of them until you get one that works.  Here's some others I
tried:

    bindkey -k kb stuff "\010"
    bindkey -k kb stuff "\177"

And other variations with ^?, ^H, and ^[[3~.

## jQuery Tooltips ##

I ended up choosing
[mbTooltips](http://pupunzi.open-lab.com/mb-jquery-components/mb-tooltip/)
for this specific application because it's relatively lightweight (4k
minified, with 8k of dependencies).  The original [jTips
plugin](http://www.learningjquery.com/2006/10/updated-plugin-jtip)
that was in use was a whopping 187k AND used AJAX requests to get
tooltip data.  jTips is also unmaintained.  Personally, I would just
use the default 'title' attribute on HTML elements for tooltips, and
style them appropriately.

## Django Stuff ##

To do redirects:

    # You'd think redirects wouldn't need to be explicitly imported...
    from django.http import HttpResponseRedirect
    return HttpResponseRedirect("/")

[Form models, form helpers, form
processing](http://docs.djangoproject.com/en/dev/topics/forms/)
