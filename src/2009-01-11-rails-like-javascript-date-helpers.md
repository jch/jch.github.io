# Rails-like Javascript Date Helpers #

I'm a fan of
[ActiveSupport::CoreExtensions::Time::Calculations](http://api.rubyonrails.org/classes/ActiveSupport/CoreExtensions/Time/Calculations.html).
It gives you easy to use methods like <code>beginning_of_day</code>,
<code>end_of_day</code>, <code>beginning_of_week</code>,
<code>end_of_day</code>, etc.  These methods make date handling code
more concise and more readable.  I wanted the same benefits in
Javascript, so I've ported over a subset of these methods and mixed
them into Javascript's <code>Date</code> object.  Read on for the
code.

Here are a few examples of what you can do with these date extensions:

    // Mon Jan 12 2009 13:30:00 GMT-0800 (PST)
    var monday = new Date(2009, 0, 12, 13, 30, 0);

    // Wed Jan 14 2009 13:30:00 GMT-0800 (PST)
    var wednesday = new Date(2009, 0, 14, 13, 30, 0);

    // Fri Jan 16 2009 13:30:00 GMT-0800 (PST)
    var friday = new Date(2009, 0, 16, 13, 30, 0);

    wednesday.between(monday, friday);  // true

    wednesday.beginningOfDay(); // Wed Jan 14 2009 00:00:00 GMT-0800 (PST)
    wednesday.endOfDay(); // Wed Jan 14 2009 23:59:59 GMT-0800 (PST)

    wednesday.beginningOfWeek(); // Sun Jan 11 2009 00:00:00 GMT-0800 (PST)
    wednesday.endOfWeek(); // Sat Jan 17 2009 23:59:59 GMT-0800 (PST)

    wednesday.beginningOfMont(); // Thu Jan 01 2009 00:00:00 GMT-0800 (PST)
    wednesday.endOfMonth(); // Sat Jan 31 2009 23:59:59 GMT-0800 (PST)

Here's the code:

    Date.prototype.between = function(start, end) {
      return (start <= this) && (end >= this);
    };

    Date.prototype.beginningOfDay = function() {
      var newDate = new Date(this);
      newDate.setHours(0);
      newDate.setMinutes(0);
      newDate.setSeconds(0);
      return newDate;
    };

    Date.prototype.endOfDay = function() {
      var newDate = new Date(this);
      newDate.setHours(23);
      newDate.setMinutes(59);
      newDate.setSeconds(59);
      return newDate;
    };

    Date.prototype.beginningOfWeek = function() {
      var newDate = new Date(this);
      var offsetToBeginning = newDate.getDay();
      newDate.setDate(newDate.getDate() - offsetToBeginning);
      return newDate.beginningOfDay();
    };

    Date.prototype.endOfWeek = function() {
      var newDate = new Date(this);
      // Saturday = 6
      var offsetToEnd = (6 - newDate.getDay());
      newDate.setDate(newDate.getDate() + offsetToEnd);
      return newDate.endOfDay();
    };

    // 0 = january, 1 = feb, ...
    // does not account for leap years
    Date.DAYS_OF_MONTH_MAP = [
      31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    ];

    Date.prototype.daysInMonth = function() {
      return Date.DAYS_OF_MONTH_MAP[this.getMonth()];
    }

    Date.prototype.beginningOfMonth = function() {
      var newDate = new Date(this);
      newDate.setDate(1);
      return newDate.beginningOfDay();
    };

    Date.prototype.endOfMonth = function() {
      var newDate = new Date(this);
      newDate.setDate(newDate.daysInMonth());
      return newDate.endOfDay();
    };

I did not need every method that ActiveSupport provided, so I stuck
with implementing only the ones I needed.  It's pretty straightforward
to write the rest of the methods if they're needed.
