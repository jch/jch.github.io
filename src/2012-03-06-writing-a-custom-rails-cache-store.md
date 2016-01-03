# Writing a Custom Rails Cache Store

When you use Rails built-in helpers for page, action, and fragment caching, the cached data is stored into an instance of ActiveSupport::Cache::Store. But while the interface for using the cache stores are the same, each cache store implementation has different performance characteristics and are suited for different jobs. In this post, I'll cover what cache stores are available with Rails by default, how to tune them, and how to write your own custom cache store.

## Grabbing the Code

If you want to follow along in the code, I recommend cloning the [Rails repository](https://github.com/rails/rails/). The cache related code I'm covering all live within [activesupport/lib/cache.rb](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/cache.rb) and [activesupport/lib/cache](https://github.com/rails/rails/tree/master/activesupport/lib/active_support/cache) folder. The corresponding tests live in [activesupport/test/caching_test.rb](https://github.com/rails/rails/blob/master/activesupport/test/caching_test.rb).

## Introducing the Abstract Store

All cache store implementations inherit from an abstract store named [ActiveSupport::Cache::Store](http://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html). This class defines the public interface that's used by Rails to do caching. The three basic operations are read, write, and delete. Here's a simple example you can run in irb:

```ruby
require 'activesupport'
cache = ActiveSupport::Cache.lookup_store(:memory_store)
cache.read('foo')
=> nil
cache.write('foo', 'bar')
cache.read('foo')
=> 'bar'
cache.delete('foo')
cache.read('foo')
=> nil
```

After requiring activesupport, we ask for an instance of a MemoryStore (we'll cover the different store types later in this post). The interface for read, write, and delete are self explanatory. You can also [customize the behavior](http://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html) of these actions.

## Store Implementations

The concrete store implementations are well documented, so I'll introduce them briefly here and leave the details to the documentation.

* **MemoryStore** - a cache store that stores data in a plain-old Ruby hash. As an added feature, it keeps track of cache access and cache size, and will prune the cache when it hits a customizable max size.

* **FileStore** - a cache store that stores data on the filesystem. It also caches multiple read calls within the same block in memory to decrease I/O.

* **MemCacheStore** - the big daddy of cache stores. Backed by memcached, this store allows you to specify multiple memcached servers and load balances between them.

* **NullStore** - Interesting cache store that does nothing. That's right, if you look at [its implementation](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/cache/null_store.rb), it's just a bunch of empty methods. It's perfect for use as a mock cache store for testing, or as a template for writing your own cache store.

## Rails Initialization

By default, Rails 3 will initialize a FileStore that you can reference through `Rails.cache`. This cache is used internally by Rails to cache classes, pages, actions, and fragments. If you want to change which cache store is used, you can configure it in your application.rb

```
# use a MemoryStore cache with a max size of 512 megabytes
config.cache_store = [:memory_store, {:size => 536870912}]
```

In production mode, Rails will also insert [Rack::Cache](http://rtomayko.github.com/rack-cache/) to the top of the middleware stack and use Rails.cache as its storage. Note that even though Rack::Cache's heap storage does not bound the size of its cache, if you use ActiveSupport's MemoryStore, the least recently used entries will be pruned from the cache when it hits your specified limit. So if you [set correct cache headers](http://tomayko.com/writings/things-caches-do), Rack::Cache will pick them and cache your responses.

## Writing A Custom Cache Store

The default cache stores are a perfect fit for most situations, but if you do need to write a custom cache store, rest assured that it's easy to do.

The three main methods to override are:

```ruby
# Read an entry from the cache implementation. Subclasses must implement this method.
def read_entry(key, options) # :nodoc:
  raise NotImplementedError.new
end

# Write an entry to the cache implementation. Subclasses must implement this method.
def write_entry(key, entry, options) # :nodoc:
  raise NotImplementedError.new
end

# Delete an entry from the cache implementation. Subclasses must implement this method.
def delete_entry(key, options) # :nodoc:
  raise NotImplementedError.new
end
```

These methods are then used by the public interface methods. There are a few methods you can optionally implement, but your cache will work with just the three listed above.

For a client project, I wrote a write-through cache store called [CascadeCache](https://github.com/jch/activesupport-cascadestore) that chains multiple cache stores together. For example, here's one possible configuration:

```ruby
config.cache_store = [:cascade_store, {
  :stores => [
    [:memory_store, :size => 5.megabytes],
    [:memcache_store, 'somehost:11211']
  ]
}]
```

The behavior of this cache store is to return the first hit from the list of caches. This allows the app to have a small low-latency MemoryStore in front of a MemCacheStore. If something can't be found in the MemoryCache, then we fall back to MemCache. When writing to the cache, entries are written through to both underlying cache stores. The primary reason for doing this wasn't because MemCache store was slow, but as an extra backup cache in case MemCache became temporarily unavailable (actually happened in production).

I'm hoping CascadeCache makes it upstream into ActiveSupport, but in the meantime, I've packaged it up as a [separate gem](https://github.com/jch/activesupport-cascadestore). For another example of a custom cache implementation, check out [redis-store](https://github.com/jodosha/redis-store). It includes an ActiveSupport compatible cache.

Caching is a tricky beast. On top of deciding what to cache and when to expire, the underlying cache store can affect your app's performance. Choose the cache store that best fits your needs, use a hybrid CascadeCache, or write your own. Good luck and happy tuning!
