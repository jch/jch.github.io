# Flaco Blog #

A while back I was chatting to Arthur and bitching about all the
various blog systems.  To date, I've tried a wide cross section of
them and found them all to be inadequate.  Arthur's proposed solution
was to write his own.  I shied away from that notion until a few days
ago.  Then I finally caved and started thinking about doing my own.

## Requirements ##

It's only in the past year or so that I've viewed blogging as a public
activity.  Previously, I used it more as a personal journal even if
others peeked in.  My first exposure was the trashy, but extremely
functional Xanga.  I didn't care very much about web standards or
design early in high school, so Xanga was quite good to me.  It was
free, customizable, and all my friends used it.  My relationship with
Xanga went sour when I tried to screen-scrape all my posts with
WWW::Mechanize.  It worked ok, but it made me realize how shitty the
HTML was and that there could be better.

* control and manipulation of my own data.

Sometime after that I had a brief stint with LiveJournal.  I lacked
motivation to keep it up, but I liked the external clients, and open
source nature of LJ.

* external clients / API
* clean look

I really dislike writing markup, and I also despise looking at
markup.  Neither was avoidable with other systems.  Writing markup by
hand was tedious and often resulted in erroroneous markup.  Once
you've written the markup, it's nice to know that the data is
transformable with XSLT.

* simplicity
* web standards
* easily transform data

Writing a blog with just plain text and not blog management system is
also a lost cause.  Once you get over a certain number of posts, it's
hard to manage the permalinks by hand.  There's also lots of
duplicated HTML that would best be abstracted into templates.  On top
of that, it's important to have a way for users to give feedback about
your articles.

* comments system
* templating system
* automation of publishing tasks
* "Don't Repeat Yourself" design

## Design ##

With these points in mind, I looked to create my ideal blog management
system.  Plain text will be used to manage storage for maximum
future-proofing, and minimal software requirements.  The
implementation language of choice is a hybrid of Perl, Bash, and
anything that fits in the future.  For the sake of simplicity and at
the expense of customization, I've opted for enforcing a hardcoded
directory hierarchy:

    articles/
      YYYY/
        MM/
          DD/
            title/
              index.draft
              index.text
              index.html
              images
              stylesheets
              .config/
                override default options
              .meta/
                tags, word count, etc

This keeps each individual article self-contained.  Rather than model
a data structure for what an article is, I've made the structure
implicit in the way the data is stored.  This idea separates the
system from the data so that the data makes sense standalone.  You
could argue that I duplicate this into a schema for some database, but
why would I need one?

The .text and .html is carried over from my earlier text-based blog
system.  The best web word processor is Markdown.  It lets you write
in any editor you want and has syntax rules that become natural almost
instantly.  This freed my eyes from staring at markup and also gave me
very clean XHTML and other formats as needed.  The editor and external
client was solved free of charge by Emacs and ssh.  Intermdiate
articles can be saved with a .draft extension.

As far as comments go, I plan to write it as a separate system with an
public API.  There's no reason to make a blog-specific comment system
when I can create one that can be used anywhere.  This also removes a
huge chunk of complexity involved with fighting spam that I really
don't feel belongs in a blog system.  This guy will come later.

## Templating ##

As I'm writing this, one annoying piece of the system has cropped up:
the templating system.  This puts me in a sticky spot because using an
existing templating system would introduce more bloat than I'd like,
but writing my own simplistic templating system sounds tricky.  At the
moment, all I need is a declarative way of piecing together snippets
of HTML.  My favorite option so far is to match the path of a file to
be published against a set of rules to determine which template to
use.  The actual template will be a simple perl script that takes the
content to be embedded as input and spit out a laid out version.  The
downside of this is the assumption that there will be only be one
snippet to be inserted within a template.  This is limiting, but can
be fixed by adding options so that the layout script knows what is
given.  For example:

    perl article.layout --content=articles/2008/01/29/foo/index.html
                        --header=includes/head.html
                        --footer=includes/foot.html

it'd be nice to have a generator script to scaffold a generic
template:

    script/generate layout article [header,content,footer]

**Update**: I've been working with
[TemplateToolkit](http://template-toolkit.org/) for work, and I've
found it to be very easy to use, but not bloaty.

## Headlines and Blurbs ##

This one's a bit of a bummer because none all the solutions I come up
with are tradeoffs.  The slowest and most accurate solution is
to have the author of articles fully specify the headline and blurb.
There could be separate markup at the top of a file, or put into
separate files.  Basically, this involves adding more structure to the
writing and more logic to handle this structure.  This idea doesn't
mix well with my goal of uber-simplicity.

Instead I opted for an approach that sacrifices some generality.  I
notice that all articles that I like usually involve an engaging headline
followed by an abstract.  So I figure it's fair for me to look through
either the source .text or markdowned .html for an h1 headline, and
the first paragraph.  The exit strategy is straightforward because
it's a simple map of a function over a list or articles.  No biggie.

## Dynamic Content ##

Since I've chosen such an extreme of simplicity and speed, it will be
very challenging to have dynamic content.  Once a set of articles has
been published, they are simple static pages.  This makes tasks such
as pagination, grouping articles by tags, and search non-trivial.  I
see two solutions to this problem.  One way is to mimic Blogger by
generating the dynamic content and flattening those into static pages.
Another is to build a separate service to generate the content and
reference the service from the static pages.  Reference can be done
with AJAX or server side includes.  I prefer the server side includes
because it does not assume the client to have javascript, but don't
like the idea of turning on SSI's because each page load would require
Apache to scan for SSI directives.

Pre-generating and Flattening out dyanmic content will only get me so
far.  Hopefully it'll be far enough :)

## Performance ##

Performance-wise, I want this system to be fast.  How fast?  Here are
my design goals:

<table>
  <tr>
    <th>Operation</th><th>Running Time</th><th>Storage</th>
  </tr>
  <tr>
    <td>View an article</td>
    <td>O(1) - as fast as it takes to serve a static page</td>
    <td>O(2n + m) - where n is the number of words in an article.
    Each article will be kept in both Markdown and XHTML format.  The
    extra m factor stands for the extra templating markup, but is pretty
    insignificant.  I'm trading off a bit of storage for best-case
    speed.</td>
  </tr>
  <tr>
    <td>Write an article</td>
    <td>O(1) - Emacs ftw!</td>
    <td>N/A</td>
  </tr>
  <tr>
    <td>Publish articles</td>
    <td>O(n) - where n is the number of articles to publish.  The
    script uses 'GNU find' and command line options to only publish
    and generate needed content</td>
    <td>Some meta information about the articles are created, so a bit
    of extra space is needed.  Again, pretty insignificant.
    </td>
  </tr>
</table>

For now, I have no ambition of making this system scale, but I'm smug
with the knowledge that it will scale.  ZFS immediately comes to mind.
I can imagine publishing as a bottleneck, but clever uses of 'find',
'locate' and meta information can minimize these operations.  Another
storage consideration is how wasteful it would be to duplicate common
HTML snippets across articles.  Headers, footers, and sidebars are
good examples of this.  My take on this issue is: Care when it
matters.  My own personal use case is to have meaty articles with
minimal fluff snippets.  For me, the benefits of having blazing fast
page views outweighs the negative of wasted storage.  I call it "Lazy
Pre-Evaluated Caching", or LPEC for short.  On the other hand, I can
see how saving space can lead to more articles being stored in memory.
My exit strategy, should it ever be needed, is to LPEC the most
popular pages, and leave rarely viewed pages in un-markdown'ed source
.texts.

For maintenance, I want it all.  I don't want the code to be obsolete,
and I definitely don't want my data to suffer bitrot.  By using a
hybrid of languages and frameworks, I get the best of each and
guarantee easy replace of any subsystem if a better solution arises.

**Update**:  That last bit was too vague for my tastes.  Most of the
system will be written in Perl so I can beef up some of my Perl-fu.  I
doubt anything will feel slow, but I might use
[XS](http://perldoc.perl.org/perlxs.html) just to play with it.

Common tasks can be described with Rake and to automate these tasks,
I'll periodically run them from cron.  Here's what I have in mind for
a basic publish_all task

    # month  hour  day-of-month month day-of-week   command
    0    4    *    *    *    ~/portfolio/publish_all

**Update**: There will be options in the 'publish' command that allows
users to filter what they want to publish.

## Data Models ##

I plan to use the file hierarchy and file names as an encoding of the
data.  However, from a programatic perspective, it makes more sense to
have an API to manipulate this data.  This also makes it easy to
transform the data into any other storage backend as needed.

### Article ###

An article is a source un-markdowned entry.  It keeps state for
everything that describes an article and is implemented as a
self-contained folder.

#### State ####
* title
* blurb
* year, month, day
* path - the root directory of the self-contained article.

#### Methods #####
* <=> - date compare to another article
* to_html
* to_xml
* to_* - meta-method for arbitrary formats?  This is probably overkill.

### Template ###

Object used to transform and layout objects.  Each template type
expects arguments of the things they need in order to lay out
themselves.  For example, an ArticleHTMLTemplate may require
'stylesheets', and 'articles', whereas an ArticleXMLTemplate may only
require 'articles'.

### Logic + Glue ###

I didn't want to call it controllers, but I'm thinking of it in a MVC
kind of way.

## Notes ##

I'm keeping some bullets here for updating later.

* thinking about the different use cases definitely revealed a pattern
  for processing articles.  A key observation I noticed is that there
  are two types of operations: taking an article as input, doing
  something, and spitting out a result.  The other is to take a _list_
  of articles as input, do something, and spit out a single result.

* using [Moose]() as the object system to represent an article.
  **Update** - I've decided against this because it's too fancy.

* markdown has an annoying feature that it will wrap multi-line 'li'
  content in a 'p' tag.  I fixed this by styling 'li p' to be inline.
  This is still valid xhtml and still makes markup sense.

* rebuilding the pages that are indicies for lists of articles
  requires rebuilding all of the indicies.  This does scale, so I've
  been toying with the idea of keeping a B-tree of published
  entries.  There needs to be meta files to keep track of how many
  entries are in what pages.  When a page gets too full, it gets split
  into two separate pages; When a page gets too empty, it gets joined
  with it's neighbor.  When publishing, it means that only specific
  pages are being rebuilt, rather than all index pages.

## Status ##

* 2008-05-03: pagination! atom feed!
