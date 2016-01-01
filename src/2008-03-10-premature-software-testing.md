# Premature Software Testing #

I've fallen victim to it a few times now and would like to remind
myself of the causes and consequences.  Don't get me wrong, I love
testing and have attempted/done/failed at it ever since CS61B.  I've
used standardized test frameworks, hackish quickie frameworks from
school, and created my own small frameworks for specific projects.
Testing is a good thing.

But there is such a thing as testing too early.  My most recent mishap
happened during my internship.  I finished a tool that I thought did
what I want, and fully tested it.  Well, the plus side was that it was
perfectly tested against what it does, and worked beautifully for all
possible inputs.  The downside was that the code didn't do what it was
supposed to do!  I misunderstood my own requirements and coded
something wrong.  Then instead of having tests that could support me
as I refactored, I ended up with an extra set of barriers that kept me
constrained to wrong solutions.  In other words, I believed in my
tests and this slowed down my redesign towards a correct solution.

Another time this happened to me was during cs164 while I was writing
an Earley parser.  This one cut me deep because the solution just
happened to work against the cases I specified in my tests.  Then
about one week before the due date, I noticed that I misread the
original paper and implemented a system with different semantics.  All
the tests that exercised individual methods were scrapped.  In the
end, all tests were scrapped :(

I lost many hours on both those mistakes, but I have noticed different
cases when I'm more successful.  Here are some guidelines I think work
well:

## When to Start Testing ##

* start testing when you start coding for real.

* start coding <em>for real</em> after you've read and re-read your
spec enough times to recite it backwards.  Think of a design, think of
how use cases would fare against that design.

* if there are sections of the design that are ambiguous, or if you
aren't sure of what tools to use to implement something, explore with
quick dummy code and take notes.  Don't even bother putting the dummy
code in your repo, or actual directory... It'll only tempt you to keep
crappy code.  Throw the code away, but keep the notes.

* with design doc, and notes from exploring in hand, try writing some
real code.  If you find yourself rewriting a ton of stuff repeatedly,
you didn't design/explore your problem space enough before starting.

* when exploring concepts and designs, it's a good idea to explore
what test strategies are appropriate.  I say appropriate because
there'll always be some gigantic mammoth of a testing framework with
more features than your project needs and a configuration and learning
curve to match.  Sometimes, the framework that's "just right" is one
that you glue together.


## How to Test ##

There are plenty of good guides out there on 'what' to test, but I
think many of them provide examples that are too trivial and brittle
against refactoring.

* when testing data models, focus on getting consistent domains, and
lightweight models.  If it's hard to test, it might indicate a flaw
in your design.

* unit testing is fantastic, but double check that the methods you're
testing are actually relevant and useful.  A correct method doesn't
imply a useful one.  Also, instead of tying very strictly with method
names, it can be more readable and flexible to describe your test in
terms of the action or mutation.

* don't strictly focus on unit testing.  Do the functional tests in
parallel to expose useless methods and flawed interactions early on.
The same applies for integration tests.  Also, the sooner you
communicate with modules written by other members of your team, the
better.

We all knew that testing too late or not testing at all can cause
cancer, but there is such a thing as testing too early.  It wastes
your time, and may restrict you to a suboptimal or incorrect design.
Furthermore, testing isn't the same as designing.  No amount of random
testing will yield a solid design.  Rather, an elegant design will
naturally encourage you to think about tests, and those tests can then
verify your implementation.  Testing is like eating your vegetables:
it's good for your health in the long run, but eating too much or the
wrong kind will give you the runs.