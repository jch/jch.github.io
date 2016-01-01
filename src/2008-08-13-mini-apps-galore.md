# Mini-apps Galore! #

I'm warming up to the idea of using small webapps that do _less_.
Instead of full blown behemoth applications that take a lot of time to
learn and configure, they're more in the spirit of Unix tools or perl
one-liners.  Here's three that I came across that show quite a bit of
promise.

## Hoptoad ##

<a href="/images/hoptoadapp.png">
   <img src="/images/hoptoadapp-thumb.png" alt="hoptoad main page with a listing of unresolved exceptions from my application" />
</a>

Think of Hoptoad as a beautiful and functional wrapper around
[exception
notifier](http://agilewebdevelopment.com/plugins/exception_notifier).
Only rather than installing exception notifier per application,
Hoptoad is a single stop for all your broken app needs.  Setup is as
simple as installing the Hoptoad plugin, adding 4 lines to your app,
and running a rake task.  After this, you can access your exceptions
in Hoptoad's simple web interface, or subscribe to the provided RSS
feeds.  Each exception gets a summary view, some environment context,
and a full backtrace.  If you wanted to munge on that exception data
some more, they include an
[API](http://whatcodecraves.hoptoadapp.com/pages/api) to access the
site.

## PingMyMap ##

<a href="/images/pingmymap.png">
  <img src="/images/pingmymap-thumb.png" alt="listing of what sites pingmymap sent my sitemap to" />
</a>

I came across PingMyMap when I was cleaning up my sitemap generator.
At the time I only used Google's [python sitemap
generator](https://www.google.com/webmasters/tools/docs/en/sitemap-generator.html).
I'm not hell-bent on SEO, but I figured it wouldn't hurt for people to
be able to find my site if it actually helps them.  PingMyMap doesn't
offer any tips or tools for optimizing your site.  For an app that
deals with [sitemaps](http://www.sitemaps.org/), it doesn't even offer
you a tool to generate a sitemap!  Instead all this mini app does is
take an existing sitemap and send it off to 5 search engines that it
knows about.  It provides an
[API](http://pingmymap.com/documentation/#api) for you to post the
actual sitemap, and then it'll tell you whether it was successful or
not in submitting your sitemap to those search engines.

## Disqus ##

<a href="/images/disqus.png">
  <img src="/images/disqus-thumb.png" alt="disqus showing list of comments for this blog article" />
</a>

To play with Disqus, simply post a comment to this blog article :).
Like the other two examples above, Disqus offloads the common tasks of
'comments' into a shared webapp.  You can manage comments you get from
multiples sites.  It also offers integration with existing popular
blog engines.  Unlike the others, Disqus also holds some of your data.
This eases management of that data, but at the cost of losing control
of your own data.  One of the main reasons I enjoyed using Blogger was
that it allowed me the option to store my own data on my own server.
One of the main reasons why I disliked Blogger was that functionality
wasn't always guaranteed.  Disqus shows promise because they also
*plan* on having APIs for accessing their app, but only time can show
if this one's a keeper.

For the record, I had the exact same idea for a webapp like Disqus for
a long time.  I even spent an evening a few days ago prototyping out a
super raw version.  My raw version let you do all kinds of crazy
stuff... including XSS attacks, off-site AJAX calls, and SQL injection
attacks :)

## Wrap up ##

Even though these 3 apps do very different things, they all share a
very similar *feel*.  They don't try to do everything, they're simple
to setup, and best of all, they're extendable and hackable through
their APIs.  It might not be the kind of extensibility that a
full-blown open source project provides, but with the shallow learning
curve, it's the *right* amount of extensibility to get stuff done.
