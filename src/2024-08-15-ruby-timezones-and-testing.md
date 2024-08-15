# Ruby timezones and testing

I had a test in [jch.app](https://jch.app) which fetched data by date, and kept
being off by one day. The minimal failing test case became:

```ruby
Timecop.freeze("2024/03/15") do
  assert_equal Date.current, Date.today
end
```

Turns out, this was documented behavior that goes way back to 2011. From the
timecop README:

> Sometimes
> [Rails Date/Time methods don't play nicely with Ruby Date/Time methods](https://rails.lighthouseapp.com/projects/8994/tickets/6410-dateyesterday-datetoday).
> Be careful mixing Ruby Date.today with Rails Date.tomorrow / Date.yesterday as
> things might break.

Here are the differences between ruby's builtin Time and Date methods, compared
with using ActiveSupport's TimeWithZone and Date extensions.

```ruby
irb> ENV['TZ']
=> nil
irb> Time.now
=> 2024-08-15 13:48:14.639956 -0700  # no timezone set picks up system time
irb> ENV['TZ'] = 'US/Eastern'
=> "US/Eastern"
irb> Time.now
=> 2024-08-15 16:48:46.905847 -0400  # ENV['TZ'] set overrides system time

irb> require 'date'
irb> Date.today
=> #<Date: 2024-08-15 ((2460538j,0s,0n),+0s,2299161j)>

irb> Date.today.to_time
=> 2024-08-15 00:00:00 -0700

irb> require 'active_support'
irb> require 'active_support/core_ext/date/calculations'
irb> Time.zone = 'Asia/Tokyo'
=> "Asia/Tokyo"
irb> Time.now
=> 2024-08-15 13:56:27.470616 -0700  # system time!
irb> Time.zone.now
=> Fri, 16 Aug 2024 05:56:30.666951000 JST +09:00  # the following day b/c of +9 compared to my -7 system offset
irb> Date.today  # system time!
=> Thu, 15 Aug 2024
irb> Date.current  # Time.zone date
=> Fri, 16 Aug 2024
```

Before I figured this out, my fix for the test was to stub

```ruby
Date.stubs(:current).returns(Date.parse("2024-01-01"))
```

Other methods have dates parameterized for testing. Since I'm not using any of
timecop's travel functionality, I decided to remove the dependency.

## Resources

- [Thoughtbot: It's about timezones](https://thoughtbot.com/blog/its-about-time-zones)
- [Timecop PR #416: ActiveSupport Date.current differs from Date.today when Time.zone is set](https://github.com/travisjeffery/timecop/pull/416)
