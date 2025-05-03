# Ruby HTTP Streaming Revisited

This morning I read "You might not need Websockets". It reminded me of
the rack-stream gem I wrote 13 years ago to explore the HTTP Streaming API.

Here are changes since I last looked at this topic:

- Rail's ActionCable abstracts websocket connection management
- Turbo streaming can work through websockets or eventsource
- ActionController::Streaming can stream layouts earlier with some caveats around middlewares and layouts
- falcon is a newer async ruby web server

## Links

- rack-stream: https://github.com/jch/rack-stream/
- HTTP Streaming: https://developer.mozilla.org/en-US/docs/Web/API/Streams_API
- You might not need Websockets: https://hntrl.io/posts/you-dont-need-websockets/
- ActionCable: https://guides.rubyonrails.org/action_cable_overview.html
- Turbo Streams: https://turbo.hotwired.dev/handbook/streams
- ActionController::Streaming: https://api.rubyonrails.org/classes/ActionController/Streaming.html
- falcon: https://github.com/socketry/falcon
