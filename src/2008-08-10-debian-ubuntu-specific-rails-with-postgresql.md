# Debian/Ubuntu Specific Rails with Postgresql #

I spent the weekend migrating from my shared hosting at Dreamhost over
to VPS hosting at [SilverRack](http://www.silverrack.com/).  In the
move, I setup my housing app to run on postgresql instead of mysql.  I
was in for a few surprises though.

When I ran db:migrate, I got a strange error:

     rake aborted!
     No such file or directory - /tmp/.s.PGSQL.5432

At first I thought it was because postgres wasn't started, but that
didn't make sense because I had another terminal with psql running
just fine.  If you follow the --trace message, you'll find that the
most poorly named option in database.yml will fix this problem:

     production:
       adapter: postgresql
       # ... other stuff
       host: /var/run/postgresql

The 'host' parameter is the directory Rails looks in to get the tmp
file to determine how to connect to postgres.  I guess in other *nix
systems this is conventionally in tmp, but that's not true for Debian
based distros.

After fixing that, I ran into another little problem:

    psql: FATAL:  Ident authentication failed for user "xxx"

This one comes as a result of good defaults by the Debian postgresql
configs.  A [quick google](http://semweb.weblog.ub.rug.nl/node/61)
solved this one:

    # add to pg_hba.conf, found in /etc/postgresql/...
    local    all   all   trust
    host     all   127.0.0.1  255.255.255.255    trust

For a cheatsheet of setting up a Rails project with Postgresql, check
out [this guide I wrote a while
back](/articles/2008/02/05/setup_rails_with_postgresql/).
