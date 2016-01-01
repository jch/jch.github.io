# Flaco Crushers #

Originally, this post was titled 'Ruby Markdown Implementations' and
I was going to talk about
[alternatives](http://tomayko.com/writings/ruby-markdown-libraries-real-cheap-for-you-two-for-price-of-one)
to [BlueCloth](http://www.deveiate.org/projects/BlueCloth).  But while
I was reading up about [Maruku](http://maruku.rubyforge.org/), I
followed a link to [webgen](http://webgen.rubyforge.org/).  As if that
wasn't enough, reading up on webgen led me to yet another static site
generator called [webby](http://webby.rubyforge.org/).

## Webgen ##

[Webgen](http://webgen.rubyforge.org/) is the first guy I found.  My
heart sunk a little for Flaco, but I was immediately impressed by it.

### Maturity ###

Webgen has been around for a while, and is written by [Thomas
Leitner](http://rubyforge.org/users/gettalong/), who has been in the
Ruby community since at least 2004.  It looks like the project itself
has been actively developed since 2004, with the last release being
just a week ago.  At it's height, it had [over 900
downloads](http://rubyforge.org/project/stats/?group_id=296).

### Code Quality ###

Skimming through the code, it looks very clean and ruby-like.  There
are test cases and a custom test harness. The Rakefile has many tasks
for streamlining administrative tasks.  The RDoc link on the site is
broken, but there is very comprehensive RDoc that can be generated
with the source.  It's worth noting that for a project that started
over 4 years ago, the code doesn't look crufty or outdated at all.
Kudos to you Mr. Leitner.

### Licensing ###

GPL V2.  Licensing doesn't really bother me, but it's worth
mentioning.

### Noteable Features ###

* build custom webgen tags for an extensible templating language.
* meta information fields.
* clever configuration.
* clean way to specify the render chain. e.g. erb, then markdown
* plugin-like ways to add breadcrumbs and menus.
* caching (don't know the details, but it creates a cache file)

## Webby ##

After poking around the edges of webgen, I googled for 'static site
generation' and found [Webby](http://webby.rubyforge.org/).  The webby
homepage wow-ed me more, but 'ASCII Alchemy' alone isn't enough
sometimes.

### Maturity ###

There's both a rubyforge and a github project for webby.  The fact
that it uses github and rspec makes me think that [Tim
Pease](http://www.pea53.com/) is on top of his ruby fashion.  The last
commit on github was a mere *2 hours* ago.  The whole project was
started about a year ago.

### Code Quality ###

Webby also looks pretty clean and ruby-like.  I can't quite put my
finger on it, but I think I liked how webgen was laid out better.  I
didn't spend as much time in the webby code, but it seems like it
isn't split up as well as webgen and might be harder to add new
features.  The RDoc didn't seem as good as webgen's.  I reserve final
judgement for later.

### Licensing ###

MIT License.  How chic.

### Noteable Features ###

* better guides and community for support
* use of rake for all actions
* autobuild feature
* build pages from templates

Both Webgen and Webby share a lot of features.  The ones that don't
overlap seem like they could be written because of the clean
architectures they both seem to follow.  The features webby lists and
shows in it's tutorial seem to match more with what I want for my
blog.

I'm happy to have found these two projects because they both do what I
want them to.  It saves me a ton of work in doing not-so-much tasks
like command line parsing and setting up library paths.  On top of
that, I can imagine adding the features that I wanted in Flaco that
aren't available in these systems.  They might even turn out to be
features that could be useful to other people :)
