# Capify my App #

After a complete Saturday of vegging out, I decided to accomplish
something today.  My initial target was to pull Craigslist rental
listings for my [housing app](http://housing.whatcodecraves.com/), but
that led to me learning more about plugins, which somehow led me to
reading about Capistrano.  Yak shave, anyone?

I blazed through the book <a
href="http://www.amazon.com/gp/product/0978739205?ie=UTF8&tag=what0d-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0978739205">Deploying
Rails Applications: A Step-by-Step Guide (Facets of Ruby)</a><img
src="http://www.assoc-amazon.com/e/ir?t=what0d-20&l=as2&o=1&a=0978739205"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" />.  I skimmed through the first 4 chapters
because they didn't present anything new to me.  I spent much more
time reading through chapter 5: the what, why, and how of Capistrano.
After my first reading, I decided to test it out with my Dreamhost
setup of housing app to try my luck.

One thing that threw me off initially was roles.  Roles are simply
different servers that are involed in the deployment.  Each Capistrano
recipe is run for all roles by default.  For example, the deploy:setup
recipe creates the initial directory structure on the server for
checking out the Rails application.  Capistrano tried to run this
recipe on both my :db and :app roles.  I couldn't find a way of adding
an exception to what roles an *existing* recipe is run on, so I
removed the :db role entirely.  I didn't have a use for a :db role
anyways, but I could see that as a problem in the future.

Next, I wrote a small task to keep database.yml the same between
deployments:

    task :fix\_config, :except => { :no\_release => true } do
      run "ln -s #{shared_path}/config/database.yml #{release\_path}/config/database.yml"
    end

    after 'deploy:symlink', 'fix_config'

I also overrode the deploy:restart task to fit with Phusion
Passenger.

    namespace(:deploy) do
      desc "Restart Passenger.  The file is deleted when it restarts"
      task :restart do
        run "touch #{current_path}/tmp/restart.txt"
      end
    end

After that, it was clear sailing.  The deployments were unacceptably
slow because a checkout of my project is 62MB (darn your edge
rails!). I found the Rails site
[guide](http://manuals.rubyonrails.com/read/chapter/97) to Capistrano
to be very good.  The same can't be said for the main [Capistrano
site](http://www.capify.org/).  The saving grace for that is all the
methods are well commented and straightfoward if you read through the
Capistrano source.

If I had to summarize Capistrano, I'd call it an interpreter for a
Rake-like domain specific language to records and play back commands.
Specifically, it's useful for Rails deployment because it automates
tedious and error prone sequences of commands to deploy a bundle of
code to a web directory, run any scripts or rake tasks, and kick any
servers or services.  As an added bonus, it sets a cute convention for
directory structure and allows you rollback to different deployments.
It's especially easy to pick up if you've written any Rake tasks in
the past.  I can see how Capistrano can be useful outside of Rails
projects as well.  It's simply a great little tool for automating
commands.
