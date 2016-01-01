# Fuck Fixtures #

When you first start testing a newly created application, fixtures
might seem very appealing.  They're easy to write, they make sense,
and they quickly create valid or invalid instances for you to test
with.  Unfortunately, fixtures don't scale with a growing project.
They quickly get out of hand, and you'll end up spending more time
fixing your fixtures than your tests and code.  So fuck you fixtures,
and good riddance.

Fixtures are the devil because:

* they're brittle.
* they don't work well with complex association with foreign keys.
* they don't change when your schema and models change.

Rails 2 fixtures are nicer, but it's much of the same.  If you don't
believe me, just keep using them and you'll know what I'm talking
about at some point.

## A Valid Case ##

One interesting case my friend came across the other day was using
fixtures for rspec tests.  As described above, I think model fixtures
for testing is both brittle and hard to maintain.  However, he was
running across the case:

    it "should save to the freakin database" do
      @some_model.save.should == true
      debugger
    end

This test passes with flying colors...  But seeing is believing, and
if you login to the test database, you won't be seeing a saved
record.  This is generally a good thing because once the test is
finished, the transaction is rolled back, and you'll have clean data
independence between tests.  The downside is when you're testing
something like Sphinx that assumes there's stuff in the database to
work with, it won't work.  The above example will pass, and if you
break at the debugger line, @some_model.new\_record? will be false.

## So What Now? ##

Other than that valid case, most problems should be solvable by
stubbing and mocking.  If not, then refactor your code so that it is!
One particularly delicious piece of syntactic sugar called [Factory
Girl](http://github.com/thoughtbot/factory_girl/tree/master).  For a
short description of what it does, check out [this blog
post](http://giantrobots.thoughtbot.com/2008/6/6/waiting-for-a-factory-girl).

