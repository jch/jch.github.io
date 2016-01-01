# Rails Tips #

I have started, abandoned, and restarted many pet rails projects.  All
hype aside, I've collected a fair amount of rails idioms.  Whenever I
come across a problem I know I've dealt with in the past, I usually
run a few greps through my past projects to look for an answer.  The
following pages are disorganized tips of things I have done that are
useful.

* if an ActiveRecord::Base object 'foo' doesn't agree with what's in
  the database, simply do foo.reload.  To make changes in the instance
  go to the database, do foo.save.  For many of the Base methods, you
  can append a ! to the end of the method name and it'll raise an
  exception instead of returning false on failure.  For example, save
  vs save!

* If you can't find a method or variable in a class, check the parent
  class (Class ChildClass < ParentClass), or look for 'include
  ModuleName', where ModuleName can exist in the lib/ or
  vendor/plugins directory.

* [Rails config
  variables](http://glu.ttono.us/articles/2006/05/22/configuring-rails-environments-the-cheat-sheet)
  - also good for setting vars for actionpack components

* config.observer... - registers a callback for when something happens
  to a model.  Can be done with before\_save, but can also be done
  externally and shared between models.

* ActiveRecord::Base.logger = Logger.new(STDOUT) - to just have SQL
  statements print to stdout.

## Testing ##

* [autotest](http://nubyonrails.com/articles/2006/04/19/autotest-rails)
  - This gem watches for filesystem changes and only runs tests that
  have been updated.  It's fast and it colorizes results.  I use it in
  conjunction with RSpec, and rspec-rails.

* rails\_rcov - wrapper that gives you rake tasks to
  [rcov](http://eigenclass.org/hiki.rb?rcov). To show test code
  coverage.

* [CruiseControl](http://cruisecontrolrb.thoughtworks.com/) -
  continuous integration tool that reports build and test errors.  The
  link is specific to ruby projects.

### RSpec ###

RSpec is an implementation of Behavior Driven Design (BDD).  It's a
declarative form of design and test.  When I first learned testing, I
learned it as imperatively setting up state, doing some actions, and
then verifing the end state.  The big problems I had with testing was
always getting tangled up in complex dependencies between different
components.  This made it really hard to focus on the system being
tested.  I'm looking more into using mocks and stubs to replace
fixtures and real models when it makes sense to.  BDD helps with this
because it focuses on beahavior and specification rather than
implementation.

* [RSpec](http://rspec.info/) - the library itself
  * gem install rspec, rspec-rails, diff-lcs, ZenTest
  * script/generate spec
  * rake -T | grep spec
  * should, should_not are
    [Spec::Expectations](http://rspec.info/rdoc/classes/Spec/Expectations.html)

* [mock_model](http://kpumuk.info/rspec/useful-helpers-for-rspec-mocks/)
  - good for mocking up ActiveRecord objects


## Plugins and Gems ##

* [schema-browser](http://www.pathf.com/blogs/2008/07/visualizing-your-database-schema-entirely-in-rails/)

* [restful\_authentication](http://agilewebdevelopment.com/plugins/restful\_authentication)
  - straightforward plugin that requires just a little bit of tweaking
  and config.  Works great if your user model acts\_as\_state\_machine.

* [role\_requirement](http://code.google.com/p/rolerequirement/) -
  plays well with restful\_authentication.  I haven't tried this one
  before.  I did use [Active RBAC](http://active-rbac.rubyforge.org/)
  with positive results before.

* acts\_as\_state\_machine - amazing mixin that can make your
  models act like a state machine.  It allows you to register
  callbacks for when a model's state changes.

* SyslogLogger - logger that goes to syslog.  Not a fan of this one,
  but I've seen it in use.

* [SimpleConfig](http://labs.reevoo.com/plugins/simple-config)
  - haven't used it, but will work.

### Gem Dependencies ###

  I like to have my projects be self-contained.  This means that when
  you check out one of my projects, you should be able to setup your
  database, do a rake or two, and be on your way.

  There are several fixes to this problem.  The cleanest one that I've
  choosen is to update to Edge Rails with:

    rake rails:freeze:edge

  then follow [Ryan's Scraps Gem
  Dependencies](http://ryandaigle.com/articles/2008/4/1/what-s-new-in-edge-rails-gem-dependencies)
  article.

  Unfortunately, upgrading to Edge Rails might not be feasible.  In
  this case, one solution is to mimic what Edge Rails does:


    mkdir RAILS_ROOT/vendor/gems
    gem install FOO --install-dir RAILS_ROOT/vendor/gems


  To make your rails app recognize the installed gems, update your
  environment.rb to look in the newly created subdirectory with
  config.load_paths.

  Another interesting plugin that I haven't looked into is
  [piston](http://www.rubyinside.com/advent2006/12-piston.html) which
  gives you all the advantages of svn:externals, but also allows you
  to commit local changes to your own repo.

## Escaping HTML ##

See
[ERB::Util](http://www.ruby-doc.org/stdlib/libdoc/erb/rdoc/classes/ERB/Util.html)
for the following:

* html\_escape
* url\_encode
* url\_decode

Remember that if you wanted to use these in your controller, you have
to require and include it.  I recommend against using the shorthand
versions because it sucks for readability.

## Metaprogramming ##

When I was trying to create a RESTful TagsController with the
[acts_as_taggable](http://agilewebdevelopment.com/plugins/acts_as_taggable_on_steroids)
plugin, I created a form that looked like:

    <input id="tag" type="text" size="17" name="tag"/>
    <input id="taggable[id]" type="hidden" value="14" name="taggable[id]"/>
    <input id="taggable[type]" type="hidden" value="Place" name="taggable[type]"/>

When this form was posted, I would get a string for the class of the
object that I wanted to tag in taggable[type].  In normal Ruby, you
can call
[Kernel.const_get(classname)](http://www.ruby-doc.org/core/classes/Kernel.html)
to get the Class object for classname.  In Rails, this has been
simplified further to be just [classname.constantize](http://infovore.org/archives/2006/08/02/getting-a-class-object-in-ruby-from-a-string-containing-that-classes-name/)

## Inheritance ##

[Namespaced Models](http://m.onkey.org/):

    class Pet < ActiveRecord::Base
      self.abstract_class = true

      belongs_to :person
      validates_presence_of :name
    end

    class Dog < Pet
      def bark
        "baaw"
      end
    end

## Cool Syntax ##

    assert_equal 1, Developer.connection.select_value(<<-end_sql).to_i
      SELECT count(*) FROM developers_projects
      WHERE project_id = #{project.id}
      AND developer_id = #{developer.id}
    end_sql

## Miscellanous ##

* Hash.symbolize_keys! - turns all keys to symbols
