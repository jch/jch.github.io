# Shoot em up Debugging #

Debugging is like a video game.  Unfortunately, it's the meanest video
game you will ever play.  The objective is to destroy bugs, but each
destroyed bug will only reveal more sinister bugs with more health,
greater mana, and better AI.  After you've smooshed all the trivial
syntax buggers, a whole new species evolves and leaves you fighting a
being as intelligent as yourself.  That fleeting sense of
accomplishment that you felt the first time you vanquished a missing
semicolon quickly melts into a never-ending nightmare of software
maintenance.

Is there no hope at all?  Are we all doomed to play this never-ending
and un-winnable game?  Well, not really.  At least, I sincerely hope
not.  Thankfully the rewards are great, and who knows what the next
bug-boss will be like?

## Prevention ##

The first step to kicking bug-ass is to minimize the number of bugs.
It doesn't matter how great you are at finding mistakes after the
fact, it's much more rewarding to write a system and have it work to
spec the first time around.  Creating fewer bugs also keeps you
focused on writing *real* code and the big picture rather than chasing
down silly obscurities.

### Better Design ###

Everyone messes this one up.  I'm just as guilty as the next guy when
it comes to starting to code too early and digging myself into a hole.
Take your time and *think*.  Don't think with a computer, just grab
some coffee and doodle on some napkins.  It's amazing how detrimental
a computer and Internet can be for this.  They'll only lead you to all
kinds of minutia you shouldn't worry about.  It's as if you're
creating bugs before you even have an idea of what you need to do.
You can't win like that!

### Better Components ###

As you're designing, it's always good to start classifying your
components and modules.  Don't try to abstract everything into pez-sized
libraries.  Simply make a note to remind yourself when it's possible
and revisit these notes when needed.

Make sure to challenge your own bias and assumptions.  The more you
play devil's advocate, the less chance those bugs will have to
surprise you.  It's MUCH better to predict a bug rather than to have
one sneak in an infinite loops when you're not looking.

Challenge your interfaces.  Check your input, and output for
consistency.  Will your code degrade gracefully when something doesn't
work?  Will it notify somebody?  Am I trying too hard here?  Am I
making assumptions because I don't understand the problem?

A great way to see if you've covered all cases is to run it by a
friend.

### Better Testing ###

The absolute low point of every developer's life isn't when they're
stuck.  It isn't when a system fails;  It isn't even when we pass out
on our keyboards after that 3rd all-nighter.

No.  The lowest we succumb to is sitting in front of a terminal,
stepping through a jillion lines of code.

Debuggers are meant to help you, but I can't help but see them as a
very very expensive crutch.  That's because people use them when they
shouldn't.  When you're stepping through all those lines and praying
to see some anomaly, you're a goner.  Instead, you should identify the
naughty component and *test* it.  Testing beats stepping any day of
the week.  If designed with testability in mind, then woot.  Otherwise
if you're given a giant monolithic beast of a legacy system, try black
box tests.  Remember that testing doesn't require a fancy harness or
framework, but make a honest effort to make your tests available and
repeatable.

## Tools ##

Prevention can only get you so far.  When stuff starts crashing and
the cause is not immediately obvious, hunker down with some tools.

Be wary of tools.  There are always too many choices, and most will
offer more configuration than usefulness.  Always weigh the benefits
before you install the latest and greatest.  If GNU make does
everything you want, and you're comfortable with it, look long and
hard before switching over to the 'next big thing'.  Don't say I
didn't warn you if an afternoon goes by and you have a half-configured
build system.

* Automation of tests with CruiseControl or similar systems is
  fantastic, but are only as useful as the tests that are written.
  Given limited resources, prioritize quality of tests over
  automation.

* Profiling code for performance, leaks, and bugs are a great way to
  catch bugs that aren't mission critical now, but could get nasty in
  the future.  To be honest, I don't have much experience in this
  arena.  I hear Valgrind is pure black magic though.

* I hate debuggers.  Graphical or otherwise, there's just a ton of
  information spewing at you, and if you're stepping line by line and
  you missing a line, you have to start over. If you get tired, just
  stop.  There's no benefits to blankly staring at a call stack when
  your head goes numb.  Go have a lollipop instead.

* Learn to avoid using logging frameworks for debugging.  You're
  logging output will grow, and digging through log output is the same
  type of misery as going through a debugger.  Use logging as a form
  of notifying the user.  Use testing to verify correctness.

## Conclusion ##

Debugging is a nasty topic.  A big reason why software engineers are
paid so much is because of the pain it takes to maintain and debug
software.  But I believe that bugs aren't a lost cause, and with the
right attitude and habits, it might be more game than chore.

Now if you'll excuse me, I have to go tackle some decade-old crufty
Perl.
