# Managing Rails client side navigation state

tl;dr: Over thought it. Session made it obvious and simple

```ruby
class HoldingsController < ApplicationController
  def index
    session[:period] = params[:period]
  end
end

# in the navigation partial
<%= link_to "Holdings", holdings_path(period: session[:period]) %>
```

In my app, url path params maintains navigation state. For example, to see investment performance of holdings, there are links that look like:

```
/holdings              # 1 day performance by default
/holdings?period=ytd   # year to date performance
/holdings?period=all   # all time performance
```

This is straightforward within the Holdings#index action, but the global navigation always points to /holdings so if I navigate to another page and click on the "Holdings", it'll default back to 1 day performance instead of remembering that the user has previously selected YTD or ALL.

What's have others done to keep this state globally? What makes the most sense from a UX perspective?

## Persist in the database

Attach this as a property of current user, persist / restore across requests. This feels right to me if the state is important across different instances of the app. If I choose YTD performance on my phone, then open the app on the web, I would expect my previous choice to stick. In this sense, it feels like a global user preference that's saved across all clients.

## Persist in a session

This seems like a better abstraction than attaching it to user. If using cookie stores, users would go back to the default per client. If using database store, it'd be all clients.

## Persist in localStorage

Do it all client side. Per client. Persist and restore from stimulus. I like this one the least because it feels complex without additional benefit.

https://jch.app/demo is a live demo.
