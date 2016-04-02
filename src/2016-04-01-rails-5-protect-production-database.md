# Rails 5 Production Database Protection

Rails 5 [prevents bad things™][pr] from happening to production databases:

```sh
$ RAILS_ENV=production rake db:drop
rake aborted!
ActiveRecord::ProtectedEnvironmentError: You are attempting to run a destructive action against your 'production' database
If you are sure you want to continue, run the same command with the environment variable
DISABLE_DATABASE_ENVIRONMENT_CHECK=1
```

Protected environments are configurable:

```ruby
# config/application.rb
ActiveRecord::Base.protected_environments << 'staging'
```

For older versions of Rails, I add the following to `lib/tasks/db.rake`:

```ruby
namespace :db do
  desc 'Protect against running task in production'
  task :protect do
    fail 'Refusing to run in production environment' if Rails.env == 'production'
  end

  task :drop => :protect
  task 'schema:load' => :protect
end
```

[pr]: https://github.com/rails/rails/pull/22967
