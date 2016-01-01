# OS X GUI Tool 'HTTP Client' #

Kyle sent out this [amazing tool](http://ditchnet.org/httpclient/) for
testing and debugging at the HTTP level.  This would've been a
lifesaver a few weeks ago when I was working on RESTful API stuff for
work, but better late than never.

<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
width="437" height="315" id="viddler"><param name="movie"
value="http://www.viddler.com/player/9f577b3/" /><param
name="allowScriptAccess" value="always" /><param
name="allowFullScreen" value="true" /><param name="wmode"
value="transparent"/><embed
src="http://www.viddler.com/player/9f577b3/" width="437" height="315"
type="application/x-shockwave-flash" allowScriptAccess="always"
allowFullScreen="true" wmode="transparent" name="viddler" ></embed></object>

The idea of the app is amazingly simple.  It lets you specify the type
of http request you want to make, the header options, and the body.
The beauty of doing it in a GUI instead of from the command line with
curl is that there are dropdowns for the hard to remember header
options, and that you can paste fat hunks of XML into the body field.
It's also awesome because you can open multiple windows and have each
of those be a re-runnable http client.

HTTP Client is 99% perfect app for my uses.  The single feature that
would push it to being a perfect app would be a cookie-jar so that
sessions can be saved.
