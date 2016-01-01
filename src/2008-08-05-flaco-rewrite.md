# Flaco Rewrite #

I've been happily using my own ghetto blog I named [Flaco
Blog](/articles/2008/01/27/flaco-blog).  The beauty of forcing myself to eat my
own software is that I can't really complain about it.  Either
something works exactly as I want it, or it slowly irritates me until
it overcomes the effort needed to rewrite it.  So why am I proposing a
rewrite?

Overall, I must say I'm very happy with Flaco.  It's simpler to setup and
use than all the other blog engines I've tried to use in the past.  As
far as bugs go, the scope of what I want is so well defined that all
the bugs I had were really minor.  What I haven't been enjoying is
hacking the code.  It feels more like a chore than fun.  And like I
said, I feel that I've finally been irritated enough to warrant some
action.

Earlier, I made this [whole rant](/articles/2008/05/20/my-perl) about enjoying
Perl.  I still feel that everything I said is true, but instead of
working on features I wanted, I spent my time pouring over CPAN
deciding what object libraries to use.  I had become a [language penny
pincher](http://www.pchristensen.com/blog/articles/hey-language-snobs-dont-pinch-pennies/):
mulling over how to do things and losing site of my goals.

The new plan is to use Ruby.  I won't use Rails because that doesn't
really suit the purpose of Flaco.  Using Ruby will allow me to trickle
some of the stuff I learn from work back home.  Also, it'll let me
explore the non-Rails parts of Ruby.  Here's what's in store for the
coming days.

* existing publish features of Perl Flaco.
* extraction of blog system configuration.
* separation of blog content and blog system
* incremental publishing (publish only since last published)

Those bullets are somewhat ordered for the coming days.  The last one
will be the new and interesting bit.  I'm really looking forward to
it.
