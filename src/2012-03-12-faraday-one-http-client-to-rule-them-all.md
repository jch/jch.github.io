# Faraday: One HTTP Client to Rule Them All

<img align="right" src="/images/faraday-cage.jpg" />
Faraday is a Ruby HTTP client which allow developers to customize its behavior with middlewares. If you're familiar with [Rack](http://rack.rubyforge.org/), then you'll love Faraday. Rather than re-implement yet another HTTP client, Faraday has adapters for popular libraries like Net::HTTP, excon, patron, and em-http. On top of having a consistent interface between different adapters, Faraday also allows you to manipulate request and responses before and after a request is executed.  This tutorial gives an introduction of common use cases built into Faraday, and also explains how to extend Faraday with custom middleware. The code is well tested and easy to follow, so I recommend browsing the source code to find extra options and features not covered in this tutorial.


## Basics

Out of the box, Faraday functions like a normal HTTP client with a easy to use interface.

```ruby
Faraday.get 'http://example.com'
```

Alternatively, you can initialize a `Faraday::Connection` instance:

```ruby
conn = Faraday.new
response = conn.get 'http://example.com'
response.status
response.body

conn.post 'http://example.com', :some_param => 'Some Value'
conn.put  'http://example.com', :other_param => 'Other Value'
conn.delete 'http://example.com/foo'
# head, patch, and options all work similarly
```

Parameters can be set inline as the 2nd hash argument. To specify headers, add optional hash after the parameters argument or set them through an accessor:

```ruby
conn.get 'http://example.com', {}, {'Accept' => 'vnd.github-v3+json'}

conn.params  = {'tesla' => 'coil'}
conn.headers = {'Accept' => 'vnd.github-v3+json'}
```

If you have a restful resource you're accessing with a common base url, you can pass in a `:url` parameter that'll be prefixed to all other calls. Other request options can also be set here.

```ruby
conn = Faraday.new(:url => 'http://example.com/comments')
conn.get '/index'  # GET http://example.com/comments/index
```

All HTTP verb methods can take an optional block that will yield a `Faraday::Request` object:

```ruby
conn.get '/' do |request|
  request.params['limit'] = 100
  request.headers['Content-Type'] = 'application/json'
  request.body = "{some: body}"
end
```

### File upload

```ruby
payload = { :name => 'Maguro' }

# uploading a file:
payload = { :profile_pic => Faraday::UploadIO.new('avatar.jpg', 'image/jpeg') }

# "Multipart" middleware detects files and encodes with "multipart/form-data":
conn.put '/profile', payload
```

### Authentication

Basic and Token authentication are handled by `Faraday::Request::BasicAuthentication` and `Faraday::Request::TokenAuthentication` respectively. These can be added as middleware manually or through the helper methods.

```ruby
conn.basic_auth('pita', 'ch1ps')
conn.token_auth('pitach1ps-token')
```

### Proxies

To specify an HTTP proxy:

```ruby
Faraday.new(:proxy => 'http://proxy.example.com:80')
Faraday.new(:proxy => {
  :uri      => 'http://proxy.example.com',
  :user     => 'foo',
  :password => 'bar'
})
```

### SSL

See the [Setting up SSL certificates](https://github.com/technoweenie/faraday/wiki/Setting-up-SSL-certificates) wiki page.

```ruby
conn = Faraday.new('https://encrypted.google.com', :ssl => {
  :ca_path => "/usr/lib/ssl/certs"
})
conn.get '/search?q=asdf'
```

## Faraday Middleware

Like a Rack app, a `Faraday::Connection` object has a list of middlewares. Faraday middlewares are passed an `env` hash that has request and response information. Middlewares can manipulate this information before and after a request is executed.

To make this more concrete, let's take a look at a new `Faraday::Connection`:

```ruby
conn = Faraday.new
conn.builder

> #<Faraday::Builder:0x00000131239308
    @handlers=[Faraday::Request::UrlEncoded, Faraday::Adapter::NetHttp]>
```

`Faraday::Builder` is analogus to `Rack::Builder`. The newly initialized `Faraday::Connection` object has a middleware `Faraday::Request::UrlEncoded` in front of an adapter `Faraday::Adapter::NetHttp`. When a connection object executes a request, it creates a shared `env` hash, wraps the outer middlewares around each inner middleware, and executes the `call` method. Also like a Rack application, the adapter at the end of the builder chain is what actually executes the request.

Middlewares can be grouped into 3 types: request middlewares, response middlewares, and adapters. The distinction between the three is cosmetic. The following two initializers are equivalent:

```ruby
Faraday.new do |builder|
  builder.request  :retry
  builder.request  :basic_authentication, 'login', 'pass'
  builder.response :logger
  builder.adapter  :net_http
end

Faraday.new do |builder|
  builder.use Faraday::Request::Retry
  builder.use Faraday::Request::BasicAuthentication, 'login', 'pass'
  builder.use Faraday::Response::Logger
  builder.use Faraday::Adapter::NetHttp
end
```

### Using a Different HTTP Adapter

If you wanted to use a different HTTP adapter, you can plug one in. For example, to use a EventMachine friendly client, you can switch to the EMHttp adapter:

```ruby
conn = Faraday.new do |builder|
  builder.use Faraday::Adapter::EMHttp

  # alternative syntax that looks up registered adapters from lib/faraday/adapter.rb
  builder.adapter :em_http
end
```

Currently, the supported adapters are Net::HTTP, EM::HTTP, Excon, and Patron.

### Advanced Middleware Usage

The order in which middleware is stacked is important. Like with Rack, the first middleware on the list wraps all others, while the last middleware is the innermost one, so that's usually the adapter.

```ruby
conn = Faraday.new(:url => 'http://sushi.com') do |builder|
  # POST/PUT params encoders:
  builder.request  :multipart
  builder.request  :url_encoded

  builder.adapter  :net_http
end
```

This request middleware setup affects POST/PUT requests in the following way:

1. `Request::Multipart` checks for files in the payload, otherwise leaves everything untouched;
2. `Request::UrlEncoded` encodes as "application/x-www-form-urlencoded" if not already encoded or of another type

Swapping middleware means giving the other priority. Specifying the "Content-Type" for the request is explicitly stating which middleware should process it.

Examples:

```ruby
payload = { :name => 'Maguro' }

# uploading a file:
payload = { :profile_pic => Faraday::UploadIO.new('avatar.jpg', 'image/jpeg') }

# "Multipart" middleware detects files and encodes with "multipart/form-data":
conn.put '/profile', payload
```

### Modifying the Middleware Stack

Each `Faraday::Connection` instance has a `Faraday::Builder` instance that can be used to manipulate the middlewares stack.

```ruby
conn = Faraday.new
conn.builder.swap(1, Faraday::Adapter::EMHttp)  # replace adapter
conn.builder.insert(0, MyCustomMiddleware)      # add middleware to beginning
conn.builder.delete(MyCustomMiddleware)
```

For a full list of actions, take a look at the `Faraday::Builder` documentation.

### Writing Middleware

Middleware are classes that respond to `call`. They wrap the request/response cycle. When it's time to execute a middleware, it's called with an `env` hash that has information about the request and response. The general interface for a middleware is:

```ruby
class MyCustomMiddleware
  def call(env)
    # do something with the request

    @app.call(env).on_complete do |env|
      # do something with the response
      # env[:response] is now filled in
    end
  end
end
```

It's important to do all processing of the response only in the on_complete block. This enables middleware to work in parallel mode where requests are asynchronous.

`env` is a hash with symbol keys that contains info about the request and response.

```
:method - a symbolized request method (:get, :post, :put, :delete, :option, :patch)
:body   - the request body that will eventually be converted to a string.
:url    - URI instance for the current request.
:status           - HTTP response status code
:request_headers  - hash of HTTP Headers to be sent to the server
:response_headers - Hash of HTTP headers from the server
:parallel_manager - sent if the connection is in parallel mode
:request - Hash of options for configuring the request.
  :timeout      - open/read timeout Integer in seconds
  :open_timeout - read timeout Integer in seconds
  :proxy        - Hash of proxy options
    :uri        - Proxy Server URI
    :user       - Proxy server username
    :password   - Proxy server password
:response - Faraday::Response instance. Available only after `on_complete`
:ssl - Hash of options for configuring SSL requests.
  :ca_path - path to directory with certificates
  :ca_file - path to certificate file
```

### Testing Middleware

Faraday::Adapter::Test is an HTTP adapter middleware that lets you to fake responses.

```ruby
# It's possible to define stubbed request outside a test adapter block.
stubs = Faraday::Adapter::Test::Stubs.new do |stub|
  stub.get('/tamago') { [200, {}, 'egg'] }
end

# You can pass stubbed request to the test adapter or define them in a block
# or a combination of the two.
test = Faraday.new do |builder|
  builder.adapter :test, stubs do |stub|
    stub.get('/ebi') {[ 200, {}, 'shrimp' ]}
  end
end

# It's also possible to stub additional requests after the connection has
# been initialized. This is useful for testing.
stubs.get('/uni') {[ 200, {}, 'urchin' ]}

resp = test.get '/tamago'
resp.body # => 'egg'
resp = test.get '/ebi'
resp.body # => 'shrimp'
resp = test.get '/uni'
resp.body # => 'urchin'
resp = test.get '/else' #=> raises "no such stub" error

# If you like, you can treat your stubs as mocks by verifying that all of
# the stubbed calls were made. NOTE that this feature is still fairly
# experimental: It will not verify the order or count of any stub, only that
# it was called once during the course of the test.
stubs.verify_stubbed_calls
```

### Useful Middleware

* [faraday-middleware](https://github.com/pengwynn/faraday_middleware) - collection of Faraday middlewares.
* [faraday_yaml](https://github.com/dmarkow/faraday_yaml) - yaml request/response processing

