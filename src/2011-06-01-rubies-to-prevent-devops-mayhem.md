# Rubies to Prevent Devops Mayhem

<div style='margin-top: 10px;'>
  <center>
    <object width="560" height="349">
      <param name="movie" value="http://www.youtube.com/v/vtP-S9OS0o0?fs=1&amp;hl=en_US"></param>
      <param name="allowFullScreen" value="true"></param>
      <param name="allowscriptaccess" value="always"></param>
      <embed src="http://www.youtube.com/v/vtP-S9OS0o0?fs=1&amp;hl=en_US" type="application/x-shockwave-flash" width="560" height="349" allowscriptaccess="always" allowfullscreen="true"></embed>
    </object>
  </center>
</div>

You've just written a masterpiece of a web app. It's fun, it's viral,
and it's useful. It's clearly going to be "Sliced Bread 2.0". But what
comes next is a series of unforeseen headaches. You'll outgrow your
shared hosting and need to get on cloud services. A late night hack
session will leave you sleep deprived, and you'll accidentally drop
your production database instead of your staging database. Once you
serve up a handful of error pages, your praise-singing users will
leave you faster than it takes to start a flamewar in #offrails. But
wait! Just as Ruby helped you build your killer app, Ruby can also
help you manage your infrastructure as your app grows. Read on for a
list of useful gems every webapp should have.

### Backups

When you make a coding mistake, you can revert to a good known
commit. But when disaster wrecks havoc with your data, you better have
an offsite backup ready to minimize your losses. Enter the [backups
gem](https://github.com/meskyanichi/backup/), a DSL for describing
your different data stores and offsite storage locations. Once you
specify what data stores you use in your application (MySQL,
PostgreSQL, Mongo, Redis, and more), and where you want to store it
(rsync, S3, CloudFiles), Backup will dump and store your backups. You
can specify how many backups you'd like to keep in rotation, and
there's various extras like gzip compression, and notifiers for when
backups are created or failed to create.

### Cron Jobs

Having backups configured doesn't make you any less absent minded
about running your backups. The first remedy that jumps to mind is
editing your crontab. But man, it's hard to remember the format on
that sucker. If only there was a Ruby wrapper around
cron... Fortunately there is! Thanks to the [whenever
gem](https://github.com/javan/whenever), you can define repetitious
tasks in a Ruby script.

### Cloud Services

With the number of cloud services available today, it's becoming more
common to have your entire infrastructure hosted in the cloud. Many of
these services offer API's to help you tailor and control your
environments programmatically.  Having API's is great, but it's tough
to keep them all in your head.

The [fog gem](https://github.com/geemus/fog) is the one API to rule
them all.  It provides a consistent interface to several cloud
services. There are specific adapters for each cloud service. By
following the Fog interface, it makes it really easy to switch between
different cloud services. Say you were using Amazon's S3, but wanted
to switch to Rackspace's CloudFiles. If you use Fog, it's as simple as
replacing your credentials and changing the service name. You can
create real cloud servers, or create mock ones for testing. Even if
you don't use any cloud services, fog has adapters for non-cloud
servers and filesystems.

### Exception Handling

[Hoptoad](http://hoptoadapp.com/pages/home) is a household name in the
Ruby community. It catches exceptions created by your app, and sends
them into a pretty web interface and other notifications. If you can't
use Hoptoad because of a firewall, check out the self-hostable
[Errbit](https://github.com/relevance/errbit).

### Monitoring

When your infrastructure isn't running smoothly, it better be raising
all kinds of alarms and sirens to get someone to fix it. Two popular
monitoring solutions are [God](http://god.rubyforge.org/), and
[Monit](https://github.com/k33l0r/monit). God lets you configure which
services you want to monitor in Ruby, and the Monit gem gives you an
interface to query services you have registered with
[Monit](http://mmonit.com/monit/). If you have a Ruby script that
you'd like to have running like a traditional Unix daemon, check out
the [daemons gem](http://daemons.rubyforge.org/). It wraps around your
existing Ruby script and gives you a 'start', 'stop', 'restart'
command line interface that makes it easier to monitor. Don't forget
to monitor your background services, it sucks to have all your users
find your broken server before you do.

### Staging

Your application is happily running in production, but all of a
sudden, it decides to implode on itself for a specific user when they
update their avatar. Try as you might, you just can't reproduce the
bug locally. You could do some cowboy debugging on production, but
you'll end up dropping your entire database on accident. Oops.

It's times like these that you'll be thankful you have a staging
environment setup. If you use capistrano, make sure to check out how
to use capistrano-ext gem, and its [multi-stage deploy
functionality](http://weblog.jamisbuck.org/2007/7/23/capistrano-multistage).
To reproduce your bug on the same data, you can use the [taps
gem](https://github.com/ricardochimal/taps) to transfer your data from
your production database to your staging database. If you're using
Heroku [then it's already
built-in](http://devcenter.heroku.com/articles/taps).

Before you start testing your mailers on staging, do all of your users
a favor and install the [mail_safe
gem](https://github.com/myronmarston/mail_safe). It stubs out
ActionMailer so that your users don't get your testing spam. It also
lets you send emails to your own email address for testing.

### CLI Tools

[Thor](https://github.com/wycats/thor) is a good foundation for
writing CLI utilities in Ruby. It has interfaces for manipulating
files and directories, parsing command line options, and manipulating
processes.

### Deployment

[Capistrano](https://github.com/capistrano/capistrano) helps you
deploy your application, and
[Chef](http://wiki.opscode.com/display/chef/Home) configures and
deploys your servers and services. If you use
[Vagrant](http://vagrantup.com/) for managing development virtual
machines, you can reuse your Chef cookbooks for production.

## Conclusion

All of these gems help us maintain our application infrastructure in a
robust way. It frees us from running one-off scripts and hacks in
production and gives us a repeatable process for managing everything
our app runs on. And on top of all the awesome functionality these
tools provide, we can also write Ruby to interact with them and
version control them alongside our code. So for your next killer
webapp, don't forget to add some killer devops to go along with it.

