# Messy Ruby Requires #

At some point in tinkering with a language, you outgrow simple scripts
and want to organize your code into separate modules that live in
separate files.  It's just this little OCD code habit you develop.
Since I've only been using Ruby with Rails up till now, loading and
importing the correct library files have been completely hidden away
by Rails convention and magic.  Everytime I want to use a library
named 'acts\_as\_giraffe', I either A) assumed it was loaded already, or
B) do <tt>require 'acts_as_giraffe'</tt>.  But the real world's not
so easy.

Like other languages, Ruby has a concept of a load-path where it'll
search for .rb files to require.  To see what this defaults to, run
the following:

    ruby -e 'puts $LOAD_PATH'

The shorter, perlish version is to use $: instead of $LOAD_PATH.  This
variable is just an array of directory names to search when require is
called.  To add or remove load paths, just mutate the list with shift
and unshift.  To see what Rails magic provides you, go to a Rails
project, and run <tt>script/console</tt> and print $:

Amazing isn't it?  For my housing project that uses Edge Rails, I see
that the precendence for loading libraries is something along the
lines of:

 * vendor/gems
 * current directory
 * system ruby libraries
 * system ruby
 * gems
 * vendor/rails
 * vendor/plugins
 * app/models
 * app/controllers
 * app/views

This is a much longer list of paths to look for a library
compared to the first run I did on the command line.

What I like about this magic is that it keeps most of my code clear
from hardcoded or semi-hardcoded absolute paths like the following:

    require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

The [first hit on
google](http://blog.8thlight.com/articles/2007/10/08/micahs-general-guidelines-on-ruby-require)
about the topic is a pretty good explanation of the problem.  I agree
that a single giant 'require farm' is hard to unmaintain and pretty
unsightly, but I do think that small require farms that are associated
with specific modules and directories are a good way to organize.  For
example, if I had a library called 'obfuscator' that lives in many
separate files:

    obfuscator/
      crypt.rb
      cram.rb
      barf.rb

I'd add an 'obfuscator.rb' file that globed all the rb files and
required them:

    Dir.glob(File.join('obfuscator', '*.rb')).each do |lib|
      require lib
    end

Then whenever I wanted to use obfuscator, I'd simply require
'obfuscator.rb'.  The above would work if your current working
directory is the same as obfuscator.rb.  Unfortunately, if it isn't,
then you're screwed because require won't be able to find
obfuscator/*.rb relative to where you are.

One fix is to hard code the glob to be relative to the current file,
rather than the current working directory:

    Dir.glob(File.join(File.dirname(__FILE__), 'obfuscator', '*.rb')).each do |lib|
      require lib
    end

This will make the library lookups relative to 'obfuscator.rb'
(__FILE__).  Since it's semi-hardcoded it'll work.

Another
[solution](http://blog.objectmentor.com/articles/2008/07/20/bauble-bauble)
that I came across today that I liked is to have the library
to-be-loaded be in charge of doing the requiring.  I noticed that
[Webby](http://webby.rubyforge.org/) also used a similar trick called
<tt>ensure_in_path</tt> to calculate some library loading:

    # Adds the given arguments to the include path if they are not
    # already there
    def ensure_in_path( *args )
      args.each do |path|
        path = File.expand_path(path)
        $:.unshift(path) if test(?d, path) and not $:.include?(path)
      end
    end

I'll keep an eye out for other clean ways people have been approaching
this problem, but so far I like the approach of manipulating the load
path in a function or file, and having that function or file loaded
before the rest of the project.  I hope that clears up some requiring
woes!
