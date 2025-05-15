# Bake-off: It's Performance Week!

tl;dr I spent a week to bring https://jch.app from 3s+ pages to ~150ms at the 99%tile

Back again after my earlier rant about deployments this week. I run a personal project for tracking my investments at https://jch.app. Once I was happy with the functionality, the slow page loads became annoying. I hope this random collection of notes and search keywords helps another solo dev out there.

puma: I was running out of memory on render's 512MB of ram. Given the low traffic, I cut down the workers so that it was running in standalone mode with multiple threads. slow/occasionally broken -> slow.

rack-mini-profiler: I ran this locally and in production to get a rough timing and breakdown between code and sql calls. In-memory storage of results is fine since I was testing pages I knew were slow.

propshaft / sprockets: A surprising finding from flamegraphs was that propshaft was taking a significant percentage of time in development (Dir.[]). This wasn't an issue in production since static assets were already precompiled and served outside rails, but I switched to sprockets to make it easier to compare local / prod timings. Would be an interesting problem to dig into further.

solid_cache: I used this to cache the custom sql queries I use to calculate a time series of networth (10 years of historical stock prices against my holdings). Having it cache to db keeps my infrastructure surface area small. 3+ seconds down to ~1s.

turbo frames: Lazy load the long list of assets so that it's only fetched when it comes into view. 1s -> 500ms. Breaking up the page into partials also shows how much time each partial takes with the mini_profiler, and makes the flamegraph easier to read.

ActiveRecord::QueryMethods#select: pushing some calculations to sql instead of materializing the record and doing the calculation in ruby. e.g. holdings.select``("SUM(shares * price)") 500ms -> 300ms

Increasing compute: I was hosting on render.com and increased the compute from Starter $7/mo 0.5CPU to Standard $25/mo 1CPU. Postgresql instance stayed the same at 0.5CPU. This did roughly half the request time to ~150ms. But I was curious to try out kamal and compare performance to a VPS like digital ocean. This was a good stopping point for getting to around 100-150ms page latency by mid-week. Everything after was new and for fun.

kamal / docker / digital ocean: Digital Ocean was simple enough to start a $4/mo droplet. Kamal source code is easy to walk through, and served as a starting point for what docker areas to learn about. Docker is new to me, but the documentation is good (particularly the Engine section). I ran into an issue with not being able to connect my app container to my postgres container, but that was solved after understanding how docker handles networking. tldr is to specify the IP instead of localhost from inside the container, or switch the network adapter to "network = host".

dockerfile-rails: unfortunately, I didn't run the app long enough on the vanilla rails docker file to compare, but the fly.io template have a couple memory optimizations. Would be interesting to compare the memory usage with the stock recommendations.

cloudflare: render had my origin servers behind a CDN, but since I moved to digital ocean, I configured my own here. Rails asset pipeline can be CDN aware, but I proxied the entire domain and found the default file extensions it caches to be sufficient. The only cloudflare config I had to change was to set the SSL to full to avoid redirect loop b/c traefik was rewriting all my traffic to SSL already.

deploy speed: I'm running an intel MacBook prod, so turning off multiarch under builder cut my deploy down by more than half (3min to 1min+)


