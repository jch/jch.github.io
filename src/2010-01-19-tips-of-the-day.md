# Tips of the Day #

* debugging django SQL problems
* documenting convention for Rails routes


## Debugging Django SQL problems ##

You can install [Django debug toolbar
middleware](http://github.com/robhudson/django-debug-toolbar), or you
can set a breakpoint and inspect queries that have been run on the
current database connection:

    from django import db
    db.connection.queries[0]['sql']

'queries' is an array of dicts.  The useful keys on the dict are 'sql'
and 'raw_sql'.

## Documenting Convention for Rails Routes ##

I started a mini-hackathon for a [beer review
app](http://beerpad.heroku.com) I've wanted to write for a while.
While I was scaffolding, I thought it'd be useful to document the
routes inline with their controller:

    class ReviewsController < ApplicationController
      # beer_reviews(@beer) => GET /beers/:beer_id/reviews
      def index
      end

      # new_beer_review(@beer) => GET /beers/:beer_id/reviews/new
      # new_review             => GET /reviews/new
      def new
      end

      # beer_reviews(@beer) => POST /beers/:beer_id/reviews
      # reviews             => POST /beers/reviews
      def create
      end
    end

The benefit is that for any given controller you can always add
'_path' or '_url' to the end of the comment without having to run rake
routes and grepping for the controller/action pair.  This convention
also lets you see every possible way of accessing a given action
instead of only the basic method.
