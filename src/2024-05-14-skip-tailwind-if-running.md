# Skip tailwindcss build if already running

This speeds up tests and other rake tasks. Not a big savings (~1s on my tiny app), but takes out the extra tailwind build step if it's already running.

```ruby
# end of Rakefile
if Rails.env.test? && IO.popen('ps').readlines.any? {|l| l.include?('tailwindcss -i')}
  puts "Rakefile: tailwindcss:watch running, skipping tailwindcss:build"
  Rake::Task["test:prepare"].prerequisites.delete("tailwindcss:build")
end
```