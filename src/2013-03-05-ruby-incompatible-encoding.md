# Ruby Incompatible Encoding Errors

String encodings is like air. Completely necessary and never on your mind
until something goes wrong. Encoding bugs are painful and often feel like the
black arts. Follow the jump for an aggregation of past experiences for solving
these tricky problems.

## Background

The first time you think of encodings in Ruby is probably the first time you
see an exception along the lines of:

```
incompatible character encodings: ASCII-8BIT and UTF-8
```

Before you pull out your hair, I recommend reading [James Edward Grey
II's](http://blog.grayproductions.net/articles/understanding_m17n) in depth
coverage on why and what encodings are. Markus Prinz's [Working with Encodings
in Ruby 1.9](http://nuclearsquid.com/writings/ruby-1-9-encodings/) is also a
good read. Go ahead, this article will wait.

The core cause of the above error is when your code tries to mash two strings
with different encodings together. For example, trying to glue a UTF-8 Chinese
string to an ASCII-8BIT English string. They're hard to hunt down because the
error is generated in C code and doesn't descend from the Exception class.
This means you can't `rescue` the error to inspect it. Your best tool for
finding the origin of the error is to learn about the [Encoding](http://ruby-doc.org/core-2.0/Encoding.html)
module. Once you're familiar with that API, it's easy to inspect the encoding
to check it's what you expected.

```ruby
"some string".encoding
"some string".force_encoding('UTF-8')
```

### Rails

Rails defaults to UTF-8 for encoding. You can change it via application.rb
with:

```ruby
config.encoding = 'UTF-8'
```

Yehuda Katz has a [good write
up](http://yehudakatz.com/2010/05/05/ruby-1-9-encodings-a-primer-and-the-solution-for-rails/)
describing the problem. The long term solution is to have
libraries that deal with external strings to respect
`Encoding.default_internal`

### Databases

To make sure your database uses the correct encoding, set your connection
adapter to the correct encoding:

```
# config/database.yml
development:
  encoding: unicode
```

### Views

When template views are read in from the filesystem, it respects the global
ruby default for encoding. This can be overridden by a special shebang-like
declaration at the top of the file:

```ruby
# encoding: utf-8
```

Check out [ActionView::Template#encode!](http://api.rubyonrails.org/classes/ActionView/Template.html#method-i-encode-21)
for more details.

If you're seeing an incompatible encoding error in a view, it's possible that
it's caused by rendering a value from an external gem or string. Remember that
the `render` method returns a string. A quick way to inspect that your
partials are in the correct encoding is to save the result of a partial into a
variable and print it's encoding:

```ruby
<% output = render(:partial => 'some/partial') %>
<%= output.encoding %>
```

### Heroku

Don't [forget to set your environment
variable](http://stackoverflow.com/questions/7612912/set-utf-8-as-default-
string-encoding-in-heroku) to the correct default encoding.

```sh
$ heroku config:add LANG=en_US.UTF-8
```
