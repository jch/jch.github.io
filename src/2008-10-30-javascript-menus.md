# Building Webapp Menus #

One feature we're releasing for this sprint is a quick access menu on
every page for the common day-to-day actions used in Coupa.
Previously, a user would either have to bookmark the common urls they
used, or dig through the cluttered Administration page to find what
they wanted.  For our app, we needed something more expressive than a
simple web navigation because there are simply too many actions for a
user to take.

Before I bore you with all the reasoning and technical mumbo-jumbo,
this is what the final menu looks like.  All the sexiness is provided
by the mad skills of Kyle and David.

<img src="/images/coupa_menu.png" alt="sexy image of menu with tabs and subtabs" />

Our application deals with several different document types.  There
are some common workflows that these documents follow.  The most basic
workflow is for a user to create a Requisition, have that requisition
go through an approval process, create a Purchase Order (PO, in
procurement-speak) from that requisition, and manage Invoices, and
Inventory based on POs.  We took a very Apple approach to organizing
the top-level tabs so that users can think of what *document* they
want to work with, and then drill down to see what actions are
available on that document type.  Initially, we had action-oriented
tabs, but it was hard and confusing to figure out how to logically
group the submenu items.

Based on who's logged in, there are different tabs, and different
submenus.  If a normal user logs in, all they can see is the Home tab
because all they care about is ordering stuff.  Admins and various
supervisor roles will see different sets of tabs.  To make this
possible, we use a great little Rails plugin called
[Blueprint](http://blueprint.devjavu.com/) to define the structure of
the menu in Ruby code.  It lets us define a hierarchial menu structure
with ruby blocks.  Very spiffy.

    class GlobalMenuStructure < Blueprint::Container
      define do
        node 'menus' do
          menu 'Home' do
            node 'links' do
              link 'Home', :link_to => { :controller => 'user', :action => 'home' }
              # ...
            end
          end

          menu 'Requests' do
            node 'links' do
              link 'Requisitions', :link_to => { :controller => 'requisitions', :action => 'index' }
              # ...
            end
          end

          #...
        end
      end

Defining the structure in code enables us to generate and tailor a
menu for each specific user.  The hierarchial menu structure also lets
us create a reverse-lookup object to determine which tab should be
highlighted based on the current page's url.

After the menu structure is defined, we looped over the structure and
conditionally spewed out a bunch of unstyled ul's for the menu.  We
chose [YUI Menu](http://developer.yahoo.com/yui/menu/) to give us
cross-browser hover effects and actions on the menus.  YUI lets you
define a menu either in HTML markup or in javascript.  Theoretically
we would get slightly faster performance if we created the menu's in
javascript, but it was easier to do styling and extra features if we
defined it in markup.  Note that doing it in markup leaves users
without javascript with an equally unusable app because the unhidden
and unstyled submenus would cover everything else.  YUI also allows
you to trap for keypresses so you could implement keyboard shortcuts
if you wanted.

I don't recommend these super deep and complex menus for webapps,
because it ends up making the webapp feel more like a desktop app.  At
the same time, web menus are never as good as native desktop menus, so
it ends up looking half-assed.  The Coupa menus are definitely the
best solution for the problem though.  If we didn't have menus, we'd
still be control-f'ing for that link we wanted.
