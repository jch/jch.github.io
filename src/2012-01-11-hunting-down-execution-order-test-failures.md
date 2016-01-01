# Hunting Down Execution Order Test Failures

Unit tests should pass when run in random order. But for an existing legacy
project certain tests might depend on the execution order. One test might run
perfectly fine by itself, but fail miserably when run *after* another test.
Rather than running different combinations manually, RSpec 2.8 has the option
to run specs in random order with the `--order random` flag. But even with
this it can be hard to determine which specific test is causing the
dependency.  For example:

    rspec spec/controllers  # succeeds
    rspec spec/lib/my_lib_spec.rb  # succeeds
    rspec spec/controllers spec/lib/my_lib_spec.rb  # fails

In this scenario you know that one of the spec files in spec/controllers is
not jiving with your lib spec, but if you have hundreds of spec files, it's
hard to tell which. Never fear! There's a Ruby one-liner for that:

    ls spec/controllers/*.rb | ruby -pe '$_=`rspec #{$_} spec/lib/my_lib_spec.rb`'

Let's break this command down into its components:

    ls spec/controllers/*.rb

gives you a list of spec files to run alongside your lib spec

    ruby -pe

'e' for execute, and 'p' means wrap the code in a loop and assign  each line of STDIN to `$_`. We're piping in STDIN from the `ls` command.

    $_=`rspec #{$_} spec/lib/my_lib_spec.rb`

The 'p' flag also prints out the value of `$_` at the end of each loop. So we assign the output of running rspec with the 2 files (one from ls alongside `my_lib_spec`).

My bash buddies would wag their fingers at me for using a ruby one-liner here,
but it's a familiar syntax and it's easier for me than remembering other
shell commands and regex flags. If there's something another unix program is
better at processing, then I can then take the output of the ruby one-liner
and pipe it into another command. It's a very simple and versatile way to
munge on text.
