# Rails Flash with Ajax #

One small annoyance about working with the
[flash](http://api.rubyonrails.org/classes/ActionController/Flash.html)
in Rails is that it only works well if you render separate pages per
action.  The flash falls apart if you do an Ajax call and render an
RJS template or some inline javascript.  The flash won't show up when
it should, and it'll show up on some other page when you don't want it
to.  I made 2 small changes to my app to make flash behave better when
an Ajax call is made.

The first trick is something I learned at work.  First, we need to
extract the rendering of the flash into a partial in
'app/views/layouts/_flash.html.erb'.  This will allow us to render the
flash in a normal template, but also allow us to replace the flash in
an inline render.  In my main template, I do a normal:

    <div id="flash_messages">
    <%= render :partial => 'layouts/flash' %>
    </div>

To refresh the flash when an Ajax request happens, I add a
'reload_flash' method to ApplicationHelper:

    def reload_flash
      page.replace "flash_messages", :partial => 'layouts/flash'
    end

Then from my RJS templates or from a <code>render :update</code>
block, I can call the reload_flash to refresh the flash inline:

    # within a controller action
    render :update do |page|
      flash[:notice] = "Entering 'beast mode'..."
      page.reload_flash
    end

This all seems fine and dandy until you visit another page.
Unfortunately, the flash is not cleared because you haven't visited
another action, so you end up with the flash message redundantly
displaying a 2nd time.  To fix this, I added an
<code>after_filter</code> to <code>ApplicationController</code> to
clear the flash after an action if it was an Ajax request:

    class ApplicationController < ActionController::Base
      after_filter :discard_flash_if_xhr

      protected
      def discard_flash_if_xhr
        flash.discard if request.xhr?
      end
    end

Easy isn't it?  The catch here is to remember to call
<code>reload_flash</code> whenever you're doing an inline render.

Another useful tip plugin for working with the flash is the
[flash-message-conductor](http://www.robbyonrails.com/articles/2008/08/29/flash-message-conductor)
plugin.  I use it to controll the logic of when to show the flash, and
also control some animations for hiding and showing the flash.  It's a
nice simple plugin.
