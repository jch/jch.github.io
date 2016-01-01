# Protecting Resque::Server

Resque ships with a Sinatra app that can be mounted within your application for
inspecting the status of your workers and jobs. By default, there's no
authentication built in. But thanks to the fact that Sinatra is rack-able, you
can put a middleware in front of it for handling authentication. For example, to
add HTTP Basic auth, you can use Rack's built-in
[Rack::Auth::Basic](https://github.com/chneukirchen/rack/blob/master/lib/rack/auth/basic.rb).

### HTTP Basic authentication

```ruby
protected_app = Rack::Auth::Basic.new(Resque::Server) do |username, password|
  password == 'some-secret'
end

# mount protected_app in Rails, or other rack application…
```

This kind of works, but I always forget the password and have to look it up. It
also sucks for on boarding new developers since it's not very discoverable. An
improved solution is to piggyback onto your existing authentication system. For
one of our apps, we use Devise, which exposes the user object in the Rack `env`
object. Roughly, our rescue authentication looks like:

### Devise or other authentication library

```ruby
# config/initializers/resque.rb
class AuthenticatedMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['warden'].authenticated? && env['warden'].user.staff?
      @app.call(env)
    else
      [403, {'Content-Type' => 'text/plain'}, ['Authenticate first']]
    end
  end
end

Resque::Server.use(AuthenticatedMiddleware)

# config/routes.rb
mount Resque::Server, :at => '/resque'
```

If the main application is a Rails app, you can also use [routing
constraints](http://guides.rubyonrails.org/routing.html#advanced-constraints) to
limit access. The benefit here is the Rail request and session object are
available. For example, in another internal-only application, we only check that
the session includes a user id:

### Rails route contraints

```ruby
# config/routes.rb
class SessionAuthenticatedConstraint
  def self.matches?(request)
    !request.session[:user_id].blank?
  end
end

constraints(SessionAuthenticatedConstraint) do
  mount Resque::Server, :at => '/resque'
end
```

Overall, I prefer the last approach because it's easy to understand, easy to
test, idiomatic of Rails conventions, and short.

Shout outs to
[@kdaigle](https://twitter.com/kdaigle) for code reviewing me and suggesting the
last approach, and [@jonmagic](https://twitter.com/jonmagic) for reviewing this post.
