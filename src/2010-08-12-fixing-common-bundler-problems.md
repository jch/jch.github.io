# Fixing Common Bundler Problems #

<img src="/images/gembundler.png" style="float:left" />
When [bundler](http://gembundler.com/) first came out, I really wanted
to like it. It promised a clean way to declare dependencies on for
your application in a single place, and have that be definitive
regardless of what box your app was running on.  Unfortunately,
reality didn't match up with promises and I've had plenty of headaches
from bundler problems.  Read on for a list of tips I've pulled
together to save you some headache.

## Ensure you're local bundler is the same version as your server

Different versions of bundler may act differently:

    bundle --version  # on your local machine and your server
    sudo gem install bundler --version="0.9.26"

## Explicitly specify gem versions

Did you know in HTTParty 0.4.5, there's no 'parsed_response' method on
a response object?  Well, neither did I when it worked fine on my
local laptop (0.6.1), but not on the server (0.4.5)

    gem "httparty"  # bad times if your system gem is out of date...
    gem "httparty", "~> 0.6.1"  # better, but...
    gem "httparty", "0.6.1"     # ...why not just specify the version everyone should use?

## Check you're actually using gems installed by bundler

Once in a while, bundler will report success on install, but you'll
get the wrong gems loaded in your load path.  Grep your load path to
double check libraries you're having trouble with

    # in script/console
    >> $:.grep /http/
    => ["/Users/jch/.bundle/ruby/1.8/gems/httparty-0.6.1/lib"]

## Gemfile conditionals

bundler allows you to specify groups so only gems you need in one
environment are loaded:

    # we don't call the group :test because we don't want them auto-required
    group :test do
      gem 'database_cleaner', '~> 0.5.0'
      gem 'rspec'
      gem 'rspec-rails', '~> 1.3.2', :require => 'spec/rails'
    end

All gems you specify in your Gemfile WILL be installed regardless of
what RAILS_ENV you're currently on.  There's a very deceptively named
option called --without that does not work as you would expect:

    # weird, but this will install gems in group test
    bundle install --without=test

This can turn out to be a disaster if your production environment
tries to install a OSX specific gem with native extensions that you
use for development.  An ugly fix in the meantime is to add
conditionals that look for an environment variable:

    if ['test', 'cucumber'].include?(ENV['RAILS_ENV'])
      group :test do
        # your gems
      end
    end

## Update your capistrano

Don't forget to bundle when you deploy:

    after  "deploy:update_code", "deploy:bundle"
    namespace :deploy do
      desc "Freeze dependencies"
      task :bundle, :roles => :app do
        run "cd #{release_path} && bundle install --relock --without=test"
      end
    end

## NameErrors and autoloading issues

Read [this
issue](http://github.com/josevalim/inherited_resources/issues/issue/34).
The fix is to skip the require in your Gemfile and do the require in
your environment.rb:

    # Gemfile
    gem 'misbehaving_gem', :require_as => []

    # environment.rb
    Rails::Initializer.run do |config|
      # ...
      config.gem 'misbehaving_gem'
      # ...
    end

## Nuke .bundler

When all else doesn't make sense, and you've pulled out what precious
little hair you have left:

    rm -rf RAILS_ROOT/.bundle      # removes gems for this project
    rm -rf ~/.bundle               # removes cached gems for your current user
    rm -rf RAILS_ROOT/Gemfile.lock # lets you do a fresh 'bundle install'

    # do a fresh bundle install
    bundle install

## Other

Bundler is still a moving target as far as bugs goes.  It's getting
better with each release, so many of these issues might not exist by
the time you start using it.  Meanwhile, hopefully this list above is
will save you some time with bundler related headaches.  Let me know
in the comments if you've encountered other tips for resolving these
problems.
