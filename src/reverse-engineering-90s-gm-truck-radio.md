# How to add bluetooth to old car radios with separate auxiliary CD/cassette drives

My project vehicle came from the factory with a tape deck and a CD player. I
wanted to play music from my phone over bluetooth, but I also wanted to keep the
original OEM interior intact.

The most sensible solution would've been to buy a $5 cassette tape to aux
adapter. If you just want music, stop reading and save yourself some time, money,
and blood.

For a few bucks more, an FM transmitter would also work. For slightly improved
quality, there are transmitters which connect inline with the radio antenna
directly into the radio. This could yield better audio quality and less
interference with local stations. I almost went this route, but wanted to have
track controls; Silly, I know.

The next obvious choice was to buy an after market head unit with all the modern
bells and whistles. I admit the Apple Carplay and Android Auto head units were
tempting, but I wanted to try and keep the stock look. No one would consider
this pickup a classic by any measure, but everything feels right like it came
from the right decade. There's a tiny calculator style display, individual knobs
for an equalizer, speed dependent volume, and track controls. Some high end
tech. Ripping out all that 90's goodness and slapping a touchscreen on just
didn't feel right.

## Fake CD player

The radio has an AUX button that switches to the auxiliary device, the CD drive,
but only if it detects there is an inserted CD. The display shows a small disc
icon when there is a disc. Once switched to aux, the display can cycle between
the clock, the current track number, and the current position in the song. More
importantly, the radio station preset controls turn into track controls (prev,
next, rewind, fast forward). This meant there was some way to trick the radio
into thinking that it was talking to a CD player, but replace the CD with a
different input source like bluetooth audio.

Both [Full Size
Chevy](http://www.fullsizechevy.com/forum/general-discussion/audio-video-electronics/491405-added-aux-input-factory-95-02-gm-deck.html),
and GMT400 forums had good resources for people with similar ideas. Several
owners drilled a hole into the dash, added a 3.5mm audio jack, and tapped into
the CD player's left and right audio channel wires. A CD still had to be in and
playing, but the audio would come from the new input. Not bad for <$20. If you
didn't want to cut any wires, [Pac Audio's $50
AAI-GM9](http://www.pac-audio.com/productDetails.aspx?ProductId=99&CategoryID=24)
is a plug and play device that does the same thing.

![](/images/gmt400/aai-gm9.png)

## The plan

I didn't have access to the original wiring diagrams, but I did find a few
promising ones from the same era of GM trucks. The radio and CD are connected by
a 9-pin connector. The obvious ones were power, and the left/right audio
channels. But we're interested in the data wire the radio and CD communicates
over.

This is my first attempt at an electronics project. Fortunately, I had a lot of
help from @jonmagic and several other coworkers.

Our rough plan was:

* power on the radio and CD outside of the truck
* connect them through a breadboard so we can listen to and decode the data signal
* build a controller to simulate the data signals for an inserted CD, and track controls
* connect a bluetooth audio module as input

## Wiring and power on

![](/images/gmt400/power-on.png)

* wiring diagram was wrong
* ground was wrong to CD, but inadvertantly powered on because we stacked the radio on top of the cd, grounding it through the chassis

## Listening to the signal

## Decoding the signal

## Simulating the signal

## Adding bluetooth

## Summary

* cheap/easy: cassette adapter, FM transmitter
* expensive/medium: aftermarket head unit
* medium/hard: stock head unit, custom software

* total cost
* total time

[aai-gm9](http://www.pac-audio.com/PACProductData/AAI-GM9/1_Instructions/aai-gm9_instructions_111605.pdf)
