# Platform of Choice #

I kept some rants and notes to myself a while back about what I
thought about some of the operating systems I've used and currently
use.  These notes are more about day-to-day usage from the perspective
of a software developer / power user rather than an objective review
of each platform.  I also update these pages with links to my favorite
apps and tricks I've come across.

## OSX

It just works.

I think Apple's done a great job of make a day-to-day OS for dummies.  That way,
when I want to feel like a dummy and not obsessively configure every freaking detail,
I can just make some common sense assumptions and start working.

On the other hand, I like how OS X doesn't make you hit a brick wall once you've
done the common simple cases.  If you wanted or
needed to, it's perfectly accepted to open up and Terminal and [have at
it](http://www.macosxhints.com/index.php?topic=unix).  Whether it's a simple
shell script to do some text munging, or a regularly recurring task with cron,
Apple has made it easy for *nix geeks to be productive outside the pretty Aqua
UI.

I dislike fanboys.  Everyone new to OS X should check out ["What is Mac OS
X"](http://www.kernelthread.com/mac/osx/ "What is Mac OS X") for a serious myth
debunking and very interesting history and details about OS X.

I'm learning to program with Objective-C and Cocoa, so there'll be on
more these later.

### Software ##

Since it's so easy to compile applications from *nix systems on OS X, linux
apps are readily available on OSX.  Both [Fink](http://finkproject.org/)
and [MacPorts](http://www.macports.org/) are good package management systems.

* [Namely](http://amarsagoo.info/namely/) Great light freeware launcher of
  applications.  Quicksilver is too slow on my ibook.

* [Camino](http://www.caminobrowser.org/) I used this browser for quite a
  while because of some nit-picky details I had with Safari.  It integrates
  better with OSX better than FF, but doesn't let you have extensions like FF.

* [HandBrake](http://handbrake.m0k.org/) Rip dvds to mp4, avi, or ogm.

* Terminal comes with OS X by default, but make sure you change the terminal
    type to xterm (instead of xterm-color) or else your screen sessions
    won't have a backspace.

* [SSHKeychain](http://www.sshkeychain.org/) a very well done wrapper
    around ssh-agent.  It uses apple's Keychain to store your key's
    passwords, and will auto lock your private keys on customizable events.
    Learn more about ssh in general
    [here](http://www.sshkeychain.org/mirrors/SSH-with-Keys-HOWTO/ "SSH with Keys HOWTO")

* [Parallels](http://www.parallels.com/products/desktop/) For $80, you could have
  a very sophisticated and usable VM to test against all different types of OS's.
  I have not tried VMWare on OS X yet.

## Linux

A fan boy's fantasy or salvation for corporate environments?

Sometime before high school, my dad brought home 2 O'Reilly Linux
books.  He never looked at them again after he wrapped them, but told
me that *nix was important.  This confused me since he was a Windows
admin guy.  The book was on RedHat 5.1 and I installed it on my newly
upgraded Pentium MMX 233/266Mhz machine.  I got really excited about
the philosophy and freeness the books touted.  Watching Gnome start
up, and something non-Windows on my computer was also a treat.
Fortunately for me, those early windowing apps were absolute garbage.
This forced me to the command line and made me learn how to get around
without a GUI.  I remembered my DOS days very fondly, so the
transition wasn't a big deal.  I remember having a heck of a time
getting a floppy to mount in Linux.  I had to ask Sean's dad (a
Berkeley professor!) because it was so frustrating.  Man pages aren't
designed for impaitient noobs.  RedHat was a gateway drug for me.  I
moved on to try several different distributions.  At the time, I tried
them haphazardly and didn't really know what I was looking for.  I
judged each distribution by how hard it was to install and how easy it
was to get software loaded on it.  The RH book totally lied about
RPMs.  I tried Slackware and enjoyed the packaging system much more than
RPMs.  When I volunteered for the ACCRC refurbishing computers for
nonprofits, I installed Suse 7 on those machines.  After I tried
Debian Potato, I was pretty hooked.  Woody was even more amazing
(fresher packages).  Even today, after Ubuntu has redefined ease of
use, I continue to use Debian because I see no reason to switch.

### Applications ###

* [pork](http://dev.ojnk.net/) - the best aim/irc client, ever.
* [gnu screen](http://www.gnu.org/software/screen/) - an absolute must if you use ssh.
    It's not impressive until you customize your .screenrc
    Usually it's nice to have screen running to keep your ssh sessions alive as well.
    If you're unlucky and have your screen killed, then you get a message:
    _Suddenly the Dungeon collapses!! - You die..._


## DOS

Instant bootup, instant shutdown, excellent throughput, zero hassle, what's not to like?

> *640K ought to be enough for anybody - incorrected attributed to Bill Gates*

DOS was an easy to love operating system.  Any negative brought up against DOS
can be "scoped out".  I didn't miss multitasking; It had [graphics and
sound](http://en.wikipedia.org/wiki/The_Lost_Vikings "The Lost Vikings");

I plan to explore more with [FreeDos](http://www.freedos.org/) when I set up my VMs

### Pros
* instant bootup/shutdown.  Unrivaled by anything available today.  It's even
  faster than my stupid cell phone.
* minimal set of commands.  It was very easy to remember them and use.

### Cons
* setting up extended memory was hard :(
* I wish the commands and options were more *nix like.
* instant shutdown is a double edged sword

## Windows

Good to you if you don't know any better.

After I put debian on my desktop computer and bought an ibook for a
laptop. I stopped using windows completely.  The NT family of OS's
were solid, and I never really had any problems with XP.  On the other
hand, I didn't have any problems because I was very careful with what
I did on that computer.  I haven't kept up with Vista at all.
