# Setup Rails with Postgresql #

Everytime I set up a Rails project, there are many braindead steps
that need to be followed.  Instead of doing a web search each time I
need to get an app setup, I follow these simple sequence of
instructions.

The first thing to do is to create the rails directory structure.
Many Rails tutorials assume SQLite or MySQL.  Here in ivy covered UC
Berkeley, our database of choice is Postgresql.

    rails --database=postgresql myapp

## Postgresql ##

    (as postgres admin user)
    psql template1

    create role myapp with createdb login password 'myapp';  // 'login' is optional if you plan to use psql
    // with newer versions of Rails, 'rake db:create:all' will create all the databases listed in config/database.yml
    select * from pg_user;    // verify user created
    select * from pg_shadow;  // sysid listed here
    create database myapp_development owner myapp;
    create database myapp_test owner myapp;
    create database myapp_production owner myapp;

    (in RAILS_ROOT)
    rake db:migrate

If rake complains that it can't load the file 'postgres', then you are
missing the postgresql database adapter.  You can get it via:

    sudo gem install pg

If that fails, read the [wiki
page](http://wiki.rubyonrails.org/rails/pages/PostgreSQL) about it.
For the lazy, you can simply install the slower pure ruby adapter
'postgres-pr'

The 'postgres' gem is
[unmaintained](http://archives.postgresql.org/pgsql-interfaces/2007-12/msg00001.php),
and a new [fork of the project 'pg'](http://rubyforge.org/projects/ruby-pg).

## Config ##

Keep your database.yml
[DRY](http://blog.bleything.net/2006/06/27/dry-out-your-database-yml).
Edit database.yml as follows:

    common: &common
      adapter: postgresql
      username: myapp
      password: password # from psql setup, see Postgresql

    development:
      <<: *common
      database: myapp_development

    test:
      <<: *common
      database: myapp_test

    production:
      <<: *common
      database: myapp_production


## Subversion ##

The following keeps your repository squeaky clean:

    mv myapp myapp-tmp
    mkdir -p myapp/{branches,tags}
    mv myapp-tmp myapp/trunk
    cd myapp/trunk
    rm -rf log/* tmp/*
    mv config/database{,-example}.yml
    svn ps svn:ignore '*' log
    svn ps svn:ignore '*' tmp
    svn ps svn:ignore 'database.yml' config

## Updating Stuff ##

To update rails, do

    sudo gem install -y rails
