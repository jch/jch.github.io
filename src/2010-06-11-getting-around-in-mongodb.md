# Getting Around in MongoDB #

<a href="http://mongodb.com"><img src="/images/mongodb.png" style="float:right;padding-top:10px;padding-left:20px"></a>
I started working with [MongoDB](http://www.mongodb.org) a few days
ago.  To oversimplify, think of Mongo as a really big and fast hash
that gets saved to disk. It lets you query, retrieve, and manipulate
data in Javascript and [JSON](http://en.wikipedia.org/wiki/JSON).  I
had a ton of work to do, so I didn't get a chance to explore the
technology as much as I would've liked.  Today, after getting a solid
night's sleep, I got a chance to experiment more.  Read on to get some
quick tips about writing Mongo queries and generating reports from the
Mongo shell.

When I first started interacting with Mongo, I used the Ruby
[Mongoid](http://mongoid.org/) adapter.  It gave me a familiar
ActiveRecord interface so I could accomplish things like:

    Beer.all(:conditions => { :style => "stout" })

But it also gave me a sneak peak at Mongo's 'criteria' API for querying

    Beer.criteria.where(:style => "stout")

It's worthwhile to note that criterias are lazily loaded, meaning
that the query isn't performed until you actually need to access the
data.

    Beer.criteria.where(:style => "stout")  # doesn't hit mongo
    Beer.criteria.where(:style => "stout").first.drink!  # executes actual query

This was all fine and dandy, but just like learning SQL and
ActiveRecord, having an understanding of the underlying system gives
you a better idea of what you can do.  So I busted out the [mongo
shell](http://www.mongodb.org/display/DOCS/Overview+-+The+MongoDB+Interactive+Shell)
and started running queries.  The
[tutorial](http://www.mongodb.org/display/DOCS/Tutorial#Tutorial) was
a good starting point for familiarizing myself with how to connect to
mongo, executing some queries, and printing out results.  My favorite
feature was that the mongo shell doubled as a Javascript interpreter.
I was able to write JS to manipulate the query results:

    function map(arr, func) {
      var collection = [];
      if(arr && arr.length) {
        for(var i = 0; i < arr.length; i++) {
          collection.push(func(arr[i]));
        }
      }
      return collection;
    }

    db.beers.find().forEach(function(beer) {
      print(beer.name);
      print('--------------');
      map(beer.ingredients, function(ingredient) {
        print(beer.ingredient.quantity + ' - ' + beer.ingredient.name);
      });
    });

I got pretty tired of copying and pasting this script every time I
edited it.  Thankfully, mongo shell lets you pass in script files to
execute:

    > mongo --help
    MongoDB shell version: 1.4.0
    usage: mongo [options] [db address] [file names (ending in .js)

This little feature enabled me to write more complex scripts and tweak
to my heart's content.  Something was still missing though.  I love
Javascript as a language, but nowadays, I've grown so accustomed to
jQuery that I'll start typing jQuery assuming it's available even when
it's not.

    db.beers.find().forEach(function(beer) {
      // CURSES! JQuery isn't available :(
      $(beer.ingredients).each(function() {
        // ... do something
      });
    })

My next genius idea: load jQuery as the first script:

    > mongo beerdb jquery-1.4.2.min.js reporting.js
    JS Error: ReferenceError: window is not defined jquery-1.4.2.min.js:153
    failed to load: jquery-1.4.2.min.js

Noooooo! It makes a lot of sense that jQuery would assume a browser
environment, but I was hoping that it wouldn't require it for the nice
utility functions.

To get the job done, I wrote myself a small utility library:

    $ = {
      // > $.map([1,2,3,4], function(x) { return x*x; }
      // [1,4,9,16]
      map: function(arr, func) {
        var collection = [];
        if(arr && arr.length) {
          for(var i=0; i<arr.length; i++) {
            collection.push(func(arr[i]));
          }
        }
        return collection;
      },

      // > $.max([1,2,3,4])
      // 4
      // > $.max([1,2,3,4], function(x) { return x*2; })
      // 8
      max: function(arr, func) {
        if(arr == undefined) { return arr; }
        var max = null;
        for(var i=0; i<arr.length; i++) {
          var current = (func ? func(arr[i]) : arr[i]);
          max = (current > max ? current : max);
        }
        return max;
      },
    }

This didn't buy me the full power of JQuery, but at the same time, I
was pretty happy I was able to quickly whip together some JS and get
the reports I needed.

Does anyone know of a JS library that buys you a lot of core library
features and fixes, but doesn't assume a browser?  I looked at [John
Resig's
Env.js](http://ejohn.org/blog/bringing-the-browser-to-the-server/),
but even that assumes that you're running JS in
[Rhino](http://www.mozilla.org/rhino/).  What other Mongo tricks do
people find useful?

## Reference ##

Here's the order I recommend reading the Mongo documentation.  The
Advanced Queries link was especially useful.

* [Mongo Tutorial](http://www.mongodb.org/display/DOCS/Tutorial#Tutorial)
* [Overview - The MongoDB Interactive Shell](http://www.mongodb.org/display/DOCS/Overview+-+The+MongoDB+Interactive+Shell)
* [dbshell Reference](http://www.mongodb.org/display/DOCS/dbshell+Reference)
* [Advanced Queries](http://www.mongodb.org/display/DOCS/Advanced+Queries)

*All databases are fictional. No beers were harmed in the making of this blog post.*
