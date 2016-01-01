# Building Streaming REST APIs with Ruby

<img align="right" src="/images/ben-and-jerrys-ice-cream.png" />
Twitter popularized the term "firehose API", to mean a realtime stream of data sent through a persistent connection. But even if you're not a realtime service, streaming APIs are great for pushing data from the backend to clients. They reduce resource usage because the server can decide when it's a good time to send a incremental chunk of data. They can also improve the responsiveness of your user experience.  The same HTTP API can be reused to power multiple different apps. For example, you could write your web frontend with a Javascript frameworks like [Backbone.js](http://documentcloud.github.com/backbone/), but reuse the same API to power a native iOS application. Follow the jump to read about how streaming APIs work, and how you can write one with [Rack::Stream](https://github.com/intridea/rack-stream).

### TL;DR

[Rack::Stream](https://github.com/intridea/rack-stream) is rack middleware that lets you write streaming API endpoints that understand HTTP, WebSockets, and EventSource. It comes with a DSL and can be used alongside other rackable web frameworks such as Sinatra and Grape.

### What's Streaming HTTP?

Normally, when an HTTP request is made, the server closes the connection when it's done processing the request. For streaming HTTP, also known as [Comet](http://en.wikipedia.org/wiki/Comet_(programming)), the main difference is that the server doesn't close the connection and can continue sending data to the client at a later time.

<img src="http://f.cl.ly/items/2P0y3O0O1D0V211b2p40/normal-http.png" alt="normal http" />

<img src="http://f.cl.ly/items/0u031f1N0X1p3M3X1t0B/streaming-http.png" alt="streaming http" />

To prevent the connection from closing, rack-stream uses Thin's ['async.callback'](http://macournoyer.com/blog/2009/06/04/pusher-and-async-with-thin/) to defer closing the connection until either the server decides to close the connection, or the client disconnects.

### Rack::Stream

[Rack::Stream](https://github.com/intridea/rack-stream) is rack middleware that lets you write streaming HTTP endpoints that can understand multiple protocols. Multiple protocols means that you can write an API endpoint that works with curl, but that same endpoint would also works with WebSockets in the browser. The simplest streaming API you can make is:

```ruby
# config.ru
# run with `thin start -p 9292`
require 'rack-stream'

class App
  def call(env)
    [200, {'Content-Type' => 'text/plain'}, ["Hello", " ", "World"]]
  end
end

use Rack::Stream
run App
```

If you ran this basic rack app, you could then use curl to stream it's response:

```sh
> curl -i -N http://localhost:9292/

HTTP/1.1 200 OK
Content-Type: text/plain
Transfer-Encoding: chunked
Connection: close
Server: thin 1.3.1 codename Triple Espresso

Hello World
```

This isn't very exciting, but you'll notice that the `Transfer-Encoding` for the response is set to `chunked`. By default, rack-stream will take any downstream application's response bodies and stream them over in chunks. You can read more about [chunked transfer encoding on Wikipedia](http://en.wikipedia.org/wiki/Chunked_transfer_encoding).

Let's spice it up a bit and build an actual firehose. This next application will keep sending data to the client until the client disconnects:

```ruby
require 'rack-stream'

class Firehose
  include Rack::Stream::DSL

  def call(env)
    EM.add_periodic_timer(0.1) {
      chunk "\nChunky Monkey"
    }
    [200, {'Content-Type' => 'text/plain'}, ['Hello']]
  end
end

use Rack::Stream
run Firehose
```

The first thing to notice is the Firehose rack endpoint includes `Rack::Stream::DSL`. This are convenience methods that allow you to access `env['rack.stream']`, which is injected into `env` whenever you `use Rack::Stream`. When a request comes in, the `#call` method schedules a timer that runs every 0.1 seconds and uses the `#chunk` method to stream data. If you run curl, you would see:

```sh
> curl -i -N http://localhost:9292/

HTTP/1.1 200 OK
Transfer-Encoding: chunked
Connection: close
Server: thin 1.3.1 codename Triple Espresso

Hello
Chunky Monkey
Chunky Monkey
Chunky Monkey
# ... more monkeys
```

rack-stream also allows you to register callbacks for manipulating response chunks, and controlling when something is sent with different callbacks. Here's a more advanced example with callbacks added:

```ruby
require 'rack-stream'

class Firehose
  include Rack::Stream::DSL

  def call(env)
    after_open do
      chunk "\nChunky Monkey"
      close  # start closing the connection
    end

    before_chunk do |chunks|
      chunks.map(&:upcase)  # manipulate chunks
    end

    before_close do
      chunk "\nGoodbye!"  # send something before we close
    end

    [200, {'Content-Type' => 'text/plain'}, ['Hello']]
  end
end

use Rack::Stream
run Firehose
```

If you ran curl now, you would see:

```sh
> curl -i -N http://localhost:9292/

HTTP/1.1 200 OK
Transfer-Encoding: chunked
Connection: close
Server: thin 1.3.1 codename Triple Espresso

HELLO
CHUNKY MONKEY
GOODBYE!
```

For details about the callbacks, see [the project page](https://github.com/intridea/rack-stream).

Up until this point, I've only used curl to demonstrate hitting the rack endpoint, but one of the big benefits of rack-stream is that it'll automatically recognize WebSocket and EventSource requests and stream through those as well. For example, you could write an html file that accesses that same endpoint:

```html
<html>
<body>
  <script type='text/javascript'>
    var socket       = new WebSocket('ws://localhost:9292/');
    socket.onopen    = function()  {alert("socket opened")};
    socket.onmessage = function(m) {alert(m.data)};
    socket.onclose   = function()  {alert("socket closed")};
  </script>
</body>
</html>
```

Whether you access the endpoint with curl, ajax, or WebSockets, your backend API logic doesn't have to change.

For the last example, I'll show a basic chat application using Grape and Rails. The [full runnable source](https://github.com/intridea/rack-stream/tree/master/examples) is included in the `examples/rails` directory.

```ruby
require 'grape'
require 'rack/stream'
require 'redis'
require 'redis/connection/synchrony'

class API < Grape::API
  default_format :txt

  helpers do
    include Rack::Stream::DSL

    def redis
      @redis ||= Redis.new
    end

    def build_message(text)
      redis.rpush 'messages', text
      redis.ltrim 'messages', 0, 50
      redis.publish 'messages', text
      text
    end
  end

  resources :messages do
    get do
      after_open do
        # subscribe after_open b/c this runs until the connection is closed
        redis.subscribe 'messages' do |on|
          on.message do |channel, msg|
            chunk msg
          end
        end
      end

      status 200
      header 'Content-Type', 'application/json'
      chunk *redis.lrange('messages', 0, 50)
      ""
    end

    post do
      status 201
      build_message(params[:text])
    end
  end
end
```

This example uses redis pubsub to push out messages that are created from `#post`. Thanks to [em-synchrony](http://www.igvita.com/2010/03/22/untangling-evented-code-with-ruby-fibers/), requests are not blocked when no messages are being sent. It's important do the redis subscribe after the connection has been opened. Otherwise, the initial response won't be sent.

### What about socket.io?

socket.io is great because it provides many transport fallbacks to give maximum compatibility with many different browsers, but its pubsub interface is too low level for capturing common app semantics. The application developer doesn't have nice REST features like HTTP verbs, resource URIs, parameter and response encoding, and request headers.

The goal of rack-stream is to provide clean REST-like semantics when you're developing, but allow you to swap out different transport protocols. Currently, it supports normal HTTP, WebSockets, and EventSource. But the goal is to support more protocols over time and allow custom protocols. This architecture allows socket.io to become another protocol handler that can be plugged into rack-stream. If you wanted to use Pusher as a protocol, that could also be written as a handler for rack-stream.

### Summary

rack-stream aims to be a thin abstraction that lets Ruby developers write streaming APIs with their preferred frameworks. I plan to broaden support and test against common use cases and popular frameworks like Sinatra and Rails. If you have any questions or comments, feel free to [submit an issue](https://github.com/intridea/rack-stream/issues) or leave a comment below!

