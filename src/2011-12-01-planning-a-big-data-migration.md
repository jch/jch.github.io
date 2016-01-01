# Planning a Big Data Migration

It doesn't matter if data is being migrated from SQL to NoSQL, from flat
files to key-value store, or from XML to an object database, or every
permutation of any data store to any other data store. What stays constant is
the fact that data migrations are scary and painful. Without the right strategy, a big
data migration will leave you with inconsistent data, strange errors, and very
angry users. Read on for a data migration checklist that'll save you days of
headache.

It doesn't matter if data is being migrated from SQL to NoSQL, from flat
files to key-value store, or from XML to an object database, or every
permutation of any data store to any other data store. What stays constant is
the fact that data migrations are scary and painful. Without the right strategy, a big
data migration will leave you with inconsistent data, strange errors, and very
angry users. Read on for a data migration checklist that'll save you days of
headache.

## Backup

Before even considering a massive destructive mutation of your data, you
should have working backups. The keyword is **"working"**. Take production
dumps of your data, and make sure you can load the same data on a cloned
environment. If anything goes wrong when migration day comes along, these
backups will be your last line of defense. Backups are also useful for doing
practice runs of a migration.

## Logging

Create a logger that logs to a separate place from your application logs
that's specific for the migration. When the migration is running, the logger
should warn on strange data and error on exceptional cases. To keep the log
useful, it's important not to flood it with debugging information. Log only
the most important details needed for troubleshooting problems: a timestamp,
an id reference to the failing record, and a brief description of the failure
reason.

## Atomicity

Regardless of whether the destination data store supports transactions or not,
the migration should always define an invariant for when a record is
successfully imported. If this invariant is broken, then whatever has been
done to break the invariant should be undone so that your data isn't in some
zombie half consistent state.

## Idempotence

Not strictly the definition of
[idempotence](http://en.wikipedia.org/wiki/Idempotence), but similar to
maintaining consistency, your code should be able to handle re-migrating the
same data. If the migration crashes halfway, having this property allows you
restart and import again without worrying about weird state issues.

## Batch Processing

Having atomicity and idempotence lets your migration be split up into smaller
migrations. Instead of migrating a million records in an all-or-nothing
migration and crossing your fingers, you can split them up into small 500
record batches. If any single batch fails, you can redo just that single
batch, rather than redo the entire migration. This also allows you to balance
the migration across more resources like multiprocessors, different servers,
and different slave databases.

## Validation

After a migration is complete, it's important to be able to validate that
everything is still working. This means running your test suite, your
integration tests, and also logging in as existing users and clicking around.

## Live Migrations

Running a migration with scheduled downtime is hard enough as it is, but in
certain applications, a big chunk of downtime is unacceptable. If this is the
case, then it's critical to add bookkeeping code that tracks which records has
been migrated and which haven't. This allows you to query and incrementally
upgrade parts of your system while co-existing with old data and old code.

## Plan Ahead

Data migrations will always be a chore. But with the right strategy, at least
it'll be one that can be finished, rather than something that drags along and
repeatedly slows down your whole team.
