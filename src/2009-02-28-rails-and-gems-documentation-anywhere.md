# Rails and Gems Documentation Everywhere #

<img src="/images/mobile-me.png" alt="stick figure of me and macbook"
style="float:left;padding:0 10px 10px;" /> A great thing about
[Coupa](http://www.coupa.com/) work is how I can hack it up without a
network connection.  The codebase is checked out and I run mysql
locally.  I fire up emacs and a script/server and I'm pretty much good
to go.  The only downside is not being able to access the rails and
gems docs.  Here's what I did to put together a productive local
setup.

**Update:** 2009-03-30 [Jason
  Seifer](http://jasonseifer.com/2009/02/22/offline-gem-server-rdocs)
  of RailsEnvy does a better job of explaining the process than I do.

**Note:** For the rest of this guide, I'm going to assume you have
ruby and gem installed via MacPorts.  If they aren't, change the
directories in the commands appropriately.

<br style="clear:both"/>

## Gems ##

First of all, let's generate the documentation for all of your
gems. If you're more accustomed to the layout of Rails documentation,
then install [Jamis's rdoc template](/files/rdoc_template.rb).

    # this step is optional
    cd /opt/local/lib/ruby/1.8/rdoc/generators/template/html
    sudo mv html html.original.rb
    sudo curl -o html.rb http://www.whatcodecraves.com/posts/2009/02/28/rails_and_gems_documentation_anywhere/rdoc_template.rb

(The link to the original template was broken for me.)

Now actually generate the rdocs.

    sudo gem rdoc --all

After the command finishes, start a gem server so you can browse the
docs:

    gem server --daemon

Point your browser at [the gem server](http://localhost:8088).

## Rails ##

You'll notice that no rdocs were generated for the Rails gem. This is
because the rdoc task is intended to be run from the root of a frozen
Rails app.  This is amazingly annoying, but is a [solved
problem](http://www.nullislove.com/2007/05/29/rails-documentation/).
Basically, you have to freeze Rails in your app, rdoc it, unfreeze it,
and copy over the rdocs.

    cd myapp
    rake rails:freeze:gems
    rake doc:rails
    rake rails:unfreeze
    sudo cp -R doc/api/ /opt/local/lib/ruby/gems/1.8/doc/rails-2.1.1/rdoc/

Now you can code from anywhere!  As an added bonus, the docs will load
blazingly fast.
