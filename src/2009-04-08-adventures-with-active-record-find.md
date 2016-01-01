# Adventures with ActiveRecord find #

Retrieving records from the database and mapping the results into
ActiveRecord models are a big part of every Rails app.  A large
majority of your controllers will retrieve one or more ActiveRecord
models.  For something as important and fundamental as 'find', knowing
more of it's options and idioms can help you write less, write it more
elegantly, and do more.

For starters, let's look at the basic form.

    Fruit.find(1)  # single integer id
    Fruit.find(params[:id])  # single string id
    Fruit.find(@user1, @user2)  # by list
    Fruit.find([@user1, @user2]) # by array

This is how you find a record given an id.  When you search like this,
it will raise
[ActiveRecord::RecordNotFound](http://api.rubyonrails.org/classes/ActiveRecord/RecordNotFound.html)
if no record can be found.  This exception is what causes the 404 page
to load in your controllers when you hit a URL for a record that
doesn't exist.  You can emulate this by explicitly raising
RecordNotFound if you don't want a user to access a certain record.

    @banana = Fruit.find(5)

    # pretend that no record was found and show a 404 page.
    if @banana.rotten?
      raise ActiveRecord::RecordNotFound.new
    end

## First, Last, All ##

    Fruit.find(:first)
    Fruit.first
    Fruit.find(:last)
    Fruit.last
    Fruit.find(:all)
    Fruit.all

These methods do what you expect them to.  I prefer using the shortcut
methods 'all', 'first' and 'last', rather than explicitly saying
Fruit.find(:first).  The order for :first and :last is the 'id' of the
table.  Think of 'first' as the first inserted record, and 'last' as
the most recently inserted record.

Something I would like to see more people using is the shortcuts in
conjunction with find's arguments.  Instead of:

    Fruit.find(:all, :conditions => { :color => 'yellow' })

I prefer the shorter:

    Fruit.all(:conditions => { :color => 'yellow' })

This works with all 3 shortcut methods.  It also works with all of the
options that the normal find method accepts.

## Conditions ##

Conditions are what get translated into the WHERE clause in the SQL
statement.  There are 3 different way to specify your conditions: the
String form, the Array form, and the Hash form.

### String Conditions ###

The string form is easy to understand and is useful for querying
specific known values.

    Fruit.all(:conditions => "name = 'banana' OR name = 'apple'")

**DO NOT** use the string form for tainted values that come in from
submitted web forms.  The String form does not escape values for you
and can cause SQL injection attacks if you aren't careful.  For example:

    # DO NOT do this!
    Fruit.first(:conditions => "name = '#{params[:name]}')

While this may look harmless at first, there's no guarantee that
params[:name] is a safe value.  It could very well have the value

    # dangerous params[:name] value
    '; DROP TABLE fruits;

When you interpolate that value into the condition string, you end up
dropping all your delicious fruits!  When you need to do a find based
on unsafe web input, use the Array and Hash forms instead.  Both of
these will escape and quote the values properly.

### Array Conditions ###

Using the same example, we could write that last dangerous query as:

    Fruit.first(:conditions => ["name IN (?) OR color = ?", params[:keywords], params[:color]])

This works, but gets kind of ugly when you have a lot of values to
interpolate.  To make it more readable, you can name your
interpolations in a hash instead of using '?'.

    Fruit.all(:conditions => [
      "name IN (:keywords) OR color = :color",
      {
        :keywords => params[:keywords],
        :color    => params[:color]
      }
    ])

Finally, we come to my favorite and most used form of condition.

### Hash Conditions ###

I find this style to be the most readable for equality and SQL IN
conditions.  It keeps the column name close to the value being
queried.  If the value is an Array, then ActiveRecord knows to use the
SQL IN operator.

    Fruit.all(:conditions => {
      :name  => params[:keywords],  # SQL - name IN ('banana', 'apple')
      :color => params[:color]      # SQL - color = 'yellow'
    })

If you use :joins or :include to pull in associations, you can still
use the Hash form to do equality comparisons.  For example:

    Fruit.all(:include => [ :company ], :conditions => {
      "company.name"  => params[:company_name],
      "company.phone" => params[:phone],
      :color          => params[:color]
    })

In general, I like using the String form to do short hardcoded SQL
queries like "aroma IS NULL".  The Hash form is ideal for conditions
that only use the equality operator.  The Array form is the most
general purpose; I try to use the named arguments version when using
the Array form.

## Associations ##

You can use the :include or :joins to pull in a model's associations
if you want to use them in the find's :conditions, or if you want them
to be [eager
loaded](http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html)
in the results.  :include uses 'LEFT OUTER JOIN' and :joins uses
'INNER JOIN'.  Both forms can take a raw SQL string, or symbols for
what associations to follow.

    # fruits LEFT OUTER JOIN companies ON companies.id = fruits.company_id
    Fruit.all(:include => [ :company ])

    # fruits INNER JOIN companies ON companies.id = fruits.company_id
    Fruit.all(:joins => [ :company ])

You can follow associations arbitrarily deep:

    # fruits LEFT OUTER JOIN companies ON companies.id = fruits.company_id LEFT OUTER JOIN employees ON employees.company_id = company.id LEFT OUTER JOIN profiles.employee_id = employees.id
    Fruit.all(:include => [ { :company => { :employees => :profiles } } ])

Multiple associations work too:

    Fruit.all(:include => [ :company, :farm ])

For more examples, [google 'rails eager
loading'](http://www.google.com/search?q=rails+eager+loading), and
read up about [Rails Eager
Loading](http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html).
Use :joins when an inner join is sufficient.  This will give you
faster queries, and cleaner log output.

## Making Results Things Unique ##

When you do multiple joins or includes, you may end up with duplicates
in the results.  Rather than removing the duplicates in code, let
ActiveRecord handle it.

    Fruit.all(:select => "DISTINCT fruits.*", ...)

## Mapping Fewer Columns ##

By default, all selects will select all columns (SELECT * FROM ...).
If you know ahead of time that you'll only be using a few specific
columns, specify them with :select and large queries will feel
noticeably faster.

    @banana = Fruit.first(:select => 'id, name')
    @banana.id    # ok
    @banana.name  # ok
    @banana.color # raise ActiveRecord::MissingAttributeError

This is especially useful when writing data migrations that only need
to modify a specific column's data.  Make sure you include 'id'
because it's not included by default.

## Named Scopes ##

[named_scope](http://api.rubyonrails.org/classes/ActiveRecord/NamedScope/ClassMethods.html#M002120)
is great.  Everything you learn about 'find' applies to named_scope.
It's a great way to compose complex queries.

## It's like eating your vegetables... ##

Grokking the various ways to retrieve database rows and control how
they are mapped into models by your ORM will make you a stronger
developer regardless of what framework you're using.  There'll be less
code to maintain, and that code will be both readable and concise.
Spend an afternoon and read the documentation for find, eager loading,
and named_scope.  I promise that even if you've been doing Rails for a
while, you'll pick up on an option or a style that you hadn't seen
before.
