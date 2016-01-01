# Hacking Live Systems #

After my evening jog, I hopped onto the QA environment around 11pm
because I wanted to look something up for another blog post I was
writing.  Instead of being greeted with the welcome screen of the app,
I get redirected to our homepage.  All kinds of warning flags were
going off in my head, but I couldn't collect my thoughts because of
the runner high.  Did I break something before I left work?  Did I
forget to deploy the latest code base to QA?  Were we going to lose a
night of quality QA from the team in India?

My fears were confirmed when I signed on to chat.  Kyle was online.
Kyle is *never* online this late.  I shoot him a quick message, "can
you reach devtrunk?".  Just as I hit return, I get a message from
Minh, "did you change the deploy stuff?".  QA in India had nothing to
test on.  Things were looking grim.

Deep breath, and go!

Do a fresh deploy.  Interesting, the deployment went through without a
hiccup.

SSH into the QA box, look at the Apache logs.  Interesting, Apache's
down.  Let's bring her back up.

Hit the page.  Interesting, still getting redirected.  Must be a bad
config.

Scan through httpd.conf, scan through the included vhosts.
Interesting, they all look ok...

WAIT!  There's no vhost defined for devtrunk, the QA environment.  But
I saw it earlier today...  Let's find an old working config and put
that guy in for now.

Reloading Apache...

<img src="/images/devtrunk-lives.png" alt="devtrunk lives!" />

I have never been happier to see Domo-kun.

It's funny when these situations come up.  Programmers go into this
'turbo' mode.  They start typing really fast, fixing and breaking
things left and right.  This surge of energy can't be sustained for a
long period of time, so it's really important that they both diagnose
and fix the problem before they burn out.  I left out all the details
in my description for the solution, but they involved a lot of window
switching, poorly typed out IM messages, and a lot of keystrokes.

Man, what a rush.  I'm not sure what gave me more of a workout, a 45
minute hour run, or typing frantically while figeting my leg.
