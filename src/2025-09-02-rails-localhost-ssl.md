# SSL for local Rails development

- Works with https://localhost:3000 or https://custom-hostname.local
- No insecure site warning because certificated is signed by a system trusted CA

My goal was to test [jch.app](https://jch.app) serviceworkers
with different devices on the same network. While localhost is an exception allowed for serviceworkers,
all other origins require a no-warning https connection. This meant the certificate
must be signed with a system trusted CA.

Fortunately, `mkcert` does exactly that. Some additional fiddling was
needed to configure `puma` with command line options to reference the certs
and listen for SSL connections. No additional gems,
or configuration changes were necessary. Tested on macOS 15.6.1,
puma 6.6.0, mkcert 1.4.4, and rails 8.0.2.

```sh
# Run from rails root
# Create locally trusted certificate https://github.com/FiloSottile/mkcert
$ mkcert -install

# Used `sudo scutil --set LocalHostName` to set local hostname to `roboplan.local`
$ mkcert roboplan.local "*.roboplan.local" roboplan.local localhost 127.0.0.1 ::1

# Rename to avoid shell escaping later
$ mkdir -p config/certs
$ mv roboplan.local+5-key.pem config/certs/roboplan.local-key.pem
$ mv roboplan.local+5.pem config/certs/roboplan.local.pem

# Added in bin/dev
$ bin/rails server -b 'ssl://0.0.0.0?key=config/certs/roboplan.local-key.pem&cert=config/certs/roboplan.local.pem'
```

## Details

Puma and Falcon support self-signed certificates with `localhost` gem, but
the defaults did not add a system trusted CA causing certificate warnings
that made serviceworkers unavailable.

Additional notes:

- `mkcert` is a cross platform tool to install a system trusted CA, and use that to sign certs that won't give the insecure warning
- Rails will require `localhost` the development env without an explicit require
- `puma` reads from `config/puma/development.rb`, but does not evaluate the global `config/puma.rb`
- `localhost` setup uses `bake localhost:install`, but does not list `bake` as a dependency
- `puma` config `ssl_bind` still requires starting puma or rails server with `-b 'ssl://localhost:9292'` to handle SSL. Because of this, I preferred keeping all the config in one place as a CLI flag.
- `puma` docs start server with `puma`, but this loses the logging defaults I prefer with `rails server`
- `bin/setup` updated with `mkcert` steps for repeatability
- development certificates added to gitignore since they'll be specific to each host

> Service workers are only available in secure contexts: this means that their document is served over HTTPS, although browsers also treat http://localhost as a secure context, to facilitate local development. [MDN Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)

## Sources

- https://github.com/FiloSottile/mkcert
- https://github.com/puma/puma/blob/6-6-stable/README.md#self-signed-ssl-certificates-via-the-localhost-gem-for-development-use puma localhost documentation
- https://github.com/puma/puma/releases/tag/v5.6.0 Support localhost integration in ssl_bind
- https://github.com/puma/puma/releases/tag/v5.5.0 new integration with the localhost gem
- https://github.com/basecamp/thruster/pull/40 TLS_LOCAL support is promising, but also fine to leave thruster focused on production
- https://gist.github.com/chaffeqa/d6c6ac491d3e1824a2980607d796e4a8 creates cert dynamically in config/puma.rb and installs to system across platforms. This had the `ssl_bind` config, but was missing the `-b ssl://0.0.0.0:3001`. I found mkcert first, but this implementation may be easier to use with `bin/setup` and version control.
- https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API
