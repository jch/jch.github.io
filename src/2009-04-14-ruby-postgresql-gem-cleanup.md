# Ruby Postgresql Gem Cleanup #

I ran into some trouble with getting a good native postgresql driver
installed.  Here are some links and resources I found to be useful.  I
also wrote a [checklist for bootstrapping a new Rails app with
postgres](http://www.whatcodecraves.com/posts/2008/02/05/setup_rails_with_postgresql/)
as the adapter.

There are several choices for postgresql adapters.  The most active
and up-to-date one appears to be
[ruby-pg](http://rubyforge.org/projects/ruby-pg/), previously known as
ruby-postgres.  ruby-pr was the one I was using originally, but this
one is non-native and unmaintained.

A good starting point was [Robby's 'Installing Ruby on Rails and
Postgresql on OS X 2nd
edition](http://www.robbyonrails.com/articles/2007/06/19/installing-ruby-on-rails-and-postgresql-on-os-x-second-edition).
[ShiftEleven](http://shifteleven.com/articles/2008/03/21/installing-postgresql-on-leopard-using-macports)
also had detailed instructions for installing postgresql with
macports.

The exact steps I took that worked for me were:

    # start postgres on computer start.
    sudo launchctl load -w /Library/LaunchDaemons/org.macports.postgresql83-server.plist

    # the ARCHFLAGS is because of Leopard weirdness.
    sudo env ARCHFLAGS="-arch i386" gem install pg


<!--
## Getting Warehouse to work with postgres and newer rails ##

  changed database.yml to postgresql adapter
  removed vendor/rails
  changed to rails 2.1.1
  changed production to not cache_classes on db tasks
  rake warehouse:bootstrap

  # missing svn/core
  http://www.jtanium.com/2008/10/13/using-native-bindings-with-ruby-enterprise-edition/
  sudo aptitude install libsvn-ruby1.8
-->
