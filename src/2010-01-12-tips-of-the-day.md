# Tips of the Day #

* dumping and restoring databases from RDS
* connecting to Twitter via oauth using python
* python debugger in Django

## Backup and Restore to RDS ##

Backup:

    mysqldump -h dev-rds.customdomain.com -u root -psecret database_name table_name  | gzip > backup.sql.gz

table_name is optional, and you can pass a -9 to gzip to maximize compression

Restore:

    gunzip < backup.sql.gz | mysql -h dev-rds.customdomain.com -u root -psecret database_name

## Python Twitter OAuth ##

[Download sample code](/files/python_twitter_oauth_sample.zip)

[Grab oauth
library](http://oauth.googlecode.com/svn/code/python/oauth/oauth.py),
and drop it on your python path.  Don't use the egg because there are
problems with it.

If you're using cookie based sessions and developing locally, make
sure your callback url is consistent with your local dev url.  I had
the callback url set to http://127.0.0.1/twitter_callback, but I was
accessing the application via http://localhost:8000/, so the cookies
weren't being set properly.  The fix was to access the app from
http://127.0.0.1:8000/ instead.

## Python Debugger in Django ##

    import pdb; pdb.set_trace()

Equivalent of 'import ruby-debug; debugger' in ruby.
