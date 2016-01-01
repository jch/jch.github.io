# Beerpad Hackathon: Hosting with Heroku #

When I started [planning out
Beerpad](/articles/2010/02/27/hackathon-beerpad), I wanted to focus on
fun beer ideas.  I'm perfectly capable of setting up an environment
for a Rails application to run in, but I didn't want to waste a
morning doing a bunch of chores and have nothing but a "Hello World"
page to show for it.  Once I had my designs, I wanted to prototype the
*juicy real features* right away.  Enter
[Heroku](http://www.heroku.com/).  Heroku is a service for hosting
Ruby webapps.  I've been interested in the service since I saw [Adam
Wiggins](http://adamblog.heroku.com/) demo it at a [SVC Ruby
Meetup](http://www.meetup.com/silicon-valley-ruby/).  Heroku is a
one-stop service for starting a database-backed, [Rack
compatible](http://rack.rubyforge.org/), Ruby webapp.  They use git to
version control your code, [Thin](http://code.macournoyer.com/thin/)
to serve your traffic, and [Postgresql](http://www.postgresql.org/) to
store your data.  They also have [add-ons](http://addons.heroku.com/)
that webapps may find useful.  I've been looking for an excuse to play
with the service, and [Beerpad](http://beerpad.heroku.com/) fit the
bill perfectly.  Follow the jump for my experiences.

## Research ##

Before I got started, I read through their [well-written
documentation](http://docs.heroku.com).  It's good to get a high-level
architectural overview of Heroku's infrastructure to appreciate how
much plumbing the service abstracts.  If you're familiar with
deploying a Rails app on a Linux system and use git as your VCS, the
learning curve isn't steep.  That said, because Heroku manages your
entire software stack, there'll more than one layer that you'll need
to reference when you're first starting out.

## Getting Started ##

The first step was to generate my blank Rails project.  I chose to use
postgresql locally to mirror the production environment closer, and
also because I had [it setup for previous
projects](http://www.whatcodecraves.com/posts/2008/02/05/setup_rails_with_postgresql/).
Once I verified my application ran locally, I added Heroku as a git
remote source and pushed.  The really cool part here is that Heroku
uses git's post receive hook to [package your dependencies with Gem
bundler](http://github.com/carlhuda/bundler) and deploy it on their
infrastructure.

## How's it drive? ##

As someone who has deployed several different Rails apps with
[capistrano](http://www.capify.org/) and different requirements, my
jaw dropped when I saw in my terminal:

    -----> Heroku receiving push
    -----> Gemfile detected, running Bundler
           All dependecies are satisfied
           Locking environment
    -----> Rails app detected
    -----> Installing Exceptional plugin from
    -----> git://github.com/contrast/exceptional.git...done.
    -----> Installing quick_sendgrid plugin from
    -----> git://github.com/pedro/quick_sendgrid.git...done.
    -----> Installing New Relic plugin...done.
           Compiled slug size is 7.6MB
    -----> Launching.......... done
           http://beerpad.heroku.com deployed to Heroku

With a simple "git push heroku", Heroku resolved my gem dependencies,
installed [add-ons](http://addons.heroku.com/) to handle exception
reporting, emails, and performance monitoring, and restarted the app
servers.

Sure, I've accomplished all of these things before with my other apps,
but each of those tasks had to be thought out separately, written, and
**maintained**.  I love the git workflow abstraction.  You design, you
test, you code, you push, and voila!  Your app's online.  Rinse and
repeat, and you have an amazing prototyping tool.  I don't miss
configuring capistrano, databases, and postfix.  I don't miss having
separate credentials for github, amazon web services, monitoring, and
servers.

## Rattles and Squeaks ##

As much as I love the service up to this point, not everything was
smooth sailing.  At one point, when I pushed the code, Beerpad would
barf up a completely cryptic backtrace.  Trying to access the app via
the online dashboard would cause the dashboard to barf with a 500
server error.  Emailing back and forth with support indicated that it
was a known bug they're working on, and the fix was to delete and
re-add my project.

Now I didn't mind the outage because Beerpad is a toy application with
zero traffic, but if my bread and butter app mysteriously died and the
fix after 24 hours was to delete and re-add, heads would've rolled.

Another annoyance is only 100 lines of logs are kept.  Down the line,
I can imagine an add-on to address this, but in the meantime, [people
sent their log data to external
services](http://www.ioncannon.net/programming/842/heroku-tips-for-the-cheap/#heroku-logs).
This works, but definitely isn't in the spirit of removing plumbing
responsibilities from the user.

## Would I pay for it? ##

Definitely.  Without a doubt, I see Heroku's value.  It consolidates
several services into one, adds a functional dashboard, and has room
for extensibility.  It saves you a ton of time on plumbing unrelated
to your webapp.  If you're starting a new Ruby webapp, whether
personal or commercial, you'd be nuts to duplicate the work the Heroku
guys have done.  On top of that, because you won't have a dedicated
systems team (read: $$$), you'll end up doing a much worse job.

If you have an existing app and a well defined deployment process, the
story changes.  Replacing one good process with another is a lot of
work and might not be worth it.  But that decision needs to be weighed
on a case by case basis.  For new projects, Heroku is freaking
awesome.
