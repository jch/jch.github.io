# Self hosting Rails on a Mac

https://jch.app now runs on a 2016 Macbook Pro with i7-6920HQ CPU @ 2.90GHz, 16GB DDR3 ram, and 2TB SSD.

I feel warm and fuzzy keeping this 8 year old mac out of the e-waste bin. The app is low traffic, but it nonetheless strained the $7/month Digital Ocean VPS. While it's no Apple silicon or raspberry pi in efficiency, the laptop draws a modest 15-20W, translating to ~$3/month at my utility rates. This generation mac had 4 thunderbolt ports, so I also bought a $10 thunderbolt to ethernet adapter.

I kept the existing OSX install to keep my development and production environments similar. While I love linux, I wanted to avoid troubleshooting apple hardware issues. My dad gave me a free thinkpad t480s which would make a nice linux dev machine, but that's a story for another day.

Roughly, the steps are:

1. DNS resolves your domain name to your server IP address
2. Router forwards requests to your server
3. Server knows to update DNS if IP address changes

My notes list the domain as `m.jch.app` because the base domain `jch.app` pointed at production. Once everything was migrated, I updated the configs to point at the base domain.

## Forward ports

1. Configure router to assign a static IP address to server by it's MAC address
2. Forward public web (80, 443) and ssh (22), or all ports to server.


By default, Safari uses Private Relay which will mask your public IP if you try to search for it.

```sh
# `what is my public ip address command line`
$ curl ifconfig.co

- Router settings
  - Device Info
    - WAN (PUBLIC_IP x.x.x.x)
  - Advanced Setup
    - Static IP Lease, server MAC address, 192.168.1.2 (some static IP)
    - NAT
      - DMZ Host 192.168.1.2 (this updates without a reboot, forwards all ports to this host)

# verify port forwarding works from somewhere outside of your network
$ nc -zv PUBLIC_IP 22
```

## Dyanmic DNS

I'm using Cloudflare for DNS, which has an API.

- https://github.com/qdm12/ddns-updater
  - v2.8.1 static binary
  - config/data.json for cloudflare config
  ```json
  {
    "settings": [
      {
        "provider": "cloudflare",
        "proxied": true,
        "zone_identifier": "cloudflare dash > m.jch.app > scroll down to Zone ID",
        "domain": "m.jch.app",
        "ttl": 600,
        "token": "cloudflare dash > m.jch.app > API > Get your API token > Edit Zone DNS",
        "ip_version": "ipv4",
        "ipv6_suffix": ""
      }
    ]
  }
  ```
- Cloudflare > m.jch.app > DNS
  - Verify A record m.jch.app points to PUBLIC_IP

## Host configuration

- OSX > Network
  - Ethernet device
    - Verify IP 192.168.1.2 statically assigned by MAC
  - Firewall enabled
    - Options (each should prompt to be added as exception)
      - ddns-updater_2.8.1_darwin_amd64
      - ruby
      - thrust
  - /etc/hosts
    - 192.168.1.2 m.jch.app (otherwise built-in router httpd will respond)

## Rails

```ruby
# Gemfile
gem "thruster"  # https://github.com/basecamp/thruster

# config/application.rb
config.hosts << "m.jch.app"
config.logger = Logger.new(config.paths['log'].first, 1, 100.megabytes)

# config/environments/production.rb
# assets will be cached by thruster
config.public_file_server.enabled = true
config.public_file_server.headers = {
  'Cache-Control' => 'public, s-maxage=31536000, max-age=15552000',
  'Expires' => 1.year.from_now.to_formatted_s(:rfc822)
}

# config/master.key from digital ocean
```

```sh
# Starting server in development for testing
$ DEBUG=1 TLS_DOMAIN=m.jch.app thrust bin/rails server
$ curl -Iv https://m.jch.app

# Starting server in production
DEBUG=1 TLS_DOMAIN=jch.app caffeinate -s thrust bin/rails server -e production
$ curl -Iv https://m.jch.app
```

## Deployment

Previously, I had deployment setup with Kamal and containers. With development and production being the same, I wrote a bash script for simplicity. Deploys take ~13 seconds.

```sh
#!/usr/bin/env bash
# bin/deploy
set -e

APP_ROOT=$(dirname "$0")/..
cd $APP_ROOT
source $APP_ROOT/.env

git stash > /dev/null

echo "Pulling the latest changes..."
git pull
echo

echo "Bundling dependencies..."
BUNDLE_DEPLOYMENT=1 BUNDLE_WITHOUT=development:test BUNDLE_WITHOUT_DOCUMENTATION=true bin/bundle
echo

echo "Migrating the database..."
bin/rails db:migrate
echo

echo "Precompiling assets..."
bin/rails assets:precompile
echo

bin/rails runner "puts 'Checking app loads...'"
echo

echo "Restarting the app..."
touch tmp/restart.txt
echo

echo "Cleaning up old logs..."
rm log/*.log.* 2>/dev/null || true
echo
```

## Processes

These are run in a `screen` session for access via ssh. `caffeinate` keeps the mac awake.

```sh
cd ddns-updater; ./ddns-updater_2.8.1_darwin_amd64
cd roboplan; DEBUG=1 TLS_DOMAIN=m.jch.app RAILS_ENV=production WEB_CONCURRENCY=4 RAILS_MAX_THREADS=1 caffeinate -s thrust bin/rails server
htop  # F4 Filter 'puma'
cd roboplan; tail -f log/production.log
```

## Backups

```sh
$ crontab -l
0 8 * * 1-5 /Users/jch/roboplan/bin/backup
```

```sh
#!/usr/bin/env bash
# bin/backup
set -e

APP_ROOT=$(dirname "$0")/..
source $APP_ROOT/.env

if [ -n "$1" ]; then
  BACKUP_ROOT=$1
else
  BACKUP_ROOT=$APP_ROOT/backups
fi

mkdir -p $BACKUP_ROOT
ls -t $BACKUP_ROOT | tail -n +11 | xargs rm -rf

BACKUP_DIR=$BACKUP_ROOT/${POSTGRES_DB}_$(date +%Y-%m-%d)
NUM_JOBS=$(/usr/sbin/sysctl -n hw.physicalcpu 2>/dev/null || echo 1)

pg_dump $POSTGRES_DB --format=d --jobs=$NUM_JOBS --clean --no-owner --if-exists --file $BACKUP_DIR > /dev/null

find $BACKUP_ROOT -type d | xargs du -sh
```

## Benchmarks

- ruby 3.3.5
- rails 7.1.2
- postgresql 17.0
- disable wifi to ensure testing on ethernet interface
- run multiple times to warm up servers

```sh
# 1 worker, 3 threads (baseline from digital ocean)
$ wrk -t10 -c100 -d30s https://m.jch.app
Running 30s test @ https://m.jch.app
  10 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    41.68ms   93.04ms   1.81s    99.34%
    Req/Sec    23.56     14.24    70.00     68.77%
  2510 requests in 30.08s, 46.16MB read
  Socket errors: connect 0, read 0, write 0, timeout 234
Requests/sec:     83.43
Transfer/sec:      1.53MB

# 4 workers, 1 thread on mac (roughly ~3x, more threads don't help)
$ TLS_DOMAIN=m.jch.com RAILS_MAX_THREADS=1 WEB_CONCURRENCY=4 RAILS_ENV=production thrust bin/rails server
$ wrk -t10 -c100 -d30s https://m.jch.app
Running 30s test @ https://m.jch.app
  10 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
     Latency    29.96ms  128.94ms   1.92s    98.38%
     Req/Sec    46.60     36.89   220.00     71.97%
  8074 requests in 30.10s, 148.47MB read
  Socket errors: connect 0, read 0, write 0, timeout 814
Requests/sec:    268.21
Transfer/sec:      4.93MB
```

## Power management

I thought the battery would be a nice UPS in case of a power outage, but it's completely shot. I realized this one day when our robovac bumped the power adapter loose and the site went down. No plans to replace the battery because this generation of laptop required replacing the entire top case (keyboard / battery).

```sh
$ pmset -g batt | grep -v "drawing from 'AC Power'" && osascript -e 'tell application "Messages" to send "Ack! Powers out" to buddy "jollyjerry@gmail.com"'

```

## Development

Access development server from phone or other devices for testing. These are part of `bin/setup`

```sh
# Jerrys-MacBook-Pro, accessible at Jerrys-MacBook-Pro.local via mDNS
scutil --get LocalHostName
scutil --set LocalHostName roboplan-dev  # roboplan-dev.local

# Firewall configuration, still bit wonky
sudo codesign --force --sign - $(which ruby)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add $(which ruby)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --listapps

# Test firewall and dns
ruby -run -e httpd . -p 3000
curl http://localhost:3000
curl http://$(ifconfig | grep 192 | awk '{print $2}'):3000
curl http://roboplan-dev.local:3000
```

```ruby
# config/development.rb
config.hosts << `scutil --get LocalHostName`.strip + '.local'
```

Thank you for stopping by and reading, and I hope you this inspires you to save some old hardware too.
