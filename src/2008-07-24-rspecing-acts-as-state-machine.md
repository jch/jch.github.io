# RSpec'ing acts\_as\_state\_machine #

One of my favorite plugins I've seen so far is
[acts\_as\_state\_machine](http://agilewebdevelopment.com/plugins/acts\_as\_state\_machine).
It's a dead simple way to model the different states your models can be
in.  It also lets you register callbacks to when a model enters,
entered, or leaves a particular state.  It's absolutely fantasic until
I have to test it.  Then it becomes an absolute nightmare.

The first intuitive, but horrifically wrong idea is to stub out the
current state:

    @model.stub!(:state).and_return('old_state')
    @model.some_event!
    @model.state.should == 'new_state'

The problem with this is the mock will always return old\_state, even
if some\_event! caused @model to go into new\_state.

A less intuitive, but workable solution is to check that the
transition event was fired:

    @model.should_receive(:update_attribute).with(@model.class.state_column, "matched")

This is a little nicer, but kind of obscures the intention of the
test.  So ideally, I'd like to be able to say something like:

    @model.should transition_to('matched').from('draft')

Thankfully, the crappy RSpec documentation does cover this case.  It
was easy to write a [custom expection
matcher](http://rspec.rubyforge.org/rdoc/classes/Spec/Matchers.html):

    module ActsAsStateMachineMatchers
      class Transition
        def initialize(expected)
          @expected = expected
        end

        def matches?(target)
          @target = target
          @target.should_receive(:update_attribute).
            with(@target.class.state_column, @expected)
        end

        def failure_message
          <<-MSG
          expected #{@target.inspect} to transition to state
          #{@expected}, but in state {@target.state}
          MSG
        end

        def negative_failure_message
          <<-MSG
          expected #{@target.inspect} to transition to state
          #{@expected}, but in state {@target.state}
          MSG
        end
      end

      def transition_to_state(expected)
        Transition.new(expected)
      end
    end

This is one step away from my ideal case because I was too lazy to a
Spec::Mocks::Methods with a corresponding
Spec::Mocks::MessageExpectation, which is what 'should\_receive' and
'with' are.  If I ever get unlazy enough to poke into the code more, I
could write the analogous 'should\_transition\_to', and 'from'.  This
might be a good excuse to open a github account and play with that too
:)
