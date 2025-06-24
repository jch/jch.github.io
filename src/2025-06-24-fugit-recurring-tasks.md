Fugit gem: defining recurring tasks for background jobs

[Fugit](https://github.com/floraison/fugit) parses cron syntax and various time and date strings. It is a dependency of solid_queue and good_job. I didn't notice it at first because I was using cron syntax directly for my [side project](https://jch.app).

Personally, I don't mind cron syntax, but it turns out fugit also supports time zones. I have some tasks that run on Eastern time based on the stock market. Previously, I had two separate cron entries for daylight savings time. But now, fugit simplifies it to `US/Eastern`.

The readme has a lot of other examples, but the fun one that stood out to me was ["the first Monday of the month"](https://github.com/floraison/fugit?tab=readme-ov-file#the-first-monday-of-the-month):

> Fugit tries to follow the man 5 crontab documentation.

> There is a surprising thing about this canon, all the columns are joined by ANDs, except for monthday and weekday which are joined together by OR if they are both set (they are not *).

> Many people (me included) are surprised when they try to specify "at 05:00 on the first Monday of the month" as 0 5 1-7 * 1 or 0 5 1-7 * mon and the results are off.

> The man page says:

> Note: The day of a command's execution can be specified by two fields -- day of month, and day of week. If both fields are restricted (ie, are not *), the command will be run when either field matches the current time. For example, ``30 4 1,15 * 5'' would cause a command to be run at 4:30 am on the 1st and 15th of each month, plus every Friday.
Fugit follows this specification.

Anyways, thought I'd share this long-running stable and neat gem that's used by a lot of the popular ruby scheduling libs.
