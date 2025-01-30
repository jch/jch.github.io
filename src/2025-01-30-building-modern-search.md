# Building an accessible search page with progressive enhancements

This article documents what I learned building a search page for stocks, ETFs, and other securities for https://jch.app. I start with built-in HTML elements and attributes for accessibility, add CSS for layout and visual design, and progressively enhance the user experience with Turbo, and one line of javascript. At the end, I'll talk about some experiments that led to dead ends and share interesting links and references.

## HTML and CSS

Here's the basic form.

```html
<!-- GET /securities -->
<search>
  <form action="/securities">
    <input type="search" name="q" placeholder="Search" autocomplete=off spellcheck=false />
    <button>Search</button>
  </form>
</search>
```

If a user wants to see the price of VTI (Vanguard Total Market Index Fund), they would enter 'VTI' and hit enter, or click 'Search'. A few observations:

1. The default `method` for a `form` is `GET`, so submitting this form takes the browser to `/securities?q=VTI`
1. `button` is associated with the form and submits by default
1. `<search>` hints for screen readers, and/or add a `role=search` on the form
1. `spellcheck=false` turns off the angry squiggles in Edge because VTI isn't a word


On the backend, I take the `q` parameter, do a database lookup, and render the same template with the search results below. Each search result will have a name, full name, current price, and percentage change today.

The plan was to layout each search result like:

```
+-------------------------------------+
| VTI                         $301.30 |
| Vanguard Total Market I...   -0.30% |
+-------------------------------------+
```

This layout can be made with flexbox or grid. I experimented with both and found flexbox to be easier to read.

The entire page has a maximum width for readability to keep the name and price close enough. I've focused on a mobile layout, but this could turn into an `<aside>` sidebar in the future. One highlight is to change grid/flex item's default `min-width` to stay inside the container and allow `text-overflow` to work.

```html
<style>
  main {
    max-width: 350px; /* for readability */
    margin-inline: auto; /* centers the container on wider viewports */
  }
</style>
<main>
  <form>...</form>

  <!-- full width so results with short names stretch -->
  <div id="search-result-list" class="w-full">
    <!-- flexbox or grid here -->
    <div class="search-result">
      ...
      <style>
        .fullname {
          whitespace: nowrap; /* so search results have a consistent height */
          min-width: auto; /* or zero b/c the default for flex/grid items is `fit-content` */
          overflow: hidden; /* prevent long names from colliding into the prices */
          text-overflow: ellipsis; /* add the `...` */
        }
      </style>
      <p class="fullname">Vanguard Total Market Index Fund</p>
      ...
    </div>
  </div>
</main>
```

Once I had search results, the next piece was 'watching' or 'unwatching' a stock. Each watched stock would have a check next to it, and clicking on that would toggle whether it was watched.

```
+-----+-------------------------------------+
+ [x] | VTI                         $301.30 |
+     | Vanguard Total Market I...   -0.30% |
+-----+-------------------------------------+
```

My first idea was to build this as a checkbox and enhance it with javascript to submit on click. However, I realized it makes sense to watch one stock at a time. The default behavior for a `<button>` within a form is to submit the form, skipping the need for javascript.

```html
<div class="search-result">
  <form action="/securities" method="post">
    <button aria-label="Watch VTI">&plus;</button>
  </form>
  <!-- security details -->
</div>
```

Testing it in a screen reader, I liked having the name of the action with the name of the security announced. I played around with having the button on the left vs right, and found it more aesthetic and intuitive on the left close to the name. It felt like you're "watching VTI". The tab order also felt natural, allowing user to navigate each result and it's details. I could use `flex-direction` to flip the order and make a left-handed or right-handed setting. With my iPhone 13 mini, it's a natural reach for the button, but something to consider for different devices.

Visually, I used html entities for `&plus;` and `&check;` to represent whether something is watched. I've recently enjoyed using html entities, and emoji as icons rather than svgs or images. There are differences across platforms, but they present a familiar representation specific to the platform. So a check mark looks different in Safari vs Chrome, and different still on Edge on Windows. But each of those will look familiar to users on that platform. It's also easier to maintain because what's rendered matches what's in code.

Speaking of icons, I added a magnifying glass emoji to the left of the search input. It's less customizable than an svg icon, but I found it visually pleasing. I reduced the opacity so it wasn't shouting for attention. I started with a small shadow on the search input to give it a raised look, but once I added the magnifying glass, I went for a minimal single bottom border.

## Progressive enhancement

At this point, the search form works. It doesn't need javascript. It uses vanilla HTML elements and attributes that works across browsers. The markup has aria attributes to add semantics for assistive technologies, and doesn't mess with the logical ordering of elements.

To enhance the user experience, I use Turbo to add:

1. Search as you type
1. Morphing elements for smoothness
1. Subtle animations
1. Live preview of stock prices

To implement search as you type, I submit the search form when the input changes `oninput="this.form.requestSubmit()"`.  This is the one line of javascript that I wrote. I considered debouncing the events to avoid too many requests to the backend, but found it unnecessary once I limited each search to ~10 results. Between search as you type, and the search icon, I removed the 'Search' button to reduce clutter further.

There is a distinction between `form.submit` and `form.requestSubmit`. The latter works as if a user clicked submit, which is necessary for Turbo.

Each search input change adds to the browser history. So a search for 'VTI' adds:

1. /securities?q=V
1. /securities?q=VT
1. /securities?q=VTI

Adding `data-turbo-action="replace"` on the form configures it `replace` the entry in the browser history rather than the default `advance` that adds a new entry on the stack.

Turbo's default behavior on forms and links adds subtle animations between page transitions. Since the search form renders the same page when it's submitted, I enable morphing:

```html
<head>
  <meta name="turbo-refresh-method" content="morph">
</head>
```

With search results limited to 15, there weren't enough elements to make a noticeable difference even when I typed or cleared the input quickly. One side effect is that the search input is not replaced between different pages. However, I left a `data-turbo-permanent` attribute on the input because it documents that the element should be kept between turbo visits, and won't regress if I change the refresh method back to the default. This was also necessary for `autofocus` to not reset the cursor position.

There's additional opportunity to use view transitions to fine tune the search results instead of the default cross fade, but again, it didn't seem worth the effort with a capped number of results.

Here's the final search as you type form without styles for readability. Note the input value comes from the backend, but can also be populated with javascript from `window.location.search`. Though the latter would make it tricky to maintain cursor position.

```html
<form id="search-form" action="/securities" data-turbo-action="replace" data-turbo-permanent>
  <input name="q" type="search" value="<%= params[:q] %>" class="border-0 ring-0 py-2 pl-8 w-full" placeholder="Search" oninput="this.form.requestSubmit()" autofocus autocomplete="off" spellcheck="false" />
</form>
```

When search finds a result, it's nice to preview the current price and today's change percent. My backend tracks this information, and I push new price information via Turbo Streams. This can be done without Rails as the backend, but Rail's ActiveRecord, ActiveJob, and ActionCable integrates with Turbo Streams to provide a nice interface.

```html
<!-- rails helper turbo_stream_from generates subscription -->
<!-- <%= turbo_stream_from "security_1" %> -->
<turbo-cable-stream-source channel="Turbo::StreamsChannel" signed-stream-name="somelongsignedstreamname"></turbo-cable-stream-source>
```

Turbo Streams documentation says it's implemented with websockets with a fallback to server-sent events (SSE), but I have not tested this. It's out of scope for this article, but here's a taste of what my backend looks like:

```ruby
class Security < ApplicationRecord
  # this renders securities/_security.html.erb to the "security_1" channel above
  # and replaces search results by unique id selectors that describe each security
  after_update_commit { broadcast_replace_later_to self }
end
```

At first I had a stream for `securities`. While this doesn't leak any user specific information, it causes unrelated updates from other searches to be pushed on the same stream. I was worried creating 10 streams on a page would create 10 separate connections to the backend, but it multiplexes the different stream names on a single websocket connection.

## What didn't work

Once I had a working version, I tested on different devices and screen readers to add the tweaks and enhancements I talked about so far. But there were two dead ends, `display: contents` and styling `table`'s, where I learned a lot about accessability.

Safari's web inspector has a menu to disable images, css, and javascript. I toggled these while building to understand what the default user agent experience looked like. Since I'm targeting modern browsers, it's safe to assume CSS and JS are enabled, but it's satisfying to know the page works without them. While I was building the form to watch/unwatch stocks, I thought `<fieldset>` and `<legend>` would be a good descriptive pair of tags to use. Since legend must be a direct child of fieldset, I wanted to use flexbox to position the legend, and `display: contents` to ignore the fieldset and treat it's children as flex items of it's parent.

```html
<form action="/securities" method="post" style="display: flex">
  <fieldset style="display: contents">
    <legend>VTI</legend><!-- valid -->
    <div class="search-result">
      <legend>VTI</legend><!-- invalid, legend must be direct child of fieldset -->
      <button aria-label="Watch VTI">+</button>
      ...
    </div>
  </fieldset>
</form>
```

MDN warns that browsers incorrectly remove `display: content` element from the accessability tree. I also realized there's no semantic value to have a fieldset/legend. The only form action is the button, which has an obvious aria-label. The fieldset isn't being used to group a set of related inputs, and the legend is redundant because it's rendered by a shared template again below the button.

I learned:

1. The default user agent styling for fieldset/legend looks good, and allows for interesting transforms and animations.
1. Avoid `display: content` for now

Next, I considered marking up the search results as tabular data.

```html
<table>
  <legend>Search results</legend>
  <tr>
    <th>Watch</th>
    <th>Name</th>
    <th>Full name</th>
    <th>Price</th>
    <th>Percent change</th>
  </tr>
  <tr style="display: flex">
    <td><form>...</form></td>
    <td>VTI</td>
    <td>Vanguard Total Market Index</td>
    <td>$301.30</td>
    <td>-0.30%</td>
</table>
```

Unfortunately, this made it difficult to share a template with other pages because "Watch" is a state that's tied to a specific user, while price information is not. With a `<div>` search result, the template can be shared and the user-specific state can be added, but the same could not be done with a `<tr>` as the shared template:

```html
<!-- shared.html: shared template for a security -->
<div id="VTI">
  <p>VTI</p>
  <p>Vanguard Total Market</p>
  <p>$301.30</p>
  <p>-0.30%</p>
</div>

<!-- add user specific state and reuse shared template -->
<div class="search-result" style="display: flex">
  <form>(Watch / Unwatch)</form>
  <%= render "shared" %>
</div>
```

Changing the `display` on a table removes it's table semantics from screen readers. I didn't change the table's display, only the `<tr>` to layout individual search results. Nevertheless, I was forcing a table for accessability, then styling it to not be a table.

## Conclusion and links

Play with it at https://jch.app/demo. I encourage you to try turning off javascript and CSS. Try it in a screen reader.

Plain built-in HTML has the flexibility to create useful pages that are accessible by default. Though javascript is widely available, it is not a requirement for building a beautiful and useful page.

A sparing use of javascript can progressively enhance the user experience without increasing complexity and maintenance. The only js I wrote was `this.form.requestSubmit()`, while the rest were html data attributes to customize Turbo's default behavior.

While my backend is Rails, which has helpers to integrate with Turbo, the concepts and code can be done with any backend. I've even used Turbo on static HTML pages to smooth the transitions between links.

### HTML
- MDN HTML elements reference: https://developer.mozilla.org/en-US/docs/Web/HTML/Element
- <search>: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/search
- form#method: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/form#method
- button#type: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#type

### CSS
- display: contents: https://developer.mozilla.org/en-US/docs/Web/CSS/display-box
- Appendix B: Effects of display: contents on Unusual Elements: https://drafts.csswg.org/css-display/#unbox
- More Accessible Markup with Display Contents: https://hidde.blog/more-accessible-markup-with-display-contents/
- display: contents is not a CSS Reset: https://adrianroselli.com/2018/05/display-contents-is-not-a-css-reset.html
- Table CSS Display Properties and ARIA: https://adrianroselli.com/2018/02/tables-css-display-properties-and-aria.html
- table-layout: fixed: default is fit-content. This allows columns to shrink.

### Javascript
- form.requestSubmit: https://developer.mozilla.org/en-US/docs/Web/API/HTMLFormElement/requestSubmit
- Turbo: https://turbo.hotwired.dev/
- Turbo morphing: https://turbo.hotwired.dev/handbook/page_refreshes#morphing
- Turbo streams: https://turbo.hotwired.dev/handbook/streams

### Accessibility

- Enable fullpage accessibility tree: https://developer.mozilla.org/en-US/blog/aria-accessibility-html-landmark-roles/
- Mac Voice Over Cmd F5, Control Option U: https://support.apple.com/en-za/guide/voiceover/vo35709/mac

### Rails specific

- turbo-rails Turbo::Broadcastable: https://www.rubydoc.info/gems/turbo-rails/0.5.2/Turbo/Broadcastable
- https://github.com/hotwired/turbo/issues/1093: turbo-rails does debouncing on the backend
