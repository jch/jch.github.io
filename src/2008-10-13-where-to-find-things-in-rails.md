# Where to Find Things in Rails #

When I started learning Rails, I was amazed when all kinds of magical
things started working.  The problem was that I never felt in control
of the magic.  If I wanted a specific kind of magic to occur, then
Google would route me to an extremely unfriendly and near worthless
Ruby on Rails wiki.  I often had to guess how things work by tweaking
code found on peoples' blogs or by trial and error after not
understanding the Rails API documentation.  Nowadays, I'm very
comfortable with getting around in Rails and all it's plugins.  Here's
how I go about hunting down a problem.

When a bit of magic goes wrong, here's the order of how I look for
things:

* Search within the current file for the method definition.
* Search Google to see if it's a documented Rails feature.
* Search Google to see if it's a common Rails-y idiom.
* [ack](http://petdance.com/ack/) for the method name in the apps/
  subdirectory and see how it's used elsewhere.
* Search for include statements that could have mixed it into this
  file only.
* Skim config/environment.rb and/or config/initializers (Rails 2.x)
  for potential mixins.
* ack the method in vendor/plugins to see if it came from a plugin.

Sometimes, I'm not so lucky and the method name is dynamically
generated.  For cases like these, I just ack for some substring of the
method that I see being used by other files.

The checklist I outlined is far from a complete list of where I look
for mystical Rails problems.  This list is also not always in order
either.  At some point, I just became good at deciding where to start
looking.  Part of that skill comes from practice, but it really helps
to encourage your sense of curiosity and dig into the code as well.  I
find myself reading Rails code and plugins code even when I understand
the documentation.  Reading the source has taught me all kinds of
Ruby idioms and deepened my understanding of certain libraries.

If you're coming from a language or framework that has fantastic and
comprehensive documentation, don't forget to read the source every now
and then.  Even with complete documentation, it's important to keep up
with your framework and language's community to maximize what they can
do.
