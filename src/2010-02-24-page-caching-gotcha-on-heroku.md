# Page Caching Gotcha on Heroku #

Andrew noticed that his beer reviews weren't showing up on
[beerpad](http://beerpad.heroku.com/) after he published them. His reviews
were saved in the database and showed up on redeploy. I smelled a caching bug.
Digging a little deeper, I found out that caches_page and expire_page are
[overridden](http://github.com/ricardochimal/rails/commit/ecd52a0f6b841d8a84f95fddff1ae4c774e4440e)
on Heroku to set http caching headers rather than write a file to the local
filesystem. While I was fixing this bug, I picked up on a lot of useful
details about Rails action caching and configuration. Details and my fix after
the jump.

With Heroku's [read-only
filesystem](http://docs.heroku.com/constraints#read-only-filesystem) and [dyno
architecture](http://heroku.com/how/architecture), it doesn't make sense to
write rendered pages to file. However, in order to be compatible with existing
apps, Heroku uses the [caches_page_via_http
plugin](http://github.com/pedro/caches_page_via_http) to cache entire
responses in the [Varnish layer](http://docs.heroku.com/http-caching) for a
few minutes. The problem with this is that expire_page is overridden to be
noop, so stale pages can be served to users even if your code calls
expire_page in the correct places.

For example, my original code did the following:

1. update a beer review
2. expire the cached page for /reviews
3. redirect to /reviews

After a user submits their review, they should see their review at the top of
the reviews listing at /reviews. With Heroku's patch, step 2 becomes a noop,
and caches_page sets /reviews Cache-Control header to have a max age of 5
minutes. If a user finishes writing a review in less than 5 minutes from the
previous page cache, a stale page is served to them *without* their published
review.  As a user, you'd think "crap, my review got nuked".  For example:

1. GET /reviews - cached in Varnish and client browser for 5 minutes.
2. GET /reviews/new - start a beer review.
3. write quick review and submit in < 5 minutes.
4. POST /reviews - **should** expire page, but is noop instead.
5. redirect GET /reviews - stale page served from browser cache b/c < 5 minutes has elapsed.

After I figured this out, I switched my controller and sweepers to use
[caches_action and
expire_action](http://api.rubyonrails.org/classes/ActionController/Caching/Actions.html)
to make expiration work again.

A minor gotcha with expire_action is you cannot use restful route helpers by
default. The default cache_path used to key a cached value includes the
hostname. If you try to expire using the route helpers, your key won't match
and the cached value won't be expired.

    # original page caching expiration
    expire_page reviews_path

    # new action caching expiration, note that options for path_for are passed in
    # instead of using restful route helpers.
    expire_action :controller => 'reviews', :action => 'index'

## Multiple Dynos ##

Replacing page caching with action caching solves the problem caused by noop
expiration. But using the default memory cache store with multiple dynos will
still cause stale pages to be served. The new problem is that each dyno keeps
it's own local memory cache, which means when you expire the cache, you're
only expiring one dyno's cache rather than expiring all the caches. To get
around this, we need to use a centralized cache store like Memcached or DRb.
The Rails guide on caching has a [good
explanation](http://guides.rubyonrails.org/caching_with_rails.html#cache-stores)
of the cache stores available and their differences.

On Heroku, turning on Memcached is [really simple and well
documented](http://docs.heroku.com/memcached):

    # in terminal at rails root
    heroku addons:add memcached

    # config/initializers/memcached.rb - initialize connection to memcached on heroku
    if ENV['MEMCACHE_SERVERS']
      require 'memcache'
      servers = ENV['MEMCACHE_SERVERS'].split(',')
      namespace = ENV['MEMCACHE_NAMESPACE']
      CACHE = MemCache.new(servers, :namespace => namespace)
    end

    # config/environments/production.rb - use memcached as cache store
    if ENV['MEMCACHE_SERVERS']
      memcache_config = ENV['MEMCACHE_SERVERS'].split(',')
      memcache_config << {:namespace => ENV['MEMCACHE_NAMESPACE']}
      config.cache_store = :mem_cache_store, memcache_config
    end

I wrote a testing controller with 2 actions, and increased my dynos to 2 to
compare the default memory cache store and memcached cache store.

    class TestingController < ApplicationController
      caches_action :caching
      def caching
        render :text => "I was rendered at #{Time.now}"
      end

      def blocking
        sleep 10
        render :text => "finished blocking at #{Time.now}"
      end
    end

Once pushed and deployed, I repeatedly hit /testing/caching, and
/testing/blocking from separate tabs. With the default memory cache store, I
saw 2 different times on /testing/caching. Once I configured Rails to use
memcached as the cache store, I saw only be a single time on /testing/caching.
This makes sense because both dynos are pulling from the same centralized
cache.

The moral of the story is to not use page caching on Heroku for pages that
need to be manually expired. Personally, I'm just going to set http expiration
headers myself to make the code's behavior more transparent and consistent
between local development and Heroku production.

## Useful debugging tips ##

To see the cache store currently being used and the contents of your cache:

    script/console production
    app.get '/'
    # tells you what cache_store is being used, and what's in your cache
    app.controller.send(:cache_configured?)

Sweepers have a reference to the controller, so it's useful to set a
breakpoint before and after the call to expire_action:

    # in review_sweeper.rb
    def after_save(obj)
      debugger
      # inspect 'cache_configured?' or 'self.controller.send(:cache_configured?)'
      expire_action :controller => 'reviews', :action => 'index'
    end

## Reference Links ##

* [RailsGuides - Caching with Rails](http://guides.rubyonrails.org/caching_with_rails.html) - great overview of caching, and explains cache memory stores.
* [Rails action caching documentation](http://api.rubyonrails.org/classes/ActionController/Caching/Actions.html)
* [Rails page caching documentation](http://api.rubyonrails.org/classes/ActionController/Caching/Pages.html)
* [Heroku HTTP caching documentation](http://docs.heroku.com/http-caching)
* [Heroku Memcached documentation](http://docs.heroku.com/memcached)
* [Resource Expert Droid](http://redbot.org/) - useful service for inspecting http response headers
