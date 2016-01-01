# Deploying into the Night #

Yesterday was an emotional roller coaster of brutality and
awesomeness, mixed with a good share of productivity.  The day started
off innoculously enough.  I checked my incoming tickets, went through
my email for tasks to do on my projects, scrummed with the team, and
enjoyed a delicious steak lunch on the house...

Waah?  Steak lunch at
[Porterhouse](http://www.yelp.com/biz/porterhouse-san-mateo#hrid:cepR76qS-iHdExL6VGTOeg)?
Thanks to our awesome admin, Jules, Kyle, Lee, and myself got to relax
and chat over some juicy meat and a cold beer.  I had an especially
good time talking to Lee since I haven't made a big effort to talk to
coworkers outside the dev team.  It made me appreciate what it takes
to run a company efficiently, and also what kinds of features other
internal users care about.  Kyle's sexy and all, but I get to see and
talk to him everyday :).

Lunch was fantastic, but as I drew closer and closer to dinner time,
the situation looked worse and worse.  The planned upgrade time for
our 105 customer environments was scheduled to occur at 6:00pm.  I
felt like I had a good grasp of the bugs I was working on, so I
thought I'd lend a hand to the Operations team by making one of my
slow migrations run faster so they could go home earlier.  In doing
so, I realized that my migration wasn't comprehensive enough to cover
all the bad cases.  I was super thankful that this bug was caught with
only 15 minutes left before the scheduled downtime.

Of course, when I found this bug, I felt uneasy deploying the changes
without some heavy duty QA.  I thought I would stick around just to
make sure the migrations wouldn't croak.  I thought to myself, how
long could this possibly take?

We started the process off by disabling customers from accessing the
application and putting a placeholder HTML page.  Seggy quickly
cancel'ed this action because his phone started getting notifications
from [Pingdom](http://pingdom.com/) because the site uptime checkers
hadn't been paused.  Next the migrations were run for all the
instances and they seemed to work ok.  I breathed a sigh of relief,
and told Wendy that I'd be heading home at any moment...

An hour or so later, we were finally able to check off the
verification tasks in Google Docs for some custom PDF template
changes.  These were super annoying to deal with and didn't work right
away because we had bad merge data between trunk and stable.  But we
did finish, I breathed a fresh sigh, and I apologized to Wendy and
reassured her again that I'd be leaving soon...

Another hour or so later, we solved custom LDAP mixin code for the
single customer who used LDAP.  Because we refactored out most of our
config to use
[Simpleconfig](http://github.com/lukeredpath/simpleconfig/tree/master),
we were having issues deciding where to put the custom LDAP code.
This lead to a wild goose chase because the load order of when the
custom code was mixed in determined if it worked or not.  Worse yet,
we found *another* code error where the LDAP authentication code
wasn't run at all.  This took some diff-ing and merging to fix up.

I finally left the office 5 minutes to 11pm.  My heart was pumping
like mad from fixing those problems, my stomach was growling like
crazy, and my brain was turning off at an exponential rate.  It was
quite a rush to help out with the deployment.  The key lesson I took
away from that was how big a maintenance nightmare customer-specific
features are.  I understand why they were done, but if they weren't
there, none of the problems would've shown up and we would've finished
hours ago.

I had already thought Lee and Seggy were amazing coworkers, but now I
have a new level of respect for them.  I'm also super sorry to Wendy
and Serena for putting up with us taking so long.  I felt especially
guilty that the custom PDF templates wasn't a smooth transition
because I wrote the fixes for it.
