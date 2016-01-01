# Rails Webapp Engineering #

The day after I came back from Australia, I started my new job at
[Coupa Software](http://www.coupa.com).  I'm absolutely loving it at
the moment because of the awesome people and the amount of software
I'm learning.  Here's just a few that I've picked up in my first week
that I'd like to jot down.

## Skinny Controllers, Fat Models ##

Here's [one
article](http://weblog.jamisbuck.org/2006/10/18/skinny-controller-fat-model)
about it.  It really *really* helps out with testing.

## Association ##

[composed\_of](http://api.rubyonrails.org/classes/ActiveRecord/Aggregations/ClassMethods.html#M001262)

* cmd-k clears terminal window
* rake stats
* script/spec for an individual test

* [send_data, send_file](http://api.rubyonrails.org/classes/ActionController/Streaming.html)
* render_to_string - returns string, use with send_data

* [Enumerable:inject](http://www.ruby-doc.org/core/classes/Enumerable.html#M001147)
  - same as Scheme accumulator I used in 61A

* [PDF::SimpleTable](http://ruby-pdf.rubyforge.org/pdf-writer/doc/classes/PDF/SimpleTable.html)
  - really really easy to use reporter generator.

* request.xhr? - if request is ajax-y

## Getting All Tables ##

```ruby
ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
connection = ActiveRecord::Base.connection

options[:tables] ||= connection.tables.reject { |t| %w(schema_info
sessions).include?(t) }
```