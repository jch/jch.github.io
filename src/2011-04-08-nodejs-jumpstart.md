# Node.js Jumpstart

In a nutshell, Node is a Javascript framework for building network
apps.  Network apps are broader in scope than webapps. They don't need
to run on HTTP, thus freeing you to write lower level tools. Node
doesn’t necessarily have to be part of your core app, and in many
cases, it makes for a good fit for writing some of the support
functions for your webapp. I'll cover the basics of getting Node
setup, some event driven programming, and some miscellaneous Node
goodies.

To get started, you can grab the latest Node release from
[Github](https://github.com/joyent/node.git). They have [good
installation
instructions](https://github.com/joyent/node/wiki/Installation), but
for the truly uninitiated Mac users, you can install it via
[homebrew](https://github.com/mxcl/homebrew):

    brew install node

Once you have Node, you can try it out with an interactive session
much like irb. Run node with no arguments:

    node
    > console.log('hello world')
    hello world

Node's biggest core idea is evented I/O. Instead of blocking and
waiting for I/O to finish, Node will start I/O, and execute a callback
when data is actually ready. On top of reading and writing requests
and responses, we spend a lot of time doing I/O when we fetch data
from a datastore, or make external requests to other APIs. With Node,
we save that wasted blocking time to do actual useful work.

Let's compare a really simple file I/O operation to compare Ruby to
Node.  Here's a simple Ruby script that will read a file 3 times and
print when it finishes, and also print "doing something important".

    (1..3).each do |i|
      contents = File.read('foo.txt')
      puts "#{i}. Finished reading file"
      puts "#{i}. doing something important..."
    end

We also print out the loop counter to see the order the statements
were run.  The output is unsurprising:

    1. Finished reading file
    1. doing something important...
    2. Finished reading file
    2. doing something important...
    3. Finished reading file
    3. doing something important...

Now let's look at the Node equivalent of the same script:

    var fs = require('fs');
    for (var i=1; i<=3; i++) {
      fs.readFile('presentation.key', function(err, data) {
        console.log(i + ". Finished reading file");
      });
      console.log(i + ". doing something important...");
    }

What's interesting in this code is the callback we use with the
readFile method. By having a callback on this I/O action, readFile
will immediately return when called, which allows "doing something
important" to be run before the I/O actually completes. When the file
is finished reading, then we invoke the callback.  Here's the output
for the Node script:

    1. doing something important...
    2. doing something important...
    3. doing something important...
    4. Finished reading file
    4. Finished reading file
    4. Finished reading file

Were you surprised by the loop counter 4 in the results? This is one
of those subtle "gotcha's" that takes time to get used to. Because the
callback is invoked long after the loop is finished, the loop counter
variable 'i' has been incremented to 4.

The community for Node is growing, and there is already a [large
number of non-blocking
libraries](https://github.com/joyent/node/wiki/modules) that are Node
friendly. Many of these can be used to build diagnostic and metrics
tools for supporting your site. If your site has a need for push
notifications or uses AJAX to poll for updates, you can also use Node
to handle those features on your site. A few fun examples of apps
built with Node include [StatsD](https://github.com/etsy/statsd),
[Hummingbird Analytics](http://projects.nuttnet.net/hummingbird/), and
[Node Wargames](https://github.com/mape/node-wargames).

That covers a brief introduction to Node.  I leave you with a quote
from the creator of Node that I'm a fan of.  He says:

<div class="quote_box" style="background: #edf4f7 url(http://img.skitch.com/20100511-pkj1ytnfcdk5qtpi1bh9w8q5a1.png) no-repeat 10px 10px;padding: 17px 18px 14px 81px;margin-bottom: 18px;-moz-border-radius: 12px;-webkit-border-radius: 12px;">

<p>Node jails you into this evented-style programming. You can't do things in
a blocking way, you can’t write slow programs. </p>

<p style="font-size: 12px;line-height: 17px;margin-bottom: 10px;"> <strong style="display:block;font-weight: bold;color: #da1c49; font-family: 'Museo Sans', Arial, 'Lucida Grande'; margin-bottom: 5px;">--Ryan Dahl</strong>

</div>

