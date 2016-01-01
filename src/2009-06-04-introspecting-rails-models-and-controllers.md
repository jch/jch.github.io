# Introspecting Rails Models and Controllers Callbacks #

Once models and controllers grow to a certain size and complexity, it
gets tricky to figure out what callbacks act upon them.  This is
especially true for objects that are several inheritance layers deep,
have multiple mixins, were written a long long time ago, or any
combination of the above.  I've picked up a few tools for crushing
nasty little callback buggers that crop up every now and then.  I hope
you find them useful!

## ActiveRecord Callbacks ##

Model validation and save callbacks are provided by the module
[ActiveRecord::Callbacks](http://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html).
If you read through this code, you'll find that it's built on top of a
great little module called
[ActiveSupport::Callbacks](http://api.rubyonrails.org/classes/ActiveSupport/Callbacks.html).
I'm a big fan of this module because it gives you a nice abstraction
to defining callbacks on arbitrary Ruby objects.

The callbacks defined on ActiveRecord::Base sub-classes are

    after_find
    after_initialize
    before_save
    after_save
    before_create
    after_create
    before_update
    after_update
    before_validation
    after_validation
    before_validation_on_create
    after_validation_on_create
    before_validation_on_update
    after_validation_on_update
    before_destroy
    after_destroy

To see the list of a particular callbacks, suffix the callback type
with '_callback_chain'.  For example, to see the 'before_save'
callbacks defined on the model Supplier:

    Supplier.before_save_callback_chain

This will give you a list of
[ActiveSupport::Callbacks::Callback](http://api.rubyonrails.org/classes/ActiveSupport/Callbacks/Callback.html)
objects that have interesting attributes such as identifier, kind,
method, and options.

To get a named list of callbacks, do

    Supplier.before_save_callback_chain.map(&:method)

To see whether a callback is conditional, check out it's 'options'

    Supplier.before_save_callback_chain.first.options

## ActionController Callback ##

Controller callbacks documentation can be found at
[ActionController::Filters::ClassMethods](http://api.rubyonrails.org/classes/ActionController/Filters/ClassMethods.html).

SuppliersController.filter_chain

Again, the array of filter objects returned by 'filter_chain' are
ActiveSupport::Callbacks::Callback instances.  This lets you check the
method names being called, as well as what options are set on it.

## In General ##

Unrelated to callbacks, but a useful debugging tool to figure out what
caused your code to be in it's current context, use
[Kernel.caller](http://www.ruby-doc.org/core/classes/Kernel.html#M005955)
to get a list of filenames and methods of the call stack.  It's
usually pretty noisy, so I use
[Enumerable#grep](http://www.ruby-doc.org/core/classes/Enumerable.html#M003152)
to filter for what I'm interested in.

    Kernel.caller.grep /supplier/

The combination of these 3 tips have helped me debug strange callback
order bugs, as well as help me learn about a complex model that I've
never dealt with before.  Unfortunately, I put off writing about this
topic for so long that I've forgotten some of the tips.  As always, I
found reading into the ActiveRecord and ActiveSupport code to be
particularly enlightening.  If you have some other interesting
introspection tips that help you develop, please share them in the
comments ;)
