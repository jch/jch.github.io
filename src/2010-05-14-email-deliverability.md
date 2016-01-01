# Email Delivery for Webapps #

Delivering email is easy.  Having that email actually get received is
freaking hard.  In this era rife with spammers, if you don't jump
through several hoops of verifying yourself, your messages will be
automatically marked as spam during transit, and never see the light
of an inbox.  I didn't realize how tricky this was when I first
started sending out email for [Outspokes](http://outspokes.com), but
when our account activation and notification emails were always being
delivered to the spam folder, I dug deeper and learned quite a lot.
Follow the jump to save your future emails.

## The Right Way ##

Before I share my personal experiences, I want to point out that the
fastest and most sensible way to guarantee good email deliverability
is to have someone else do it for you.  Rather than setting up your
own mail server and coming up with a solution that you have to
maintain yourself, there are smart dedicated teams working on this
problem on your behalf.  The cost of entry is so low that they're all
effectively free until the volume of you email you need is large
enough that you should generate enough revenue to cover the cost.
I'll cover a few hosted services like
[Sendgrid](http://sendgrid.com/), and
[Postmark](http://postmarkapp.com/) in a separate blog post.

## Setting it Up Yourself ##

Now that I've warned you of the easier path, here's the steps I took
to make sure our emails were actually delivered rather than canned
outright.

### Reverse DNS Points to your Hostname ###

This is important when you're using a hosted environment.  Outspokes
uses [Rackspace](http://www.rackspace.com/), and the initial reverse
lookup of our IP address yielded a very spam-like looking domain:

    67-23-23-207.static.slicehost.net

From the control panel, I changed this value to a more sane-looking
'outspokes.com'.  To see what your current reverse dns entry is:

    dig -x 67.23.23.207    # your static IP address

    # other useful commands
    dig outspokes.com ANY  # show all DNS records for outspokes.com
    dig @ns1.editdns.net outspokes.com  # ask editdns for outspokes records

### Setup DNS SPF Record ###

SPF stands for [Sender Policy
Framework](http://en.wikipedia.org/wiki/Sender_Policy_Framework), and
is a DNS record that can be looked up to determine what servers are
allowed to send email for a given hostname.  For example, for
Outspokes, I only wanted the server with the static IP 67.23.23.207 to
be able to send email.  If a spam server tries to send email with a
'from address' of outspokes.com from a non-verified server, then that
email will be marked as spam and rightfully zapped from existence.

In your DNS, add a TXT record:

    v=spf1 a mx ~all

This allow servers listed in A and MX records to send email.  Some DNS
services don't support adding TXT records, so your mileage may vary
for getting this setup.

###  Setup DKIM ###

DKIM stands for [DomainKeys](http://en.wikipedia.org/wiki/DomainKeys),
and works similar in concept to SPF.  I followed a guide from the
[Ubuntu forums](https://help.ubuntu.com/community/Postfix/DKIM) to get
it setup.

    aptitude install dkim-filter
    generate rsa keypair, put in /etc/ssl/private/dkim/private.key
    edit dns add TXT record with public key
    edit /etc/dkim-filter.conf, /etc/default/dkim-filter
    edit /etc/postfix/main.cf - add smtpd milter (mail filter)
    /etc/init.d/dkim-filter start
    /etc/init.d/postfix restart


### Debugging and Testing Your Configuration ###

If you've followed this guide blindly up until this point.  Chances
are good that you're emails are still getting spammed-out.  Luckily,
there are tools that help you diagnose whether all these new changes
are actually making a positive effect.

One great way to test is to pretend that you're a mail client sending
an email and telneting to the mail server directly.  I learned this
from a [Slicehost
tutorial](http://articles.slicehost.com/2008/8/6/postfix-using-telnet-to-test-postfix).

    # I ran this directly from the mail server b/c of firewall rules
    telnet localhost 25
    HELO localhost
    MAIL FROM: jerry@outspokes.com
    RCPT TO: check-auth@verifier.port25.com
    DATA
    Subject: test
    body text
    .
    QUIT

Now you can email anyone you'd like for testing, but it's much more
helpful to email check-auth@verifier.port25.com, or
auth-results@verifier.port25.com.  These two emails will check your
mail headers against your DNS records and give you a rating of how
likely your emails will be marked as spam.  The report will be sent to
the 'MAIL FROM' field.

### Additional Improvements ###

Now that you have a good baseline setup for your emails to be
delivered, it's time to take a breather and marvel at how your
messages actually make it past spam filters.  But spammers are
constantly improving their game, so having a baseline setup far from
guarantees that your emails will be safe forever.  Here are some
additional tips that may mark your message as suspicious.

Send multipart email instead of only HTML email: send an HTML version
that includes your pretty graphics, but also send a plain text version
that gets the same point across.

Shrink size of images in message - large image implies spam.

Use a real email address instead of noreply@yourdomain.com - By real
address, I mean an address that can be delivered to.  This could be
admin@outspokes.com, or support@outspokes.com.

### Resources ###

Quick listing of links that I read:

* [Reverse DNS](http://www.corvidworks.com/articles/mail-deliverability-tip)
* [SPF](http://www.kitterman.com/spf/validate.html)
* [DKIM Proxy usage](http://dkimproxy.sourceforge.net/usage.html)
* [Postfix with DKIM on Ubuntu via serverfault.com](http://serverfault.com/questions/52393/postfix-with-dkim-on-ubuntu)
* [DKIM and DomainKeys with DKIM Proxy on Ubuntu Hardy](http://www.pocketsmith.com/blog/2009/07/05/setting-up-dkim-and-domainkeys-using-dkimproxy-with-postfix-in-ubuntu-hardy/)
* [Testing DKIM](http://www.sendmail.org/dkim/testChecker)

### Conclusion ###

Like I said before, I strongly believe that the right thing to do for
email deliverability is to have someone dedicated handling it.  For
small teams with limited resources, this means going with an external
hosted SMTP service.  On the other hand, if you're curious about how
email works, setting up your own mail server and going through the
setup for ensuring the messages get delivered can teach you the
fundamentals of how email work and also a lot of practical tools to go
along with it.

