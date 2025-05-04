# Sourdough

![](/projects/sourdough/nine.png)

During covid, I ran out of yeast. I tried to make my own sourdough starter from flour and water, but ended up with a hoochy moldy mess.

Fast forward a couple years, and my friend Sarah was kind enough to share her starter, idiot-proof care instructions, and a recipe. I named the starter Lemmy, because it was lemon-y fresh.

The first few loaves were edible, but definitely looked "homemade" in the bad way. I started writing down notes on temperature, ferment times, and other observations in a note on my phone. It gave me the warm fuzzies to see and taste each loaf after the string of initial failures. If you want a piece of Lemmy to try to bake your own bread, I'm happy to mail you some dehydrated starter to start your own.

## Journal

I made a webpage to [organize my recipe and notes](/projects/sourdough) offline. I took inspiration from a blog program named [Blosxom](https://en.wikipedia.org/wiki/Blosxom) that was written as a single perl script. I liked the idea of having everything self contained within a single file. My take was to create a single HTML file with styles and javascript inlined into the markup, requiring only a browser, but not requiring an internet connection. It currently sits at ~44kB, or around ~10kB gzipped. I load a couple of fonts, and some sample journal entries, but these are optional and the page works offline without them. Since it's a simple app, I wrote the CSS without tailwind, and the javascript without dependencies. I use IndexDB to store images and bake notes, and allow these to be exported and imported. On mobile devices, photos are taken with the input `capture` attribute.

I made a simple responsive grid layout and tested it across mobile, tablet, and desktop sizes. I spent some time [learning grid](/projects/grid.html), but I'm still not satisfied with how to layout a tall element in the same row track as shorter elements. I have the tall element span several row tracks because masonry layout isn't widely available, and I still want the bake photos to line up against row lines. Please write me if you know of a better way.
