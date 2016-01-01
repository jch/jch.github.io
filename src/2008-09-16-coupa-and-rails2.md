# Coupa and Rails 2 #

Joy and churchbells this morning here in sunny San Mateo!  David
smacked down Rails 1.2.3 with a heavy hand and replaced it with the
newer and shinier Rails 2.1.1.  Here's what's rocking and
not-so-rocking with the upgrade.

For starters, the upgrade was completely painless from my
perspective.  It was really as easy as:

    sudo gem install rails  # to update rails to 2.1.1
    svn up

That's it!  script/server started up fine, and all was happy...  Until
I logged in.  Then I was confronted with the not-so-friendly
exception:

    ActionController::RenderError (You called render with invalid options : {:layout=>false, :action=>"cloud_portlet"}, nil):
    /Library/Ruby/Gems/1.8/gems/actionpack-2.1.1/lib/action_controller/base.rb:847:in `render_with_no_layout'
    /Library/Ruby/Gems/1.8/gems/actionpack-2.1.1/lib/action_controller/layout.rb:260:in `render_without_benchmark'
    /Library/Ruby/Gems/1.8/gems/actionpack-2.1.1/lib/action_controller/benchmarking.rb:51:in `footnotes_original_render'
    /Library/Ruby/Gems/1.8/gems/activesupport-2.1.1/lib/active_support/core_ext/benchmark.rb:8:in `realtime'
    /Library/Ruby/Gems/1.8/gems/actionpack-2.1.1/lib/action_controller/benchmarking.rb:51:in `footnotes_original_render'
    /vendor/plugins/footnotes/lib/textmate_initialize.rb:12:in `render'

It turns out the old Textmate footnotes plugin doesn't play well with
new Rails.  A simple <code>svn rm</code> and we were on our way.

Unfortunately, Textmate wasn't the only broken plugin.

## ScopedAccess and named_scope ##

[ScopedAccess](http://agilewebdevelopment.com/plugins/scoped_access)
was also broken.  ScopedAccess allowed us to impose conditions on
ActiveRecord finders in our controllers.  For example, to show only
budget adjustments made on a specific budget, I had the following
ScopedAccess filter defined on the budgets controller.

    around_filter ScopedAccess::Filter.new(BudgetLineAdjustment,
      Proc.new { |controller|
        { :find => { :conditions => ['budget_line_id = ?', controller.params[:id]] } }
      }),
      :only => [:show, :show_owned ]

This filter wraps around the <code>:show</code> and
<code>:show_owned</code> action.  Whenever <code>find</code> is called
on BudgetLineAdjustment, the <code>:conditions</code> hash it passed
in with the finder.  This worked pretty well and I didn't think it
breached MVC design.

Arguably, it's the model's job to limit and filter what's accessible.
That's exactly what Rails 2.x does.  We've refactored our
ScopedAccesses with
[named_scope](http://api.rubyonrails.org/classes/ActiveRecord/NamedScope/ClassMethods.html#M001246)
at the model layer.  The above example now lives in
BudgetLineAdjustment:

    class BudgetLineAdjustment
      named_scope :for_budget_line,
                  lambda { |budget_line|
                    { :conditions => ['budget_line_id = ?', budget_line.id] }
                  }
      # ... snip
    end

## Engines ##

Initially, we didn't plan on switching to Rails 2 this sprint.  The
original plan was to scrap [LoginEngine and
UserEngine](http://rails-engines.org/) from the project to *prepare*
to migrate to Rails 2.  Replacing Engines just a tedious scan through
all the Engine code we used and selectively copying over the code that
we wanted to keep.  Initially I thought that I would have a hell of a
time migrating this to fit with restful_authentication, but it wasn't
bad and I removed *tons* of code.

## Views ##

Cosmetically, we renamed all the views to be suffixed
with .html.erb rather than .rhtml.

## Riding on Rails (2) ##

Migrating to Rails 2 was a straight forward project.  It didn't
require any new design.  We just had to make sure that whatever was
working before continued to work after the migration.  I'm super
thankful that we decided to tackle this project early in our sprint
because it gave up plenty of time to catch small silly things.  There
were plenty benefits to migrating to Rails 2.  We could remove a lot
of the backports of Rails 2 features that we had previously kept in
lib/rails_extensions.rb.  The whole system felt a bit snappier,
especially in development.  The development logs were actually useful
again because they weren't fill with deprecation warnings and noise
from the Engines code.  This is what it must feel like to be the cool
kid on the block.
