# Building reusable Ruby scripts

> Write programs that do one thing and do it well. Write programs to work
together. Write programs to handle text streams, because that is a universal
interface. -Doug McIlroy, Inventor of Unix pipe

This post illustrates some of the ideas behind the [Unix
philosophy](https://en.wikipedia.org/wiki/Unix_philosophy) by composing
utilities together to convert Markdown to HTML. I chose Ruby because it's a
language I'm familiar with, but also to show that shell scripting does not
require bash. The main idea is to write small filter scripts that can be
composed together with pipes to create flexible tools.

## Making an executable Ruby script

Typically, Ruby files end with a `.rb` extension and are executed by invoking
the Ruby interpreter explicitly. But instead typing out `ruby markdown.rb` each
time, we can use a [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) at
the top of our script to indicate which language and interpreter to use.

```ruby
#/usr/bin/env ruby
# This first line allows us to name our script `markdown` without the .rb extension
```

To skip invoking `ruby` explicitly, use a terminal to change the permission of
our script to make it executable:

```sh
$ chmod +x markdown
$ ./markdown  # no output and no errors
```

## Parsing command line arguments

For the first iteration, our script will take a single argument -- a filename of
a markdown document to convert to html. Command line arguments are available
through an Array named `ARGV`.

```ruby
#/usr/bin/env ruby
markdown_file = ARGV.first # ARGV is ['foo.md']
puts markdown_file
```

If we run our script, we see that ARGV is whatever arguments we pass in:

```sh
$ ./markdown foo.md
foo.md
```

Other languages sometimes provide a convenience method named `ARGC` to indicate
the number of command line arguments ((ARG)ument (C)ount) , but since `ARGV` is
an array, it's easy to grab the number of arguments by calling `ARGV.length`.

For a simple script like ours, it's sufficient to work with ARGV directly. If
there are complex options and flags to parse, the standard library's `optparse`
module is a good starting point. This
[gist](https://gist.github.com/rtomayko/1190547) is a template and an example
for parsing conventional POSIX style flags.

## An example Unix pipe

We have a markdown filename. The next step is to convert it to HTML. There are
many gems that will accomplish this, but for the sake of the exercise, we don't
install any gems. Instead, we can use GitHub's [markdown
API](https://developer.github.com/v3/markdown/) with curl. For example:

```sh
$ echo '{"text": "# header"}' | curl -s -H 'Content-Type: text/plain' https://api.github.com/markdown -d'@-'
```

The first half of the pipeline uses `echo` to print a JSON snippet to stdout. We
pipe this output to `curl`. The last argument `-d'@-'` is how we send the stdin
data to GitHub. From `curl`'s man page:

> -d, --data <data>
> If you start the data with the letter @, the rest should be a file name to
> read the data from, or - if you want curl to read the data from stdin.

`-s` makes `curl`'s output less noisy, and `-H` lets us pass in custom HTTP
headers required by the API.

Our script's immediate goal is to produce JSON similar to the `echo` command in
our example above. Again, we do not need an external library because `json` is
available through the standard library:

```ruby
#/usr/bin/env ruby
require "json"

markdown_file = ARGV.first
payload = { :text => File.read(markdown_file) }.to_json

puts payload
```

We can test this works as expected by executing:

```sh
$ echo "# header" > foo.md
$ ./markdown foo.md | curl -s -H 'Content-Type: text/plain' https://api.github.com/markdown -d'@-'
<h1>header</h1>
```

## Piping to other processes in Ruby

With our prepared JSON payload, our next step is to handle the pipe within our
script. Ruby's `IO.pipe` is a general way of creating a connected read and write
pipes, but for our purposes, we're interested in the higher abstraction of the
`open3` module:

```ruby
#/usr/bin/env ruby
require "json"
require "open3"

markdown_file = ARGV.first
payload = { :text => File.read(markdown_file) }.to_json

curl_cmd = %Q(curl -s -H 'Content-Type: text/plain' https://api.github.com/markdown -d'@-')

# `stdin`, `stdout`, `stderr` are the respective file handlers for the curl command
stdin, stdout, stderr = Open3.popen3(curl_cmd)

# Take the json we built and give it to curl via it's stdin. We have to
# explicitly close it's stdin before we can access it's stdout. Otherwise, curl
# will keep waiting for more input.
stdin.puts payload
stdin.close

# Print out curl's output to stdout and stderr
puts stdout.read
$stderr.puts stderr.read
```

Let's try it out:

```sh
$ echo "# header" > foo.md
$ ./markdown foo.md
<h1>header</h1>
```

## Default to processing stdin

In our last example, we had to create a markdown file because our script expects
a filename as an argument. The great thing about most Unix utilities is they
default to operating on stdin and stdout. This makes it easy to chain commands
together so that the stdout of one command flows into the stdin of the next. For
example, both of the following commands will print the number of lines in a
file:

```sh
# count the number of lines for a given filename
$ wc -l README.md

# print out the file, then count the number of the lines on stdin
$ cat README.md | wc -l
```

We can improve our markdown script with this behavior; Convert a file if a file
name is given, or convert whatever is passed in via stdin if there are no
arguments.

```ruby
#/usr/bin/env ruby
require "json"

markdown_file = ARGV.first
markdown_content = markdown_file ? File.read(markdown_file) : $stdin.read
payload = { :text => markdown_content }.to_json

# snip
```

We can simplify this code further by using Ruby's `ARGF` object. From the
docs:

> ARGF is a stream designed for use in scripts that process files given as
> command-line arguments or passed in via STDIN.

The same code rewritten with `ARGF` would look like:

```ruby
#/usr/bin/env ruby
require "json"

markdown_content = ARGF.read
payload = { :text => markdown_content }.to_json

# snip
```

As an added bonus, `ARGF` works on multiple filenames, allowing our script to
process multiple files at once:

```sh
# ARGF.read will read in all 3 files
$ ./markdown foo.md bar.md baz.md
```

## Keep stdout on topic

The complement to processing stdin by default is to keep stdout on topic. Stdout
should be reserved only for the intent of the original script. In our script,
the only output should be HTML because the script is used to convert markdown to
HTML. We avoid logging diagnostic messages or printing progress counters unless
we decide to add flags to our script that support these features. This allows us
to easily chain more commands after our own script. For example, if we want to
indent the output from our command, we can use the `tidy` command and know that
everything we output is HTML:

```sh
$ ./markdown.sh foo.md | tidy -i
```

## Exit with an appropriate code

Script exit codes allow us to control the flow of our pipelines. For example, we
may want to publish the results of running `markdown`, but only if the command
succeeded:

```sh
# Generate blog-post.html. If successful, run `./publish`, otherwise, print an error message
cat blog-post.md \
  | ./markdown > blog-post.html && ./publish || echo "failed to publish blog-post.html"
```

A successful exit is `0`, with any other number indicating something went wrong.
Unfortunately, if we ran the above, we would always publish and never see the
error message even if curl failed. Our script doesn't call `exit` explicitly, so
we always exit `0` -- even when GitHub's API isn't accessible.

Since the last thing our script run is `curl`, our script should exit with
`curl`'s exit code. Our current call to `Open3.popen3` saves three of the return
values, but the method actually returns four. We will use this fourth value to
query for `curl`'s exit code.

```ruby
# snip

# We add a -f flag so that non-200 responses fail with an exit code of 22
curl_cmd = %Q(curl -f -s -H 'Content-Type: text/plain' https://api.github.com/markdown -d'@-')

# `stdin`, `stdout`, `stderr` are the respective file handlers for the curl command
# `thread` is a `Thread` instance representing the command we're running
stdin, stdout, stderr, thread = Open3.popen3(curl_cmd)

# snip

# thread.value is a `Process::Status`. We exit our script with whatever curl's
# exit code was.
exit thread.value.exitstatus
```

## Conclusion

By following these simple conventions, our scripts work well with other existing
Unix tools. This allows us to quickly prototype things that would otherwise
require a lot of setup and dependencies. Since the scripts aim to handle a
single task, we are more likely to reuse the script for tasks that we didn't
original intend for the script to handle.

Our final source listing is:

```ruby
#/usr/bin/env ruby
require "json"
require "open3"

markdown_file = ARGV.first
payload = { :text => File.read(markdown_file) }.to_json

# Curl command to post STDIN to GitHub's markdown API
#
# -f: non-200 responses fail with an exit code of 22
# -s: silent
# -H: http headers
curl_cmd = %Q(curl -f -s -H 'Content-Type: text/plain' https://api.github.com/markdown -d'@-')

# `stdin`, `stdout`, `stderr` are the respective file handlers for the curl command
# `thread` is a `Thread` instance representing the command we're running
stdin, stdout, stderr, thread = Open3.popen3(curl_cmd)

# Take the json we built and give it to curl via it's stdin. We have to
# explicitly close it's stdin before we can access it's stdout. Otherwise, curl
# will keep waiting for more input.
stdin.puts payload
stdin.close

# Print out curl's output to stdout and stderr
puts stdout.read
$stderr.puts stderr.read

# thread.value is a `Process::Status`. We exit our script with whatever curl's
# exit code was.
exit thread.value.exitstatus
```

I use this to generate the markup for this blog. The full source is available at
[jch/jsg](https://github.com/jch/jsg).
