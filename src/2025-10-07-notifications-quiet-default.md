# Quiet, but discoverable

When a new iOS lands, a handful of features are highlighted after the phone restarts. The majority of changes are slowly discovered over several days; Frequently delightful like finding spare change in the couch, sometimes gross like finding stale cereal in the couch.

The most common interactions do not justify additional explanations. Take the new liquid glass UI: I use it based on previous experience with touch interfaces and the subtle animations like sliding across a toggle are enough to teach me new behavior. Bigger changes like hiding unknown senders in Messages warrant a popup the first time, and offer a way to switch back to previous behavior. Mail also did this with Categories by offering to go back to having everything in one list.

I've found the best experiences to have sane defaults, combined with quiet discoverable hints to deeper capabilities. It's like how in school, we were taught to "show, not tell" when writing. Yet even recognizing the experiences I prefer, I'm guilty of creating things that explain the obvious, bury the point, and complicate things needlessly.

Here are a couple recent examples.

## Notifications

When I built the weekly and monthly digest notifications for [jch.app](https://jch.app), I defaulted them enabled thinking it would make them more discoverable. These emails are meant to be a skimmable summary. Roughly 10% of users open emails, about 1% of users click a link to see additional details. 90% of the time, people don't want them. For these users, the best case is the emails are sent to a hidden mailbox, and the worst case is they have to actively click on an unsubscribe link. Having the correct Unsubscribe-List header makes this easier in mail clients, but it's still a mindless task that users shouldn't need to do.

So I've decided to default notifications off for new users. In 2007, notifications were new enough to justify as a highlighted feature. In 2025, they should be behind settings and turned on if useful.

Why keep notifications at all if only 10% of users use it? Well, they happen to be the most active users, even the ones who never click within the emails. Selfishly, I also like the weekly summmary at the end of the week, so I imagine there are some similar minded people. The feature is useful, just not one that needs to be on when someone starts using the app. It should be a discovered feature, not an enabled default.

## Landing page

I was proud of the first iteration of my landing page. It was a simple fast page, with screenshots to preview the app, and prose to explain why someone would want to use it. There's a clear call to action that lets people try out a demo. Here's what it used to look like:

![](/images/old_landing.png)

I'm not sure how to measure whether visitors read the prose, but most of my traffic comes from financial-indepence and personal-finance enthusiasts. Users either land in the demo page, then navigate back to learn more, or create an account from the demo page directly. The FAQ is valuable when people want to learn more, but the screenshots weren't necessary because visitors either already previewed the app, or could do so with the "Try it now" button. Here's the new landing page:

![](/images/new_landing.png)

For most visitors, there are a few familiar keywords, and a prominent `Start >` link to jump into the app. I'm not playing the SEO game, and I'd lose even if I tried. For people who want to learn more, the content is just below the fold. Is this too minimal? I'll experiment and tweak to see.

## Other defaults?

It takes time to understand new interfaces and patterns, so it makes sense to stick with something familiar and gradually ease into better designs.

What else have we become accustomed to, but either no longer need or have better alternatives? (registrations? passwords, notifications) What used to be reasonable defaults, but are now mindless nuisances? (3rd party cookie popups, ask app not to track, notifications, dark mode perhaps?)
