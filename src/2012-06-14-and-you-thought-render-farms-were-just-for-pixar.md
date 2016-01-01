# And You Thought Render Farms Were Just For Pixar!

Rails views are typically rendered after some controller action is executed. But the code that powers Rails controllers is flexible and extensible enough to create custom rendering objects that can reuse views and helpers, but live outside of web request processing. In this post, I'll cover what a Rails controller is and what it's composed of. I'll also go over how to extend it to create your own custom renderers, and show an example of how you can render views in your background jobs and push the results to your frontend.

## What's a Controller?

A Rails controller is a subclass of `ActionController::Base`. The [documentation](http://api.rubyonrails.org/classes/ActionController/Base.html) says:

> Action Controllers are the core of a web request in Rails. They are made up of one or more actions that are executed on request and then either render a template or redirect to another action. An action is defined as a public method on the controller, which will automatically be made accessible to the web-server through Rails Routes.

While `Base` suggests that this is a root class, it actually inherits from `ActionController::Metal` and `AbstractController::Base`. Also, some of the core features such as rendering and redirection are actually mixins. Visually, this class hierarchy looks something like:

<img src="http://f.cl.ly/items/1b1Z2N0k0r3H1a3t3f0P/Screen%20Shot%202012-06-12%20at%209.38.55%20PM.png" />

`ActionController::Metal` is a stripped down version of what we know as controllers. It's a [rackable](http://guides.rubyonrails.org/rails_on_rack.html) object that understands HTTP. By default though, it doesn't have know anything about rendering, redirection, or route paths.

`AbstractController::Base` is one layer above `Metal`. This class dispatches calls to known actions and knows about a generic response body. An `AbstractController::Base` doesn't assume it's being used in an HTTP request context. In fact, if we peek at the source code for [actionmailer](http://api.rubyonrails.org/classes/ActionMailer/Base.html), we'll see that it's a subclass of `AbstractController::Base`, but used in the context of generating emails rather than processing HTTP requests.

```ruby
module ActionMailer
  class Base < AbstractController::Base
    include AbstractController::Logger
    include AbstractController::Rendering  # <- ActionController::Base also uses
    include AbstractController::Layouts    # <- these mixins, but for generating
    include AbstractController::Helpers    # <- HTTP response bodies, instead of email response bodies
    include AbstractController::Translation
    include AbstractController::AssetPaths
  end
end
```

## Custom Controller for Background Job Rendering

For a recent project, I needed to execute flight searches in background jobs against an external API. Initially, I planned to push the search results as a json object and render everything client-side, but I wanted to reuse existing Rails views, helpers, and route path helpers without redefining them in the frontend. Also, because of differing client performance, rendering server-side [improves page load times for users](http://engineering.twitter.com/2012/05/improving-performance-on-twittercom.html) in this instance. Architecturally, what I wanted looks like:

<img src="http://f.cl.ly/items/0m082R153Z2D3L1A0t1h/Screen%20Shot%202012-06-12%20at%209.47.36%20PM.png" />

The requirements for this custom controller were:

* access to route helpers
* renders templates and partials in app/views

Unlike a full blown `ActionController`, this custom controller doesn't need to understand HTTP. All it needs is the result of the flight search from background workers to be able to render an html response.

The full code for the custom controller is:

```ruby
class SearchRenderer < AbstractController::Base
  include Rails.application.routes.url_helpers  # rails route helpers
  include Rails.application.helpers             # rails helpers under app/helpers

  # Add rendering mixins
  include AbstractController::Rendering
  include AbstractController::Logger

  # Setup templates and partials search path
  append_view_path "#{Rails.root}/app/views"

  # Instance variables are available in the views,
  # so we save the variables we want to access in the views
  def initialize(search_results)
    @search_results = search_results
  end

  # running this action will render 'app/views/search_renderer/foo.html.erb'
  # with @search_results, and route helpers available in the views.
  def execute
    render :action => 'foo'
  end
end
```

A runnable example of this source code is available at [this github repository](https://github.com/jch/custom-controller-renderer).

Breaking down the above code, the first thing we do is inherit from `AbstractController::Base`:

```ruby
class SearchRenderer < AbstractController::Base
  def initialize(search_results)
    @search_results = search_results
  end
end
```

We also save the search results in an instance variable so that our templates can access them later.

```ruby
  include Rails.application.routes.url_helpers  # rails route helpers
  include Rails.application.helpers             # rails helpers under app/helpers
```

These methods return Rails route helpers like `resource_path` and `resource_url`, and also any helpers defined in `app/helpers`.

Next we add the mixins we need to be able to call the `#render` controller method. Calling `#append_view_path` sets up the view lookup path to be the same as our Rails controller views lookup path.

```ruby
  include AbstractController::Rendering
  include AbstractController::Logger

  append_view_path "#{Rails.root}/app/views"
```

Then we define a controller action named `execute` that'll render out the response as a string. The `#render` method used here is very similar to the one used by `ActionController`.

```ruby
  def execute
    render :action => 'foo'
  end
```

To use this renderer object, you need to initialize it with a search results object, and call `#execute`:

```ruby
search_results = [{:foo => "bar"}, {:foo => "baz"}]
renderer = SearchRenderer.new(search_results)
renderer.execute
```

## Summary

Rails ActionControllers are specific to HTTP, but its abstract parent class can be used to construct objects for generic controller objects for coordinating actions outside of an HTTP context. Custom controller objects can be composed with the available mixins to add common functionality such as rendering. These custom controllers can also share code with existing Rails applications DRY up templates and helpers.

