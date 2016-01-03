# Useful Libraries: Rake::Pipeline and Spade

*Republished from [Opperator blog](http://blog.opperator.com)*

In doing research for whether Ember.js would be a good fit for Opperator, I
took some notes about the process.  I came across two useful libraries used in Ember.js that I hadn't heard of
before.
[Rake::Pipeline](http://rubydoc.info/github/livingsocial/rake-pipeline/master/file/README.yard)
helps package code assets together, and
[spade](https://github.com/charlesjolley/spade) is a Javascript dependency
manager. Here's a quick overview of what they do, and how you can use them in your project.

## Rake::Pipeline

From the Rake::Pipeline docs:

> Rake::Pipeline is a system for packaging assets for deployment to
> the web. It uses Rake under the hood for dependency management and
> updating output files based on input changes.

Think of Rake::Pipeline as a lighter and simpler Sprockets. It allows you to
declaratively match filenames with regexps, and then run those matched files
through custom filter classes. Here's an easy example of how to concatenate
all files that end in .js, and then slap a license on the top

    # Assetfile
    input  "app/assets/javascripts"
    output "public/javascripts"

    class LicenseFilter < Filter
      LICENSE = File.read('LICENSE')

      def generate_output(inputs, output)
        output.write LICENSE
        output.write "\n"
        output.write inputs.map(&:read).join("\n")
      end
    end

    match "*.js" do
      filter Rake::Pipeline::ConcatFilter, "application.js"
      filter LicenseFilter
    end

First you declare where you want your base input and output directory paths
should be. The `input` directory will be where files will be matched up
against. Next we define our own custom LicenseFilter, which is used to prefix
input files with the contents of our LICENSE file. As you can guess from the
arguments of the `generate_output` method, each element in the `inputs` array
is an `IO` object that you can read from, and `output` is the destination of
what you're writing.

Finally, we use the `match` block to specify that we want all files that end
in .js to be run through the `Rake::Pipeline::ConcatFilter` and output to
`public/application.js`. Then we run our `LicenseFilter` against the final
file to prefix our license.

## Spade

Spade is a package manager and file loader that reminds me of
[NPM](http://npmjs.org/). The goal of the library is to be able to package and
require modules that can be run in a terminal and also in the browser. The
browser part is obvious, but being able to run from the terminal is quite
useful. For example, you can have an npm-like module named 'awesome-module', and from a terminal do:

    spade preview  # opens in a browser with your module loaded
    spade console  # start interactive repl
    > require('awesome-module/main)

Alongside with [spade-qunit](https://github.com/tomdale/spade-qunit), you can
easily separate a library into a bunch of packages, test them separately, and
view the results in a browser.

