# Landline phones with Google Homes

> Ok Google, call Dad.

My kids aren't interested in having a phone or a smart watch, which I'm pretty happy about. But I'd like them to have flexibility and freedom to see neighborhood friends and change their own plans. A lot of that has been ad hoc and works pretty well. I've left a handwritten notes on the whiteboard by the fridge for example. Asking him to be home by a certain time and giving him my casio watch is another example. But there has been frustrating mixups where I wish I could **talk** to him on a phone. If he's late to online class, or the schedule's been pushed back 15 minutes. Ideally, both kids would develop an interest in ham radios and take the technician test.

When I was a kid, this was a solved problem because homes had landlines. Either I'd tell my parents where I was, or I'd be at a friend's house and call their landline and leave a message. But landlines aren't a thing anymore. Well, except for [Tin Can](https://tincan.kids/), which looks fun and perfect. But we already have 3 google homes in the house[^ghome], and I figured they have all the hardware needed to send and receive calls without a monthly subscription. They're incredibly cheap 2nd hand, and in total I've spent $30 for the 3 we have. Setting them up for calls was tricky. When I asked it to make calls, it flat out said it couldn't make calls, but their own docs said it's possible! Asking it to "start a meet with ___"[^meet] seemed to work when I used my voice, but not when my kids said the same thing. Turns out, the voice recognition matches to a google account profile then uses that profile's contacts for calls (more on this later). Since my kids don't have google accounts, Home considers them as guests and doesn't know what contact to call. After digging around, I found "Household Contacts" under Settings > Communication. These are google contacts that are allowed to be called by anyone using the google home. But choosing a contact is wonky on iPhone. It chooses a contact from Apple Contacts, which it adds as a new card in Google Contacts. This wasn't obvious at first and made it hard to figure out which contact was being called if there were duplicates between Apple and Google contacts, and if the contacts had multiple phone numbers. Once I figured this out, I created a Dad and Mom contact on iPhone with a single phone number each so kids can say "Ok Google, call Dad" instead of "Ok Google, call Jerry Cheung mobile".

The second half is calling the Home from my phone. Google Meet doesn't allow me to ring myself, and while I can ring my partner and have it ring the Home because she's listed as an admin, I didn't want to ring her phone. To work around this, I created an empty google account, named the contact House and invited that account as a member of the Home. Note that this is not Household Contacts!

Broadcast is easy, but was useless in practice. Whenever we've needed a call, it's always needed two-way information. Even announcements need to be acknowledged otherwise I don't know whether it was heard or if kids were outside.

So to summarize, the required steps to fake a landline with Google homes are:

## Home to Phone

- Create a temporary "Dad" and "Mom" contact card with one callable number
- Settings > Communications > Household Contacts. This prompts for contacts from iOS.
- Selecting a contact on iOS will create a google contact on contacts.google.com. These can go out of sync! I imagine this works better on android. What worked was deleting any dupes in contacts.google.com first, then letting Google Home create a new google contact from the ios contact. It's awful, it's also fine.

## Phone to Home

- Create a dummy google account myhouse@gmail.com
- Home settings > + Invite person, myhouse@gmail.com
- Accept the invite. This is tricky with google auth on the same device, so switch email and home to myhouse@gmail.com after sending the invite to make sure the accept invite link works.
- Install Google Meet
- Add "House" iOS Contacts. Optional, but allows me to start from default Phone app, and it'll know to call using Google Meet. Calling with Phone app knows to switch you to Google Meet app, but Siri "Call House" doesn't work because it's an email and not a phone number.

## Room for improvement

I think the confusion comes from overlapping names and ambiguity over who the actor is. Google Home has admins and members, but this is distinct from Household Contacts, which are really "People anyone can call". "Family members" is also overloaded with Google's cloud plan sharing. Contacts is confusing from Apple's ecosystem because it actually uses Google Contacts. As far as who the actor is, the Home switches Google account profiles based on Voice Match. The problem is there's a gap for voices that don't map to a google profile. My workaround is to create a dummy google profile, but this feels clunky and leaky (see Household Contacts). What I'd prefer is to have a first class named account that represents the Home when I set it up. Then "Household Contacts" becomes the Home's shared contacts, the calendar becomes the Home's shared calendar, etc.

## Stuff that didn't work

- Upgrade Google Assistant on the Home to Gemini, though now the homes talk in a fun Australian accent.
- Installing Google Assistant on my phone. Google Home app asked me to do this to send me a notification that took me into the Settings > Communications > House Contacts section
- Installing the Google app, also unnecessary.
- Avoid logging into the House google account on your phone. The multiple google apps get confused when the profiles change. If this happens, sign out of everything, and just log back in as yourself.
- Settings > Communication > Call Providers. This was set to my cellular number, but can also be set to a Google Voice or Google Fi number. I changed this to my Google Voice number and calls from Home to Phone will show that ID. Unfortunately, I cannot add that number to House's contact card because then Phone will try to call Google Voice which does not know how to route to Home.




[^ghome]: They're used to start the dreame robovacuum, cycle a smart plug connected to a recirculating pump to warm up water for the shower, changing the thermostat, and playing your mama jokes (they really need to add more here). 
[^meet]: At one point, calls worked with the Google Duo app, but that's since been deprecated for Google Meet.
