# Dump Test Data from Production to Development with yaml_db#

For [Money app](http://money.whatcodecraves.com/), I ran into a
problem with the charts drawing ugly x-axis when the datapoints were
too close together.  I didn't want to reproduce the problem locally
because it would involve a lot of data entry.  So I set out to look
for some sensible solutions.

The first thing I did was look through Rail's default database Rake
tasks.  The most promising of these was 'db:schema:dump', but
unfortunately, this only dumped the database schema structure without
dumping the actual rows.  Then I remembered hearing [Adam
Wiggins](http://adam.blog.heroku.com/) talk about
[Heroku](http://heroku.com/) a few weeks back.  I remember being
impressed by his product pitch.  But more importantly, I remember
Heroku had this feature of uploading your existing data to be imported
into their database.  So I looked through Wiggin's github repo, and
sure enough,
[yaml_db](http://github.com/adamwiggins/yaml_db/tree/master) was
there.

The README is pretty self-explanatory, and it worked as advertised.  I
remember Wiggins mentioning that Heroku had problems with loading yaml
files on the order of gigabytes, but this isn't really won't be an
issue for me for a while.

I know that at Coupa, we have our own in-house solution for cloning
production instances for testing purposes.  There is a Capistrano
task for it, and it has extra logic to reset all passwords and
overwrite user emails with generated ones.  I'll look into that when I
have a need for it.
