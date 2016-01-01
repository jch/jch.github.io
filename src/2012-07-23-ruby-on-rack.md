# Ruby on Rack

Rack is a simple and flexible library for building Ruby web applications and
web frameworks. It powers frameworks like Rails and Sinatra, and can be used
to build custom reusable components called Rack middleware. If you develop web
apps with Ruby, you're likely using Rack even if you're unaware of it. While
it's typically used to build low-level abstractions close to HTTP, knowing how
to use it leads to more modular designs and allows you to leverage a large
list of existing Rack components. In this post, I introduce what Rack is step
by step, and point towards some useful applications in the wild.

Rack [was released in 2007](http://chneukirchen.org/blog/archive/2007/02
/introducing-rack.html) by Christian Neukirchen. The [project
README](http://rack.rubyforge.org/doc/README.html) starts with:

> Rack provides a minimal, modular and adaptable interface for developing web
> applications in Ruby. By wrapping HTTP requests and responses in the
> simplest way possible, it unifies and distills the API for web servers, web
> frameworks, and software in between (the so-called middleware) into a single
> method call.

Confused? Don't worry, we'll go over each part individually.

> By wrapping HTTP requests and responses in the simplest way possible...

Stepping back from Ruby, what is the 'simplest way' to think about an HTTP
request and response? Without knowing the language or framework an application
is using, the perspective from a webapp looks like:

```
HTTP Request -> Webapp -> HTTP Response
```

An HTTP request has a method like GET or POST, a server host and port, some
uri resource path, and optionally a query string.

```
GET /posts?page=2     # method, resource uri, query string
Accept: 'text/html'   # one or more HTTP headers...
Cookie: 'foo=bar'
X-Custom: 'value'
```

The web application's job is to takes this information and generate a HTTP
response like:

```
200 OK
Content-Type: 'text/html'
Content-Length: 75
<html>
  <body>Hello!</body>
</html>
```

Without knowing **how** the response was generated, the parts of an HTTP
response are the same independent of language and framework. The `200` [status
code](http://en.wikipedia.org/wiki/List_of_HTTP_status_codes) indicates a
successful response. Additionally, [HTTP header
fields](http://en.wikipedia.org/wiki/List_of_HTTP_header_fields) describe what
the response is.

Rack wraps the request and response information into one large hash called the
**environment hash**. Rack passes this `env` hash to your application and
expects a return value with 3 parts:

* **status**  - an HTTP status code
* **headers** - a hash of response headers. e.g. `Content-Type`, `Content-Length`
* **bodies**  - an array-like object that responds to `#each` and yields strings of
                response content

> [rack] unifies and distills the API for web servers, web frameworks ... into
> a single method call

The only entry point that a Rack component must implement is a method named
`#call` that takes the `env` hash as its only argument. For example, the
following is a valid Rack application:

```ruby
class MyApp
  def call(env)
    # env has request/response information
    puts env['PATH_INFO']
    puts env['HTTP_ACCEPT']

    # return status, headers, and response bodies.
    # note that multiple response bodies will be concatenated.
    [200, {'Content-Type' => 'text/html'}, ['Hello!']]
  end
end
```

As an application developer, you can think in terms of the `env` hash instead
of parsing out all the HTTP values manually. The response `MyApp` generates is
returned in the last line as an array, and has the status code, headers, and
list of response bodies.

Rack also provides an object-oriented interface to access request information
and building responses. `MyApp` can also be written as:

```ruby
class MyApp
  def call(env)
    request  = Rack::Request.new(env)
    request.get?     # is the request a GET request?
    request.params   # query parameters
    request.cookies  # yummy

    # do stuff with `request`...

    response = Rack::Response.new
    response['Content-Type'] = 'text/html'
    response.write 'Hello!'

    response.finish  # converts object into rack expected response
  end
end
```

We say something is **rackable** when it responds to a method `#call` that
takes one argument (the `env` hash), and returns a rack compatible response.
For really simple Rack components, a common shortcut is to use a
[lambda](http://www.robertsosinski.com/2008/12/21/understanding-ruby-blocks-
procs-and-lambdas/) to define an anonymous endpoint. Because lambdas and procs
respond to `#call`, it fits the Rack requirement.

```ruby
lambda {|env|
  [200, {'Content-Type' => 'text/plain'}, ['This is a valid rack app']]
}
```

See the documentation for
[Rack::Request](http://rack.rubyforge.org/doc/classes/Rack/Request.html) and
[Rack::Response](http://rack.rubyforge.org/doc/classes/Rack/Response.html) for
details. The [Rack specification](http://rack.rubyforge.org/doc/SPEC.html) has
a full listing of what's available in the environment hash.

Now that we've seen what Rack is, let's explore the benefits from implementing
this contract.

## Application Server Independence

An application server is a library responsible for handling the plumbing of
HTTP. It takes care of things like binding to a port, listening for
connections, parsing headers, and constructing responses. Sometimes they are a
collection of tools each responsible for one part of serving a HTTP request,
other times, they may be one monolithic tool that handles all parts of the
HTTP lifecycle. Each app server has different features, allowing you to choose
one that's right for your needs.

Rack makes it easy to switch between app servers without touching your
application code. For example, to serve our sample application with the
builtin Ruby HTTP server WEBrick:

```ruby
require 'rack'

class MyApp
  def call(env)
    [200, {'Content-Type' => 'text/html'}, ['hello']]
  end
end

Rack::Handler::WEBrick.run(MyApp.new, {:Port => 3000})
```

If you wanted to use a different app server, for example Thin, then you can
change the last line to:

```ruby
Rack::Handler::Thin.run(MyApp.new, {:Port => 3000})
```

Both of the above files can be directly run from the command line. See the
[Rack::Handler
documentation](http://rack.rubyforge.org/doc/classes/Rack/Handler.html) for
details.

## Middleware Architecture

**Rack middleware** is a Rack component that manipulates the environment hash
before invoking another Rack component's `#call` method. Middleware can be
used to modify a request before an application sees it, or modify a response
generated by an application. This is useful for building shared filters that
are independent of the underlying application. For example, to filter the word
'truck' from all response bodies:

```ruby
class ProfanityFilter
  # Middleware need to accept a downstream Rack component
  def initialize(app)
    @app = app
  end

  def call(env)
    # call underlying application, returning the standard rack response
    # @app is always initialized as the `next` rack component to call
    status, headers, bodies = @app.call(env)

    # modify response bodies in place
    bodies.map! {|body| body.gsub! /truck/, ''}

    # return a valid rack response
    [status, headers, bodies]
  end
end
```

This middleware is an example of a middleware that modifies the response
generated by a downstream application. Like other Rack components, it also
uses `#call` as it's entry point. In addition to this, its first constructor
argument has to be another Rack component. The convention is to save this
argument in an instance variable called `@app`. Middleware can determine when
it wants to call the downstream app, and what to do with the app's response.

By having this stackable chain of middleware components feeding into each
other and manipulating each others' inputs and responses, it makes it possible
to compose application behavior in separate reusable components rather than a
single fat blob of code.

## Composing Middleware

Rack comes builtin with a utility object for composing middlewares and
applications together called [Rack::Builder][]. For example the following wraps the `ProfanityFilter`
middleware around the `MyApp` application:

```ruby
app = Rack::Builder.new do
  use ProfanityFilter
  run MyApp
end

Rack::Handler::WEBrick.run(MyApp.new, {:Port => 3000})
```

To further remove boilerplate code, Rack comes with a convenience executable
called `rackup` that allows you to swap out servers without any code. When run
without arguments, `rackup` looks for a file named `config.ru` to configure a
`Rack::Builder` instance:

```ruby
# sample 'config.ru' evaluated within a Rack::Builder instance
use ProfanityFilter
run MyApp
```

Then to run the application from the commandline:

```
> rackup config.ru
> rackup -s thin -p 4000  # use thin as a server and run on port 4000
```

Any additional arguments passed to `use` will be passed to the contructor of
the middleware. Remember that the first argument of a middleware is always the
downstream Rack component:

```ruby
# extra arguments are passed into the middleware constructor
use Rack::Session::Cookie, :key => 'rack.session'
```

## Adding Functionality via Middleware

Multiple Rack components can manipulate the environment hash serially without
knowing what other rack components are being used. Each component run after
the last, and its own response is passed back to the component above it.
Sometimes a middleware will inject additional functionality into the
environment hash for downstream components to use. One example is
[Rack::Session::Cookie][], a middleware that adds a `env['rack.session']`
object for downstream apps to use.

```ruby
use Rack::Session::Cookie

run lambda {|env|
  # Rather than manipulating cookies ourselves, the upstream middleware gave
  # us a helper object to set and read cookies

  puts env['rack.session']  # read what's in our session
  env['rack.session']['some_key'] = 'some_value'  # written to cookie for us
}
```

Because the environment hash is a plain old Ruby hash, you can decorate it
with any functionality you want. Typically the convention is to use string
keys and to namespace the key by the project name. For example, [OmniAuth][]
is a Rack library that allows applications to plugin different authentication
providers. When authentication completes, the relevant auth information is
given in an `env['omniauth.auth']` hash. The values don't have to be Ruby
primitive objects either. In [Rack::Stream][], a library for building
streaming Ruby webapps, `env['stream.app']` is a [Rack::Stream::App][]
instance that has callable methods and features that can be used downstream.
The contract of what's made available downstream is up to individual
libraries, but the separate between each layer helps keep the components
separate and well factored.

### Rails on Rack

Rails is one of the best examples of a complex chain of middleware in action.
In fact, if you generate a bare Rails app, and run `rake middleware`, you'll
see:

```
> rake middleware

use ActionDispatch::Static
use Rack::Lock
use #<ActiveSupport::Cache::Strategy::LocalCache::Middleware:0x007f8424bd1a50>
use Rack::Runtime
use Rack::MethodOverride
use ActionDispatch::RequestId
use Rails::Rack::Logger
use ActionDispatch::ShowExceptions
use ActionDispatch::DebugExceptions
use ActionDispatch::RemoteIp
use ActionDispatch::Reloader
use ActionDispatch::Callbacks
use ActiveRecord::ConnectionAdapters::ConnectionManagement
use ActiveRecord::QueryCache
use ActionDispatch::Cookies
use ActionDispatch::Session::CookieStore
use ActionDispatch::Flash
use ActionDispatch::ParamsParser
use ActionDispatch::Head
use Rack::ConditionalGet
use Rack::ETag
use ActionDispatch::BestStandardsSupport
run MyApp::Application.routes
```

Each item in this list processes an incoming environment hash and calls the
Rack component under it in turn. What do all these entries have in common?
They all respond to `#call`, and they all follow the Rack specification.

The final entry, `MyApp::Application.routes`, is the routes defined by
`config/routes.rb` and is an `ActionDispatch::Routing::RouteSet` object that
maps path info to controller actions. Each Rails controller action is a Rack
endpoint in itself. You can verify this by running the following in a `rails
console`:

```
# assuming a controller named `MyController` with an `index` action:
> rails console
> MyController.action(:show)
#<Proc:0x007ff1ed33bfd0@/Users/jch/.rvm/gems/ruby-1.9.3-p194/gems/actionpack-3.2.6/lib/action_controller/metal.rb:245>
```

You can see that fetching an action by name returns a `Proc` object, which
responds to `#call`.

For additional Rails specific tips and information on Rack, check out the
Rails guide [Rails on
Rack](http://guides.rubyonrails.org/rails_on_rack.html).

## Interesting Rack Projects

* [Rack::Test](https://github.com/brynary/rack-test/) - test rack middleware and apps. Used by other test frameworks.
* [Rack::Cache](http://tomayko.com/writings/rack-cache-announce) - one of my
favorites. Teaches you how HTTP caching works, and a very useful middleware.
Also checkout [activesupport-cascadestore](https://github.com/jch
/activesupport-cascadestore).
* [Rack::Cors](https://github.com/cyu/rack-cors) - cross origin resource sharing. Lets you do cross-domain ajax
* [Rack::Profile](https://github.com/ddollar/rack-profile) - use ruby's profiler to see what's slow
* [rack-contrib](https://github.com/rack/rack-contrib/) - whole bunch of useful middlewares
* [Rack::Recaptcha](https://github.com/achiu/rack-recaptcha)
* [Rack::Rewrite](https://github.com/jtrupiano/rack-rewrite) - rewrite incoming urls
* [Ruby Toolbox Rack Projects](https://www.ruby-toolbox.com/search?utf8=%E2%9C%93&q=rack-)

## Resources

* [Introducing Rack](http://chneukirchen.org/blog/archive/2007/02
/introducing-rack.html) - rack's author Christian Neukirchen explains the
rationale behind writing rack.
* Railscasts has a [Rack Middleware
screencast](http://railscasts.com/episodes/151-rack-middleware).
* [Rails on Rack](http://guides.rubyonrails.org/rails_on_rack.html)


[Rack::Session::Cookie]: http://rack.rubyforge.org/doc/classes/Rack/Session/Cookie.html
[Rack::Stream]: https://github.com/intridea/rack-stream
[Rack::Stream::App]: https://github.com/intridea/rack-stream/blob/master/lib/rack/stream/app.rb
[Rack::Builder]: http://m.onkey.org/ruby-on-rack-2-the-builder
[OmniAuth]: https://github.com/intridea/omniauth