# Troubleshooting NetworkManager DHCP

After migrating from Debian Bookworm to Fedora Workstation 43, I getting ip addresses from my main network. After chasing some red herrings, the culprit was my Adtrans modem/router not responding to dhcp requests with a client id. The fix was to configure NetworkManager's internal dhcp client to not send this info:

```
# /etc/NetworkManager/conf.d/99-adtran-compat.conf
[connection]
ipv4.dhcp-client-id=none
```

## Notes

I noticed that I wasn't able to connect to my main wifi teatime5. However, "teatime5 Guest" worked fine. Eventually I needed to be on the main network so I could print puppy coloring pages.

I messed eero's settings, but remembered my wifi router is bridged to my adtrans modem / router. The adtrans was responsible for DHCP leases. "teatime5 Guest" was a separate network created and managed by eero, which explained why dhcp worked there.

I installed `dhcp-client` and was able to manually get an ip with:

```
$ sudo dnf install dhcp-client

$ sudo dhclient -v enp12s0
```

Aside: I have 3 network interfaces on this laptop `wlp61s0` wifi, `enp0s31f6` ethernet, `enp12s0` thunderbolt (display with ethernet on the back). `ip link` lists available interfaces. `nmcli con` also works, but doesn't list disconnected interfaces.

```
$ ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp0s31f6: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN mode DEFAULT group default qlen 1000
    link/ether e8:6a:64:2e:59:ee brd ff:ff:ff:ff:ff:ff
    altname enxe86a642e59ee
3: wlp61s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DORMANT group default qlen 1000
    link/ether da:e7:76:ef:96:ce brd ff:ff:ff:ff:ff:ff permaddr 48:a4:72:9a:f6:14
    altname wlx48a4729af614
6: enp12s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 3c:07:54:6f:15:85 brd ff:ff:ff:ff:ff:ff
    altname enx3c07546f1585
```

Configuring NetworkManager to use dhclient didn't work. Logs showed it couldn't find the client. It may need a separate plugin:

```
# /etc/NetworkManager/conf.d/99-adtran-compat.conf
[main]
dhcp=dclient

# journalctl -u NetworkManager -f
Mar 29 11:46:09 fedora NetworkManager[50641]: <warn>  [1774809969.9349] dhcp: init: DHCP client 'dhclient' not available
```

The hack fix was to configure the interfaces as link-only, and run a script after connections are established:

```sh
$ sudo touch /etc/NetworkManager/dispatcher.d/99-adtran-dhcp
$ sudo chmod 755 /etc/NetworkManager/dispatcher.d/99-adtran-dhcp
```

The script executes after connect:

```sh
#!/bin/bash
INTERFACE=$1
ACTION=$2

# wlp61s0: wireless interfaces
# enp0s31f6: ethernet
# enp12s0: thunderbolt display with ethernet
if [[ "$INTERFACE" =~ ^(wlp61s0|enp0s31f6|enp12s0)$ ]] && [[ "$ACTION" == "up" ]]; then
    # Release any old/stale leases first
    /usr/sbin/dhclient -v -r "$INTERFACE"
    
    # Request a new lease and log the results for debugging
    /usr/sbin/dhclient -v "$INTERFACE" > /tmp/adtran_dhcp.log 2>&1
fi
```

This worked, but it'll probably bite me on some upgrade. To stay close to distro defaults, I needed to figure out the difference between requests sent by the internal dhcp client and dhclient.

Let's compare them back to back. First, fedora's default that sends a device id

```
$ sudo tcpdump -i enp12s0 -vvvn port 67 or port 68
tcpdump: listening on enp12s0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
11:04:19.931750 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto UDP (17), length 310)
    0.0.0.0.bootpc > 255.255.255.255.bootps: [udp sum ok] BOOTP/DHCP, Request from 3c:07:54:6f:15:85, length 282, xid 0x5b52b4e2, secs 1, Flags [none] (0x0000)
          Client-Ethernet-Address 3c:07:54:6f:15:85
          Vendor-rfc1048 Extensions
            Magic Cookie 0x63825363
            DHCP-Message (53), length 1: Request
            Client-ID (61), length 7: ether 3c:07:54:6f:15:85
            Parameter-Request (55), length 17:
              Subnet-Mask (1), Time-Zone (2), Domain-Name-Server (6), Hostname (12)
              Domain-Name (15), MTU (26), BR (28), Classless-Static-Route (121)
              Default-Gateway (3), Static-Route (33), YD (40), YS (41)
              NTP (42), Unknown (119), Classless-Static-Route-Microsoft (249), Unknown (252)
              RP (17)
            MSZ (57), length 2: 576
            Requested-IP (50), length 4: 192.168.1.99
            END (255), length 0
```

What dhclient sends:

```
# in another terminal: sudo dhclient -v enp12s0
$ sudo tcpdump -i enp12s0 -vvvn port 67 or port 68
tcpdump: listening on enp12s0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
11:20:15.835147 IP (tos 0x10, ttl 128, id 0, offset 0, flags [none], proto UDP (17), length 328)
    0.0.0.0.bootpc > 255.255.255.255.bootps: [udp sum ok] BOOTP/DHCP, Request from 3c:07:54:6f:15:85, length 300, xid 0x39a01019, Flags [none] (0x0000)
          Client-Ethernet-Address 3c:07:54:6f:15:85
          Vendor-rfc1048 Extensions
            Magic Cookie 0x63825363
            DHCP-Message (53), length 1: Request
            Requested-IP (50), length 4: 192.168.1.99
            Parameter-Request (55), length 13:
              Subnet-Mask (1), BR (28), Time-Zone (2), Classless-Static-Route (121)
              Domain-Name (15), Domain-Name-Server (6), Hostname (12), YD (40)
              YS (41), NTP (42), MTU (26), Unknown (119)
              Default-Gateway (3)
            END (255), length 0
            PAD (0), length 0, occurs 35
```

The line that the adtrans router doesn't like:

```
Client-ID (61), length 7: ether 3c:07:54:6f:15:85
```

This can be removed with the config:

```
# /etc/NetworkManager/conf.d/99-adtran-compat.conf
[connection]
ipv4.dhcp-client-id=none
```

After restarting NetworkManager with the new config:

```
$ sudo tcpdump -i enp12s0 -vvvn port 67 or port 68
tcpdump: listening on enp12s0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
11:02:57.938169 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto UDP (17), length 301)
    0.0.0.0.bootpc > 255.255.255.255.bootps: [udp sum ok] BOOTP/DHCP, Request from 3c:07:54:6f:15:85, length 273, xid 0xa885726a, secs 1, Flags [none] (0x0000)
          Client-Ethernet-Address 3c:07:54:6f:15:85
          Vendor-rfc1048 Extensions
            Magic Cookie 0x63825363
            DHCP-Message (53), length 1: Request
            Parameter-Request (55), length 17:
              Subnet-Mask (1), Time-Zone (2), Domain-Name-Server (6), Hostname (12)
              Domain-Name (15), MTU (26), BR (28), Classless-Static-Route (121)
              Default-Gateway (3), Static-Route (33), YD (40), YS (41)
              NTP (42), Unknown (119), Classless-Static-Route-Microsoft (249), Unknown (252)
              RP (17)
            MSZ (57), length 2: 576
            Requested-IP (50), length 4: 192.168.1.99
            END (255), length 0
```

Success!

Another alternative I didn't try was to make eero the primary router and configure the adtrans in bridge mode. I currently have the latter port forward to my web/ssh server.

Other configs that I tried for reference:

```
[main]
dhcp=internal

[connection]
# don't send, this works
ipv4.dhcp-client-id=none

# send a leading 01, some enterprise routers like this?
#ipv4.dhcp-client-id=01:48:a4:72:9a:f6:14

# use 4 digits of mac address instead of device id
# use a stable mac instead of a randomized one
#ipv4.dhcp-client-id=mac
#ipv4.dhcp-iaid=mac
#wifi.cloned-mac-address=permanent
#ethernet.cloned-mac-address=permanent
```

Useful commands for debugging:

```sh
$ nmcli con  # same as nmcli connection show
$ nmcli con up|down teatime5

$ systemctl restart NetworkManager
$ journalctl -u NetworkManager

$ sudo tcpdump -i enp12s0 -vvvn port 67 or port 68
```


