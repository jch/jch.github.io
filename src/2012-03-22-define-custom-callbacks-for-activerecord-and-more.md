# Define Custom Callbacks for ActiveRecord and More

Rails ActiveRecord models have a lifecycle that developers are allowed to hook into. But while most of us know about `before_save` and `after_update`, there are a few lesser unknown callbacks that are good to know about before you reinvent them. In this post, I'll cover all of the available ActiveRecord lifecycle callbacks, and also show how you can define custom callbacks for normal ruby objects.

## Meet the Callbacks

The Rails guide for [ActiveRecord Validations and Callbacks](http://guides.rubyonrails.org/active_record_validations_callbacks.html) is a good starting point for an introduction of the available callbacks and what they do. Most developers will be familiar with the validation and persistence callbacks, so let's start with these

```ruby
:before_validation, :after_validation
:before_save, :after_save
:before_create, :after_create
:before_update, :after_update
:before_destroy, :after_destroy
```

The callbacks above are self explanatory and commonly used, but if you're unfamiliar with them, or need a refresher, check out [the Rails guide on the topic](http://guides.rubyonrails.org/active_record_validations_callbacks.html).

## Around Callbacks

For `save`, `create`, `update`, and `destroy`, Rails also gives extra helper methods for defining both a before and after save callback at the same time.

For example, suppose you wanted to trigger your own custom callback while a model was being destroyed. You can do so by defining and triggering your own callback as follows:

```ruby
class SomeModel < ActiveRecord::Base
  define_callbacks :custom_callback

  around_destroy :around_callback

  def around_callback
    run_callbacks :custom_callback do
      yield  # runs the actual destroy here
    end
  end
end
```

## Custom Callbacks without ActiveRecord

Most of the time, your Rails models will be using [ActiveModel](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/), but sometimes it makes sense to use a plain old ruby object. Wouldn't it be nice if we could define callbacks in the same way? Fortunately, the callback system is neatly abstracted into [ActiveSupport::Callbacks](http://api.rubyonrails.org/classes/ActiveSupport/Callbacks.html) so it's easy to mix into any ruby class.

```ruby
# Look Ma, I'm just a normal ruby class!
class Group
  include ActiveSupport::Callbacks
  define_callbacks :user_added

  def initialize(opts = {})
    @users = []
  end

  # Whenever we add a new user to our array, we wrap the code
  # with `run_callbacks`. This will run any defined callbacks
  # in order.
  def add_user(u)
    run_callbacks :user_added do
      @users << u
    end
  end
end
```

For a fully documented and runnable example, check out [this github project](https://github.com/jch/as_callbacks_tutorial). It'll also give some extra explanation about call order and inheritance.

## Other Useful Callbacks

* **:after_initialize** is called right after an object has been unmarshalled from the database. This allows you to do any other custom initialization you want. Instead of defining an `initialize` method on a model, use this instead.

* **:after_find** hasn't been useful in my experience. I haven't run into a case where I wanted to manipulate documents after a find action. It could potentially be useful for metrics and profiling.

* **:after_touch**. ActiveRecord allows you to [touch a record](http://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-touch) or its association to refresh its `updated_at` attribute. I've found this callback useful to triggering notifications to users after a model has been marked as updated, but not actually changed.

* **:after_commit** is an interesting and tricky callback. Whenever ActiveRecord wants to make a change to a record (create, update, destroy), it wraps it around a transaction. `after_commit` is called after you're positive that something has been written out to the database. Because it is also called for destroys, it makes sense to scope the callback if you intend to use it only for saves. Be warned that after_commit can be tricky to use if you're using nested transactions. That'll probably be the topic of another post though.

```ruby
# call for creates, updates, and deletes
after_commit :all_callback

# call for creates and updates
after_commit :my_callback, :if => :persisted?
```

* **:after_rollback** is the complement to `after_commit`. I haven't used it yet, but I can see it as being useful for doing manual cleanup after a failed transaction.


## Go Forth and Callback!

While many of our models will be backed with ActiveRecord, or some ActiveModel compatitible datastore, it's nice to see how easy it is to follow a similar pattern in normal ruby without having to depend on Rails.

