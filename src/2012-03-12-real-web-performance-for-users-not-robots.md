# Real Web Performance for Users, not Robots

*Republished from [Opperator blog](http://blog.opperator.com)*

If I told you that a page took 130 requests to load 170 KB of data? Would you
call that a slow page?

![130 requests for 170 KB of data](/images/real-web-requests.png)

This is a trick question, and the numbers I gave are a double red herring. A
page is slow when it **feels** slow to a user. Without having opened up the
page for yourself in a browser, you can't have a real answer.

But if your gut reaction was "yeah, that's *damn* slow", I wouldn't blame ya.
It sounds like a ton of requests for the amount of data being transferred. To
disprove that the page is slow, here's a screenshot of the requests in Chrome:

![Chrome network inspector showing list of requests running in parallel](/images/real-web-chrome.png)

The page is question is the index page to my Facebook profile. Notice how
almost all of the requests are being sent in parallel, and most of them
finishing concurrently before the actual page skeleton has finished receiving
the data.

As web developers, we've internalized two guidelines:

* minimize the number of requests
* reduce the size of the response

By themselves, these are good guidelines for web throughput performance. Where
we go wrong is when these guidelines are applied without considering how the
user will perceive the page load. There are times where it makes sense to have
**more requests** rather than fewer in order to reduce page load times. What
we should prioritize is page **latency** rather than page **throughput**.
Facebook wrote a great [blog
post](http://www.facebook.com/note.php?note_id=389414033919) on this subject.
They decomposed a large monolithic page into a bunch of independent 'pagelets'
which can be generated, fetched, and rendered independently of one another.

With [Opperator](http://opperator.com), we recognize speed as a feature. And by designing our
architecture to be a set of loosely coupled services from day one, it was
natural and easy to make our pages feel fast. On top of the advice listed by
Facebook, here are some tips and notes about how we keep our pages speedy.

#### Serve What You Need

Don't serve a giant JSON object of all a resource with all of it's
associations. Instead, serve only what you need, when you need it. For
example, in our models, a Project has many Services. But when you make a
request for a Project, the JSON response only includes a list of Service id's
rather than the full JSON for the Project. Of course, sometimes it makes sense
to pre-fetch associated objects, but this shouldn't be the default case.

#### Serve and Render Visible Things First

As users, we don't feel page throughput, we feel page latency. It's ok for
your page to take slightly longer time to load, as long as everything the user
cares about can be seen as quickly and as smoothly as possible. The priority
we choose to serve our content is:

**CSS** goes first to make sure the rendering of the page feels smooth and
natural. We don't want any flashes of unstyled elements.

**HTML page skeleton** is loaded next to give overall structure and flat
content to the site. Flat content anything that isn't session dependent or
javascript dependent. Having this structure static will also help your SEO
rankings because no dynamic content rendering needs to happen server side.
This topic deserves it's own separate blog post.

**Javascript** is compressed loaded with [require.js](http://requirejs.org/)
asynchronously with web modules. Javascript builds all the interactive
elements on the page.

**Images** are sprited and loaded as late as possible, with the exception of
anything that makes the page reflow and jerk.

#### Render Client-Side

Our business logic lives within a [Grape](http://github.com/intridea/grape)
API. The initial page load is a static HTML skeleton that is then bound to
Javascript event handlers which will populate the content from the API
backend. We use [Ember.js]() (aka Sproutcore 2.0) to control and render all
the frontend interaction.

#### Skip Duplicate Work

Set your [HTTP cache headers](http://tomayko.com/writings/things-caches-do)
properly. If nothing has changed, then your backend doesn't have to regenerate
a full response. Better yet, if something can safely be cached for longer,
then your backend might not be hit at all.

#### CDN Your Static Assets

Think of a CDN as a proxy layer in front of your app. By offloading your
static assets into the CDN, your app no longer has to worry about serving
those static assets. Not only is it less work and bandwidth on your backend,
it's also faster for your users since the CDN's edge servers will be
physically closer to your users. Two low-cost CDN providers worth checking out
are:

**[Cloudflare](https://www.cloudflare.com/)** is a relative newcomer to the
arena. They range from **free** to $20/mo for your first site. That's hard to
beat.

If you store your static assets in S3, then **[Amazon
Cloudfront](http://aws.amazon.com/cloudfront/)** is worth a look. It allows
you to configure serving S3 assets through their CDN. Pricing is based on
usage.

#### Defining "Fast Enough"

Our website is actually deployed to a different server than our API.
Technically, we could get a performance boost if they lived on the same box to
cut down on network latency. But we decided to tradeoff network latency for
clean separation of systems. There's always room down the line for further
optimization, so "fast enough" for today is good enough for us.

**What speed optimizations do you use on your site? Sound off in the comments**

