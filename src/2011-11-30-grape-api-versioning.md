# Behind the Curtain: Grape API Versioning

*Republished from [Opperator blog](http://blog.opperator.com/post/13546958887/grape-api-versioning)*

<i>**Behind the Curtain** posts explore the development of a piece of Opperator's architecture, including the what, why, and how.</i>

[Grape](http://github.com/intridea/grape) is a Ruby framework for building
restful APIs on the web. We're using it extensively to build
[Opperator](http://opperator.com). Out of the box, Grape has built-in support
for versioning your APIs. There's general information about how to use
versioning in the Grape README and the wiki, but this post is more about
digging into the nitty-gritty and discussing some of the design decisions and
implementation details that've been merged in recently.

## Path Based Versioning

Previously, Grape supported API versioning by prefixing the version name in
the url.  For example:

    class MyAPI < Grape::API
      version :v1

      # GET /v1/cows
      get '/cows' do
        # retrieve bovine goodness
      end
    end

When `version` is called, the version names are passed into
`Grape::Middleware::Versioner` [pre-refactored
file](https://github.com/intridea/grape/blob/ca7ad7d29799fec6bddc4a0639004b7ff3b85f77/lib/grape/middleware/versioner.rb)
When a request comes in, the middleware looks for a matching version in the
path. If it finds the version, it rewrites the path info without the version
prefix, sets `env[api.version]`, and moves along it's merry way. If no version
is matched, then a 404 is thrown.

## Header Based Versioning

This works as you'd expect, but introduces your versioning scheme into your
resource uri's. Workable, but it messes up those pretty restful uris.
Fortunately, the HTTP protocol [Accept
header](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html) is a perfect
fit for this problem. RFC 2616 defines the Accept header as:

<blockquote>
The Accept request-header field can be used to specify certain media types
which are acceptable for the response. Accept headers can be used to indicate
that the request is specifically limited to a small set of desired types, as
in the case of a request for an in-line image.
</blockquote>

While the example the RFC gives is related to multimedia, if you squint and
replace the references to media with 'version', then you have a good overview
of header based API versioning. This Accept header field can be used to scope
a request to a specific API version. For example, the [Github
API](http://developer.github.com) understands the following Accept header:

    Accept: application/vnd.github-v1+json

The client who sent this header is asking the server "Hey Github, can you give
me a responses that is version v1 and formatted in JSON?". When Github sees
this request, it can do one of two things. If it's able to answer the
question, then it processes the request as normal. However, if Github doesn't
understand the Accept field value, then it should send a 406 Not Acceptable
response.

Revisiting our code sample, we would define our API as follows:

    class MyAPI < Grape::API
      version :v1, :using => :header, :vendor => 'intridea', :format => :json

      # GET /cows
      get '/cows' do
        # retrieve bovine goodness
      end
    end

Header based versioning is the new default versioning strategy, but I
explicitly specified it in the example for clarity. The `vendor` option is new
and is a way to describe the vendor providing this API, and the `format`
option is the expected response format. Similar to path based versioning,
`Grape::Middleware` is responsible for figuring out the version being
requested and setting `env[api.version]`. But since there are now multiple
strategies for handling versions, `Grape::Middleware::Versioner` has been
split into two middlewares. `Grape::Middleware::Versioner::Path` is the
original path based middleware, and `Grape::Middleware::Versioner::Header` is
the new kid on the block. [Relevant commit
here](https://github.com/intridea/grape/blob/12e44781d7e825644dba5ad52e98c95239923e74/lib/grape/middleware/versioner/header.rb)

This new middleware will use the following format in the Accept header when
matching for versions:

    application/vnd.:vendor-:version+:format

These are the fields that are original declared when `version` was first
called. If the middleware is able to match these fields, then the endpoint is
called with some extra environment variables 'api.vendor', 'api.version', and
'api.format'. If the version couldn't be matched, then the middleware returns
404 **and also sets the X-CASCADE header to pass**. That last part is
important because it allows [Rack::Mount](https://github.com/josh/rack-mount)
to keep looking for other endpoints which might match the version.

You can also control the routing behavior when no Accept header is specified
with the `strict` option. If `strict` is set to true, then a 404 will be
returned when no Accept is set. If `strict` is false, then the first matched
endpoint is returned. This is inline with the RFC definition and basically
means that the client doesn't care which version the server responds with.
Most likely, if `strict` is set to false, you'd like to use the latest
available version. To achieve this, you should mount your latest version as
high as possible (similar to routes precedence in Rails)

    class MyAPI < Grape::API
      # version v2 has higher precedence than v1
      version :v2, :strict => false do
        get '/cows' do
        end
      end

      version :v1 do
        get '/cows' do
        end
      end
    end

## Custom Versioning Strategies

Currently, path and header based versioning are what's understood, but we've
opened up the possibility of custom versioning strategies. Prefer to do domain
based versioning? Or IP-based versioning? If you want to get really wacky, you
can even version based on the lunar calendar.

Extra thanks goes out to [jwkoelewijn](https://github.com/jwkoelewijn) for
creating the initial feature branch and kicking off the discussion.
