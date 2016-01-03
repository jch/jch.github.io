# Pry Productivity From Your Code

<img align="right" src="https://img.skitch.com/20120229-bb7gyjs7138q6yh47h2wea7cus.jpg" style="padding-left:12px; padding-bottom:12px">

You've heard of Pry right? It's a full-featured alternative to the classic IRB shell that we use in Ruby, and it's <strong>awesome sauce</strong>. If you've ever felt like you wanted a crowbar to pry open your code during runtime... well, Pry is your answer.

Pry is essentially a REPL (read–eval–print loop) tool that you can use to examine and debug your code. One of the best features is that local variables are available to Pry, saving you from recreating them as you normally would in an IRB session.

### Installing Pry

I like to install pry into the global gemset since it's a tool even when I'm outside of a Rails project

```
rvm use @global
gem install pry
```

### Replacing IRB with Pry

In your application initialization, add the following to replace IRB with pry by default. For example, Rails would add this code to config/initializers/pry.rb

```
begin
  require "pry"
  IRB = pry
rescue
  # do nothing if pry fails to load
end
```

### Replacing ruby-debug with Pry

Between different versions of Ruby, installing and requiring ruby-debug can lead to annoying problems. 1.8.7 uses ruby-debug, 1.9.2 requires ruby-debug19, and 1.9.3 [blows up](http://blog.wyeworks.com/2011/11/1/ruby-1-9-3-and-ruby-debug) when you try to use ruby-debug19. ruby-debug also depends on the linecache gem, which [sometimes requires extra work to use with rvm](http://beginrescueend.com/support/troubleshooting/) and sometimes fails in environments when the native extensions fail to build.

Instead, skip all that headache with Pry! Anywhere you would use a 'debugger' statement, just call:

```
binding.pry
```

'binding' is a reference to the current local context. Enter 'exit' when you're finished with debugging, and the code will resume executing

### Additional features

Pry has a ton of other productivity boosters built in. You can drop into a shell temporarily, browse docs without leaving your shell, edit and reload code, and send code snippets up to [gist](http://gist.github.com). For a full listing, check out [their README](http://rubydoc.info/github/pry/pry/master/file/README.markdown)

There's a ton of documentation for Pry and a growing community around it; if you're interested in jumping in be sure to start at their [Github page](http://pry.github.com/) for links to tutorials, screencasts, FAQs and a Wiki!

