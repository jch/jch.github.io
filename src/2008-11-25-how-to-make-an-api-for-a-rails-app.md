# How to Make an API for a Rails App #

I've come across the same problem in my personal projects and also at
work.  You have an existing Rails app that has some authentication and
authorization scheme to protect who has access to your controllers,
but now you need to write an API that can access those controllers.
How do you keep the same authentication routine for your API users?

The are two approaches I've seen used.  One is based on using HTTP
AuthBasic, and the other is to generate a unique API key for API
users.

## Option 1: HTTP Basic Auth ##

I learned this snippet from working with [Mike](http://overhrd.com/).
Rails 2.x support [HTTP Basic Auth](http://railscasts.com/episodes/82)
out of the box.  For our app, we check the request format and only do
basic auth if the format is xml.

    class ApplicationController < ActionController::Base
      protected
      def http_basic_authentication
        if request.format == Mime::XML
          authenticate_or_request_with_http_basic do |username, password|
            username == 'foo' && password == 'bar'
          end
        end
      end
    end

Then for controllers that allow API access, we simply add a before
filter.

    class OrangesController < ActionController::Base
      before_filter :http_basic_authentication, :only => :create

      def create
        # do stuff
      end
    end

Then to create an Orange via the API, we could do:

    # we expect an XML response, so we suffix url with 'xml'
    # optionally, we can also add 'foo:bar@' before the domain name.
    url = URI.parse("http://example.com/oranges.xml")

    req = Net::HTTP::Post.new(url.path)
    req.basic_auth 'foo', 'bar'

    req.set_form_data({'size' => 'large', 'juicy' => '1'})
    http = Net::HTTP.new(url.host, url.port)
    response = http.start {|http| http.request(req) }

(Note: Beware of ssl, remember to set <code>http.use_ssl =
true</code>)

## Options 2: Using API key ##

I didn't know about HTTP Basic Auth when I was writing my [Money
app](http://money.whatcodecraves.com/), so I took a little time to
fully understand how Rail's
[ActionController::Filters](http://api.rubyonrails.org/classes/ActionController/Filters/ClassMethods.html)
work.  The documentation is clear and the source is straightforward to
understand.

For API authentication, I decided to write my own custom filter
object and put it in lib/api\_authorized\_filter.rb

    # Use this filter as an around_filter around actions that can be
    # accessed via the API.
    #
    # Example:
    #   class ItemsController < ApplicationController
    #     prepend_around_filter ApiAuthorizedFilter.new, :only => [:create]
    #   end
    #
    class ApiAuthorizedFilter
      def before(controller)
        return true unless controller.params[:api_key]
        controller.current_user = User.find_by_api_key(controller.params[:api_key]))
      end

      def after(controller)
        controller.current_user = nil
      end
    end

ApiAuthorizedFilter is put at the very beginning of the filter chain
with <code>prepend\_around\_filter</code>, before any normal
authentication <code>before\_filters</code>.  When it's called, the
<code>before</code> method is invoked with the current controller, and
the filter 'logins' an API User if the api_key is valid.  When my
normal authentication filters run, they won't halt because it'll seem
like there is a logged in user.  Finally, when the action is finished
running, the <code>after</code> method will log out the API User to
prevent a User from staying logged in.  This last step is optional,
but I think it's better to only let API Users authenticate every time
they need something.

In order to use this Filter, you'll have to add an 'api_key' column to
your User model, and also tweak the <code>before</code> and
<code>after</code> code to login and logout the user.

## Which one should I use? ##

I personally like the latter because the api key gives me another way
to reference a logged in user.  Since the api key is independent of a
user's login and password, it's also easier to replace the key without
resetting the user's web credentials.  Of course, you can make both
methods work the same way, so it's really a matter of personal taste.
