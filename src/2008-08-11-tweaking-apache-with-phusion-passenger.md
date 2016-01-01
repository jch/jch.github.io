# Tweaking Apache with Phusion Passenger #

Carrying over from weekend cleanup, I started exploring the different
deployment options available.  Here are some bleak notes as I go
along:

[Phusion Passenger](http://www.modrails.com/documentation.html).
Tried this one with Apache 2 and mpm-prefork instead of mpm-worker
since mpm-worker was chewing through my 256mb of ram too quickly.
Using Passenger with normal Ruby was easy enough.  It really simplied
what needed to be defined in the vhost.  Using Passenger with their
recommended 'enterprise' Ruby was simply a nightmare.  Trying to
restart Apache with PassengerRuby set to enterprise ruby's path had
load path issues.  Even after hacking up the file that was whining
with liberal amounts of load path unshifting, it still acted funny.
Also, it clutters up your system with basically a whole new branch of
ruby: gems, irb, ruby, you name it.  The last bit of annoynance was
that the deb they provide had a broken uninstaller, so I had to
manually remove /opt when I was purging it.
