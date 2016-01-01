# Rails Dependency Management #

Rails has two methods of adding external libraries to a project,
[rubygems](http://docs.rubygems.org/) and
[plugins](http://guides.rubyonrails.org/plugins.html).  There are also
different ways to manage these external libraries.  Here are some
conventions I've picked up over the years for managing dependencies in
development and deployment as painless and maintainable as possible.

## Rubygems ##

I prefer using gems over plugins whenever possible because they are
easily shared between different applications, and are versioned.
Multiple versions of the same gem can be installed on the same box,
and it's up to the application to specify which version it wants to
use.  This is great if you have older apps that aren't ready to go up
to a newer version living in the same environment as apps who are
already using a newer version of the same library.

* [Ryan's Scraps introduction](http://ryandaigle.com/articles/2008/4/1/what-s-new-in-edge-rails-gem-dependencies)
* [Railscast](http://railscasts.com/episodes/110-gem-dependencies)
* [Rails API documentation](http://api.rubyonrails.org/classes/Rails/Configuration.html#M002537)
* [Rubygems documentation](http://docs.rubygems.org/)

### Gem Bundler ###

In addition to installing gem dependencies on production boxen by
hand, there's an interesting new kid on the block called
[Bundler](http://yehudakatz.com/2009/11/03/using-the-new-gem-bundler-today/).
The idea is you declare what gems and versions belong with a Rails
application in a Gemfile which is used by the 'gem bundle' command to
freeze those gems into vendor/gems.  To 'freeze' a library in
Rails-speak is to copy that library into the vendor directory; It
offers the same tradeoffs as
[static-linking](http://en.wikipedia.org/wiki/Static_library) and
[dynamic-linking](http://en.wikipedia.org/wiki/Dynamic_link_library).

* [Yehuda Katz introduction](http://yehudakatz.com/2009/11/03/using-the-new-gem-bundler-today/)
* [Heroku docs](http://docs.heroku.com/gems)

I use a combination of Bundler and Rail's builtin 'config.gem' on
Heroku.  For every gem that is already available on the hosts, I use
'config.gem' and use the existing shared gem to avoid wasting space
with freezing gems.  For gems that are not available on the box, I
have a Gemfile that Bundler uses to freeze gems on every deploy.  I
get the benefit of static-linking for gems aren't available on the
local host, but also get the benefit saving space with
dynamic-linking.

## Plugins ##

Originally I thought of gems as general purpose ruby libraries, and
'plugins' as ruby libraries that are only useful within a Rails
application.  That distinction isn't very useful practically.  Even if
a shared library is only useful within a Rails app, I still prefer to
use a gem because gems are versioned and have tools to maintain and
manipulate them.  Luckily many Rails plugins usually offer themselves
as both a tradition plugin that gets frozen in vendor/plugins, or as a
gem dependency.

One plugin nasty plugin habit I had to get rid of was the urge to
'script/generate plugin' whenever I wasn't sure where to put a certain
chunk of modular code.  Before you do this, remember that plugins are
supposed to be resuable in *any* Rails app.  If your plugin can't be
decoupled from your Rails project and dropped into a fresh one, then
it probably belongs in 'lib' and not 'vendor/plugins'.

* [Ryan's Scraps rails
  initializers](http://ryandaigle.com/articles/2007/2/23/what-s-new-in-edge-rails-stop-littering-your-evnrionment-rb-with-custom-initializations)
  are useful for requiring extra libraries you have in 'lib' instead
  of 'vendor/plugins'
* [Err the Blog load_paths
  example](http://errtheblog.com/posts/3-organize-your-models). It's
  good to understand how
  [config.load_paths](http://api.rubyonrails.org/classes/Rails/Configuration.html)
  work so you can organize where you put your shared code.

## Avoid Dependencies ##

Probably the most important lesson I've learned is to not get too
trigger happy with adding new external libraries.  There are a lot of
good libraries out there, but plenty of bad ones too.  Before you
marry yourself to a particular library, research it thoroughly; Is it
actively maintained?  Are there lots of complaints about it in the
blogosphere?  Are there tests?  Does the code look well written?  Is
there documentation?

and most importantly of all...

**Do I actually need this functionality?**

I've been burned plenty of times for installing something new and
shiny and then ditching it later because it was much more than I
needed.  Just like it's more elegant to write less code, more
concisely; The same principle applies when introducing new
dependencies to your application.
