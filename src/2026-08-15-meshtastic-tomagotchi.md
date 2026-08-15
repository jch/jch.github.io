# Meshtastic meets Tomagotchi: Long Range Mesh Radio Network

Dennis (AD6DM) told me about Meshtastic before Defcon 34, so I bought 2 little radios from the merch area to try it out. If I'm being honest, what hooked me was the adorable 3d-printed tomagotchi[^antenna] case and the custom firmware that gives you a pet to feed and take care of.

![](/images/tomagotchi-lora.jpg)

The radio is cool too! Defcon was a great place to try it out because there were nodes everywhere, making it easy to trace how different nodes would relay messages, testing out private messages, and playing around with the configs and the companion phone app.

Once I got home, I sat down to dig through how it works and what local nodes were available. It's built on [LoRa Long Range](https://en.wikipedia.org/wiki/LoRa) using sub-gigahertz unlicensed spectrum intended for transmitting small amounts of data where wifi or cellular can't reach. I plan to use it during hiking and camping, but there are lots of other applications including IoT sensors, controlling drones, and emergency communications.

## Presets

Meshtastic defines a number of configuration presets. For radios to form a mesh and talk to each other, they have to broadcast with the same preset [^docs]. I made myself this study guide to understand how these settings trade off between range, speed, congestion, and battery life.

| Preset | Bandwidth (BW) | Spreading Factor (SF) | Coding Rate (CR) | Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **Short Turbo** | 500 kHz | SF7 | 4/5 | testing hardware, low latency, drones? |
| **Short Fast** | 250 kHz | SF7 | 4/5 | close nodes, high traffic, defcon used this |
| **Medium Fast** | 250 kHz | SF9 | 4/5 | bayme.sh, faster delivery |
| **Long Fast** *(Default)* | 250 kHz | SF11 | 4/5 | general urban/suburban community mesh networks |
| **Long Slow** | 125 kHz | SF11 | 4/8 | Connecting a remote node |
| **Very Long Slow** | 62.5 kHz | SF12 | 4/8 | Remote solar-powered weather stations, scientific sensors, or emergency links |

Meshtastic lives on the ISM spectrum[^ism] and uses the 915Mhz range from 902Mhz to 928Mhz in North America. A hertz is the time it takes for something to complete a full cycle in one second. So a 100hz radio wave is one that takes 0.01 second for the wave to go up and down, and a 915Mhz wave means there are 915 million up's and down's wave cycles in a second. With radio waves, there are a few ways to modulate[^modem] information inside it. AM and FM radio are easy to visualize. Amplitude modulation makes the waves taller and shorter, while frequency modulation makes the waves faster/closer and slower/further. LoRa uses Chirp Spread Spectrum (CSS) to encode information as a series of 'chirps', which I don't understand yet and leaving as a black box[^css].

Bandwidth describes a range of frequencies around a center carrier frequency. For example, 250 kHz bandwidth around a center carrier frequency of 915Mhz would mean transmitting 125kHz above and below (914.875Mhz to 915.125Mhz). In my head, I imagine tuning an FM radio: if you're near the center of a station the music is clear, and fuzzy as you go further away, before getting into the next station's range.

The more bandwidth, the faster we can transmit. So why not use the whole 26Mhz of bandwidth (928Mhz - 902Mhz)? Since it's a shared spectrum, different radios broadcasting at the same time will cancel out or step on each other. Just like FM radio, the fix is to slice up the spectrum into frequency slots ahead of time and find a slot that isn't congested (existing radios broadcasting or background noise). Wider bandwidth means fewer slots, while narrower bandwidth means more slots. The default Long Fast preset has a bandwidth of 250 kHz, which yields 104 slots (26Mhz / 0.25Mhz), while Very Long Slow has 62.5 kHz which yields 416 slots (26Mhz / 0.0625). Wider bandwidth means faster transmission, narrower bandwidth is slower but has more slots to avoid congestion.

Spreading factor describes the number of chirps the radio uses to encode a symbol. More chirps increases reliability to noise, but is slower because we need to send more chirps for the same number of bits. It's a logarithmic scale that doubles with each increasing number:

- SF7: 2^7 = 128 chirps / symbol
- SF8: 2^8 = 256 chirps / symbol
...
- SF12: 2^12 = 4,096 chirps / symbol

Because there are more chirps, it takes longer because all of those chirps need to be sent in the same bandwidth. 

Coding rate is how many additional bits to transmit for forward error correction. More bits means more protection. It's expressed as a fraction with 4 as the numerator describing the number of information bits, and the denominator as the total number of bits. Long Fast uses 4/5, which means 5 bits is sent for every 4 bits of information, Long Slow is 4/8, which doubles the message length. Interestingly, the packet format declares what coding rate the payload is, so nodes will relay messages with a different coding rate as long as bandwidth and spread factor are the same. But if nodes are configured with a preset, then it bundles all 3 config's bandwidth, spread factor, and coding rate together, making those nodes only understand that config. It's possible to configure nodes to define these variables independently for a custom mesh as long as all the nodes agree.


[^antenna]: Antennas work better when tuned to a frequency range that's a fractional multiple of the wavelength. The longer the radio wavelength, the longer the antenna. For 915Mhz, that works out to ~12.9 inch wavelength with a quarter length antenna of 3.2 inches neatly wrapped inside the tomagotchi case.
[^ism]: This is part of the  ISM (Industrial Scientific and Medical) shared by old cordless phones, RFID tags, toll passes, smart meters, garage door openers, security sensors, and baby monitors. Someone at defcon mentioned pagers use this band as well.
[^css]: https://meshtastic.org/docs/overview/#meshtastic-lora-chirp
[^modem]: modem stands for modulator demodulator, meaning it turns digital signal 1 and 0's into another medium like radio waves, then another modem demodulates the waves back into digital.
[^docs]: https://meshtastic.org/docs/overview/
