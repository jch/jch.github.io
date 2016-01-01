# PROJECT README, Y U NO HAVE?

Pick any popular open source library. It'll have more documentation than your
application code - I guarantee it. Test and documentation are both
acknowledged as good development practices. But unlike testing, documentation
doesn't get the same love from developers. For code that isn't intended for a
public audience, developers keep all the docs in their head, or assume that
their code is self documenting. Additionally, the tests become a kind of
runnable documentation. But there's several lessons we can apply to our
private application code from open source documentation. Today, we'll start
the conversation with the lowest hanging fruits - the README.

<img src='http://f.cl.ly/items/1z3W1o0q402Z141q2w2X/11516945.jpg' style="float:right; margin-left: 1em" />

Pick any popular open source library. It'll have more documentation than your
application code - I guarantee it. Test and documentation are both
acknowledged as good development practices. But unlike testing, documentation
doesn't get the same love from developers. For code that isn't intended for a
public audience, developers keep all the docs in their head, or assume that
their code is self documenting. Additionally, the tests become a kind of
runnable documentation. But there's several lessons we can apply to our
private application code from open source documentation. Today, we'll start
the conversation with the lowest hanging fruits - the README.

The lack of a good README is one of my major pet peeves. When starting on a
new project, more often than not, I'll find myself staring at this README:

    == Welcome to Rails

    Rails is a web-application framework that includes everything needed to
    create database-backed web applications according to the
    Model-View-Control pattern.

That's a fantastic README introduction... for the Rails framework. But it also
happens to be the default scaffold README for every new Rails project. Think
of a README as a first impression of your project. Just like open source
projects, your README should introduce the project the new developers.

Take 5 minutes of your time to write a README that explains the following
things:

**What is it?**

A short elevator pitch about your application. Examples:

  * [Travis](https://github.com/travis-ci/travis-ci/blob/master/README.textile)
    is an attempt to create an open-source, distributed build system for the
    Ruby community that allows open-source projects to register their
    repository and have their test-suites run on demand...
  * [YARD](http://rubydoc.info/docs/yard/frames/file/README.md) is a
    documentation generation tool for the Ruby programming language. It
    enables the user to generate consistent, usable documentation that can be
    exported to a number of formats very easily, and also supports extending
    for custom Ruby constructs such as custom class level definitions.
  * [Spree](https://github.com/spree/spree) is a complete open source commerce
    solution for Ruby on Rails. It was originally developed by Sean Schofield
    and is now maintained by a dedicated core team. You can find out more
    about by visiting the Spree e-commerce project page.

**How do I set it up?**

List any dependencies your project has, both libraries it depends on, as well
as external services it uses. Also remember to include any commands to start
required services. Example:

    Development Setup

    # install redis, mysql
    brew install redis
    brew install mysql

    # install rvm: http://beginrescueend.com/rvm/install/

    # within the project directory
    bundle
    rake db:setup
    foreman start
    # visit: http://localhost:3000

**Project Workflow and Tips**

Usually, I like to add an additional section for developers to add tips and
tricks that help with their day to day workflow. The notes listed in this
section are optional and individual developers can choose to use them or not.

**Seed and Test Data**

Often times, existing developers and stakeholders will have their environments configured
and won't remember what seed data the system assumes to exist. Versioning a gzip dump
of the test data is perfect for someone to come along and get a sense of what the
app data looks like.

**Who do I contact for help?**

If the project is a client project, it's good to list the stakeholders and
their roles. It's also a good place to put down the names and contact
information for members who may have worked on the project in the past.

**Relevant links**

A list of links to other sources of documentation or project management tools.

* bug tracker
* comps, wireframes, and design prototypes
* wikis
* staging, qa environments
* other servers

Having a good README can help you onboard developers faster and have a single
starting point for your project. It's easy and fast to write, so go forth and
write yours today!