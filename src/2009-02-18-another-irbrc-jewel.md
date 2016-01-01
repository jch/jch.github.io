# Another .irbrc Jewel #

A while back, I discovered the magical
[.irbrc](http://giantrobots.thoughtbot.com/2008/12/23/script-console-tips).
If you scroll down to the comments, Arthur and I left a tip on how to
view arbitrary script/console output in Textmate.  It's really amazing
for XML or big chunks of output.  Other useful irb links after the
fold.

[Stephen Cells](http://stephencelis.com/) mentioned the [utilitybelt
ngem](http://utilitybelt.rubyforge.org/). It might be overkill, but
I'll probably pick through for a few good bits.

I added another snippet to my .irbrc for copying stuff to the
clipboard on OS X.

    class Object
      def pbcopy(string)
        IO.popen('pbcopy', 'w') { |f| f.puts(string) }
        nil
      end
    end

