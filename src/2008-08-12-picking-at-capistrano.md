# Picking at Capistrano #

Here is the setup I wanted with [Capistrano](http://www.capify.org/)
with my [housing app](http://housing.whatcodecraves.com/).  I wanted
to develop locally and continue using Subversion over SSH for source
control.  Meanwhile, Cap would run svn commands remotely with
basic svnserve.  My first configuration looked like this:

    set :repository, "file:///var/svn/#{application}/trunk"
    set :user, "myuser"

My reasoning was that cap would first ssh to my server, and then run

    svn checkout file:///var/svn/housing/trunk /path/to/deploy

Since I use a private key to authenticate to my server, I wouldn't
need to type my password to start the initial ssh connection, and cap
wouldn't need a password to access the repository because it would
execute commands on the remote server with "file:///"

It turns out that SCM commands are run locally rather than remotely.
The implication is that my ":repository" variable has to be accessible
both locally and remotely.  With ":repository" set to "file:///" cap
tried to determine the revision number by running 'svn info' locally.
Of course, this failed miserably because the repository existed on the
remote server.

Once I figured this out, I thought it'd be a simple matter of changing
the config to say:

    set :repository, "svn+ssh://whatcodecraves.com/var/svn/#{application}/trunk"

Now cap will happily run svn locally because it'll work over
"svn+ssh://".  Unfortunately, this also had a huge flaw.  When cap
tries to run the checkout command remotely, it'll use "svn+ssh://".
But because my private key isn't stored on the server, cap will give
three feeble attempts before croaking:

    ** [208.53.44.43 :: err] Permission denied, please try again.
    ** [208.53.44.43 :: err] Permission denied, please try again.
    ** [208.53.44.43 :: err] Permission denied (publickey,password).
    ** [208.53.44.43 :: err] svn: Connection closed unexpectedly

What's weird about this is that I didn't ask cap to use public key
authentication, but it didn't give me any choice in the matter!
Crawling the internet yielded a lot of noise about poorly configured
repositories or basic explanations about public key authentication.
Finally, I came across [a
response](http://groups.google.com/group/capistrano/browse_thread/thread/13b029f75b61c09d/3746185353022cc7?lnk=gst&q=Permission+denied+\(publickey%2Cpassword\)#3746185353022cc7)
in Capistrano's google group.  The fix is damn short:

     default_run_options[:pty] = true

I looked up what a [pseudo
terminal](http://en.wikipedia.org/wiki/Pseudo_terminal).  I don't
really see why this provides a fix, but my guess is that setting pty
to true creates a new process separate from the original ssh process.
Running svn within this new process would default to password
authentication after failing to use public key authentication.

This turned out to be an amazing pain to setup.  But it did let me
step through some of the Capistrano code and appreciate what goes on
under the hood.  It also teaches me to search their [google
group](http://groups.google.com/group/capistrano) rather than doing a
general web search.
