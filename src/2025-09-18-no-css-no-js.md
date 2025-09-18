# No CSS, No Javascript. Longevity on the web.

Remember [CSS Zen Garden](https://csszengarden.com)? It started out as a site to allow designers to showcase how semantics (HTML) and visual design (CSS) can be separated. I remember being blown away by the early designs, but then being disappointed by the mess of relative and absolute positioning.

Remember [jQuery](https://jquery.com)? The interface was so simple, and it proliferated so many plugins that followed a similar design. These were the early polyfills for the modern web platform we know today.

I've switched operating systems, hardware architectures, desktops, laptops, and phones. Somehow, through all of that, a website written 20 years ago still works today. Other than retro-nostalgic emulation, is that true for anything else?

Herman has written a great post on [Building software to last forever](https://herman.bearblog.dev/building-software-to-last-forever/). As I develop my financial independence [jch.app](https://jch.app), I'm thinking how I'll make it last forever.

## HTML First

I start with the semantics and affordances of a design with unstyled HTML first. Think text, links, forms, and buttons.

I target [Web Platform Baseline](https://web.dev/baseline) and use MDN daily as a resource. Practically, I develop with Safari and Safari iOS because they tend to be the lowest common denominator, and I'm in that ecosystem.

## CSS Next

Then I enter my CSS Zen Garden phase. Thankfully, with grid, flexbox, and multi-col layouts in baseline, there are many more tools available than the early days of the web. There's also room for some delightful flourishes with color and animations.

I use tailwind because it lets me prototype quickly. A dependency isn't detrimental to longevity if it lives close to a standard, and doesn't lock into the vendor. I could easily switch back to BEM-style naming and CSS.

## Finally, Javascript

If I stopped now, the app should be fully usable and aesthetically pleasing. I sprinkle on Javascript for the final bit of polish. For example, I recently added drag and drop reordering. Initially, I did this with the baseline Drag and Drop API, but found it clunky on touch devices. Much like how jQuery would polyfill capabilities that weren't quite ready for primetime, I add js dependencies sparingly for the same reason.

I use `<noscript>` wherever I enhance components, and also a `.no-js` CSS class defined within `noscript` to help hide UI as needed.

## Try it out

Try turning off CSS and Javascript when visiting [jch.app](https://jch.app). The default browser styles remind me of Craigslist in a good way. The site works as intended. Turn on CSS. It's a big jump in layout and the experience, but the semantics between pages and functionality stay the same. Finally, turn on javascript. These changes are subtle. Service workers add device-specific native features like push notifications and icons. View transitions adds an extra bit of silkiness to the experience.

## Longevity elsewhere

I've written about self-hosting jch.app on old hardware. There isn't an infrastructure equivalent of "baseline", but "unix-y" comes close.
