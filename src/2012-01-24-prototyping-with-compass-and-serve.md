# Prototyping with Compass and Serve

For prototyping a new webapp, I like to get an HTML prototype on screen as
fast as possible. There are a number of ways to achieve this, ranging from the
heavyweight Rails, to the lightweight Sinatra. But even a barebones Sinatra
app requires you to specify routes and layouts. When I'm focused on sketching
out the markup structure and design, what I'm looking for is less distractions
from setup. Theoretically, one could prototype everything with raw static
HTML, but most designs usually share layouts and snippets that would be a pain
to copy and paste between different files. Writing raw CSS is also possible,
but once you've gotten a taste of Sass and Compass extensions, why would you
want to? In this post I'll outline my bottoms up approach to getting a site
design bootstrapped. I'll also cover how to get these prototypes up in a
public area for feedback, and how these prototypes can be used as scaffolding
alongside your development.

## **TL;DR**

This tutorial builds up an HTML prototype from the bottom up to show how
prototyping problems can be solved with compass and serve. To build an HTML
prototype, you can skip all of the details and just run:

```
serve create my-project
```

Check out the [serve documentation](http://get-serve.com/documentation/create)
for more detail. To arrive at the same conclusion step-by-step, read the long
version below.

## Overview

We'll walk through the individual steps of building out a web prototype. We'll
start with the bare minimum and add pieces as needed. The example design I'm
using is the design for my car blog, and the final source can be [found here
on github](https://github.com/jch/rock_road).

## Build a single static page

The beauty of static pages is how quick it is to set one up. We'll worry about
the other pages after we've happy with how the index page looks. For starters,
let's create a basic page skeleton.

```html
<html>
  <head></head>
  <body>
    <div id='header'>
      <a href='#'>Rocky Road Blog</a>
    </div>
    <div id='main'>
      <div id='post-list'>
        <div class='post'>
          <!-- blog post goes here -->
        </div>
      </div>
    </div>
    <div id='footer'>
      <p>Copyright 2011 RockyRoadBlog. All rights reserved</p>
    </div>
  </body>
</html>
```

To stub out image assets, I used [LoremPixel](http://lorempixel.com/). There's
no styling at all, but the structure gives us a good idea of where everything
will live.

## Add stylesheets

Instead of writing raw CSS, it's much easier to write stylesheets with sass.
Compass is another library that provides a bunch of useful sass mixins and
functions. When paired with guard-compass, the stylesheets are compiled to css
files whenever you save your sass files.

Add the following to a Gemfile

```ruby
source "http://rubygems.org"

gem "compass"
gem "guard"
gem "guard-compass"
```

Then run:

```ruby
bundle
bundle exec compass init --syntax=sass
bundle exec guard init
```

By default, `compass` uses the scss syntax, but I prefer the indentation based
sass syntax instead. Skip the `--syntax=sass` if you prefer the default. Edit
your Guardfile to look like the following:

````ruby
guard "compass" do
  watch(%r{sass/*\.sass})
end
````

Let's add our first sass file and check that our setup is working. Add a main.sass to your sass/ subdirectory with the following:

````
body
  background-color: red
````

Add a line to index.html in the head section to reference the compiled
stylesheet. Notice that we're referencing the compiled css file, not the
original sass source file.

````
<link rel='stylesheet' type='text/css' href='stylesheets/main.css'>
````

Now start guard with:

````
bundle exec guard
````

You should see your sass source files compile. Now whenever you make changes
to your sass files, guard will pick them up and recompile your sources.

## Reusable snippets

When designing, it's common to have a chunk of markup that needs to be reused
over and over. In our example, I'd like to see the design with multiple `post`
elements at once. I could duplicate the markup several times, but that's a
pain, and becomes even more painful when you have to change all of the
duplicated markup if you want to make a change. What we ideally want is to
have a separate file for the reusable snippets that we can include as many
times as we'd like.

Serve does exactly that (and more). First let's get it installed by adding it
to our Gemfile.

````
gem "serve"  # run "bundle" after editing
````

In serve, reusable snippets are called 'partials'. Partials live in a folder
called `views` by default. To make a new partial for each individual blog
post, we create a file named `_post.erb` with the html of a post:

````html
<!-- in views/_post.erb -->
<div class='post'>
  <!-- blog post goes here -->
</div>
````

Whenever we want to reference that partial, we can include it in our other
templates by calling render. For example, if we want to list 5 posts per index page, we can use a simple loop:

````html
<!-- in index.html -->
<html>
  <head></head>
  <body>
    <div id='header'>
      <a href='#'>Rocky Road Blog</a>
    </div>
    <div id='main'>
      <div id='post-list'>
        <!-- renders 5 post divs -->
        <%= 5.times.each do %>
          <%= render 'post' %>
        <% end %>
      </div>
    </div>
    <div id='footer'>
      <p>Copyright 2011 RockyRoadBlog. All rights reserved</p>
    </div>
  </body>
</html>
````

To see this in action, run `serve` in your terminal, and visit
`http://localhost:4000`. You should see the blog index page with 5 posts in
it.

## Layouts

Our blog index page is starting to come together. But our blog will have other
pages as well. There'll be an 'About' page and also a page to show a blog post
and it's comments. These pages will share a lot of the same markup (the
header, the footer, the page structure). Rather than pulling out partials for
each of these, we can create a layout. Think of a layout as an inside-out
partial. Instead of specifying which parts are the same, you specify which
part will change. To create our layout, add the following to `_layout.erb` in
the views directory.

````html
<!-- views/_layout.erb -->
<html>
  <head></head>
  <body>
    <div id='header'>
      <a href='#'>Rocky Road Blog</a>
    </div>
    <div id='main'>
      <%= yield %>
    </div>
    <div id='footer'>
      <p>Copyright 2011 RockyRoadBlog. All rights reserved</p>
    </div>
  </body>
</html>
````

Now we can change `index.html` to:

````html
<div id='post-list'>
  <%= 5.times.each do %>
    <%=  render 'post' %>
  <% end %>
</div>
````

If you try and view this in your browser, you'll notice that the loop didn't
render the partial and still looks like ruby code. This is because serve
determines what template language to run on a file based on it's file
extension. So to run ruby code in our index template, we need to rename it to
`index.html.erb`

To create our About page, we just need to put the html that's different in
`about.erb`

````html
<h1>About</h1>
<!-- about us here -->
````

Serve figures out the URL paths based on the filename, so you can view this
new file at <a target='_blank'
href='http://localhost:4000'>http://localhost:4000</a>

## Layouts and Nested Paths

Up til now, we've put our html files at the top level folder. This works until
you have multiple pages and multiple layouts. Just like how it figures out
URL's from filename, serve will also pickup nested folders as part of the URL.
For example, if I wanted to create `/about/jerry` page that uses a different
layout, I could create the following directory structure:

````
rrb
  _layout.erb
  show.html.erb     # show will use rrb/_layout.erb
  about
    _layout.erb
    jerry.html.erb  # jerry will use rrb/about/_layout.erb
````

## Publishing your prototype

Once everything looks good, we still need to get feedback from people who may
not have ruby setup. Serve has a nice export utility that will flatten your
all your pages into static html files. To export your prototype, run:

````
serve export
````

This will dump everything into an `html` directory that you can zip up and
share.

## Scaffolded development

serve is a great tool to use alongside ruby webapp development. Since it's a
rack app, you can mount it alongside your Rails or Sinatra application and
fill out the functionality as you go.

## Design driven prototyping

Prototyping out the flows and design of an application is a great way to
explore how an application will work. Paper and photoshop prototypes are
great, but actually being able to click through an HTML prototype can help the
design and user experience process. The serve library makes it easy to build
html prototypes by cutting down on the amount of setup work needed to be done.

