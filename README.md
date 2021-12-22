# LND: Tor & Clearnet - How to setup hybrid-mode

## Prelude and Objective ##
The lightning network functions in rapid growing speed as infrastructure for payments across the globe between merchants, creators, consumers, institutions and investors alike. Hence the key pillars of sustained growth are their nodes, by providing _reliable_, _liquid_, _discoverable_ and _trustless_ connection points between those parties.

While a growing number of nodes [come online](https://studio.glassnode.com/metrics?a=BTC&category=Lightning&m=lightning.ChannelsCount&zoom=all) every day, a significant share of those are using [Tor](https://www.torproject.org/), which allows them to remain anonymous in a sense that they don't need to reveal their real IP address (aka Clearnet IP). However, this methodology paired with the increased demand for Bitcoin payments will continue to stretch Tor's capacity to cater for continued need of supply. It also hampers existing and new node's metric of success being a _reliable_ and _fast_ peering partner.

To mitigate some of ongoing Tor capacity constraints, a node runner may choose to reconsider (see [Chapter Caution: Clearnet!](#caution-clearnet) offering both, a Tor as well as a Clearnet IP connection option. Next to the drawbacks outlined in the first section below, it has three main net benefits 
1. allows for alternative discovery, routing and peering in case your own Tor cluster is affected by capacity constraints. Even though mostly temporarily, it cuts into your _reliability_
2. provides quicker [routing of HTLCs](https://blog.lnrouter.app/htlc-response-time), both for payment and probing. Quite nervous waiting 8 seconds for your transfer confirmation at the supermarket or bar, isn't it?
3. offers other clearnet-only nodes to connect directly to you. Otherwise it would be required for you as Tor-only to peer-connect to them first, before they can open a channel

With those considerations in mind, have a careful read through the words of caution below, make an educated decision by yourself, and then use our guide below on how to enable a hybrid Tor & Clearnet Node.


## Table of Content ##

- [Prelude and Objective](#prelude-and-objective)
- [Caution clearnet!](#caution-clearnet)
- [Preconditions](#preconditions)
- [Configuring hybrid-mode: ](#configuring-hybrid-mode)
  - [Static IP](#static-ip)
  - [Dynamic IP: Solution 1 - NAT/UPnP](#dynamic-ip-solution-1---natupnp)
  - [Dynamic IP: Solution 2 - Dynamic DNS (DDNS)](#dynamic-ip-solution-2---dynamic-dns-ddns)
- Specific Adjustments for Umbrel Users (_Still to be added_)
  - Check for Tor settings
- [Wrap-Up](#wrap-up)


## **Caution: Clearnet!** ##
A word of caution: Running a node behind the Tor network offers many advantages (anonymity, security and usability) and is therefore the recommended way. For nodes maintaining a high number of connected channels and/or have high availability requirements Tor can be a hindrance. Tor's organic network is prone to censorship of a country's internet service providers and internal failures of circuits and relays. LND also allows running clearnet nodes that do not make use of the Tor network but directly connect to peers. This requires node administrators to take care of the underlying system's security policies. At least one port (default: 9735) needs to be forwarded and exposed for remote peers to connect to. [Setting up a firewall](https://www.maketecheasier.com/how-to-set-up-firewall-linux/) is highly recommended. Not only security is a topic to be thought about, also the risk of being localized by clearnet IP. **Only use hybrid-mode if privacy is not of concern!**

## **Preconditions:** ##
[Hybrid-mode](https://docs.lightning.engineering/lightning-network-tools/lnd/quick-tor-setup#hybrid-mode) was brought to life in LND by Lightning Labs in version `lnd-0.14.0-beta`. A new option was introduced to split connectivity and to separately address Tor-only peers via Tor and clearnet peers via clearnet:
````
[tor]

; Allow the node to connect to non-onion services directly via clearnet. This
; allows the node operator to use direct connections to peers not running behind
; Tor, thus allowing lower latency and better connection stability.
; WARNING: This option will reveal the source IP address of the node, and should
; be used only if privacy is not a concern.

tor.skip-proxy-for-clearnet-targets=true
````
For this guide the following is required:
- A fully installed and synchronized node (raspiblitz/umbrel/custom)
-


## **Configuring hybrid-mode:** ##
Advertising clearnet connectivity LND needs to know the external IP of a node. There are two different cases to investigate: static and dynamic IP connections.

Static IPs are rather easy to set in LND. The external IP address has to be applied to LND's option `externalip`. That's almost it. But most internet providers change IPs on a regular basis or at least on reconnection. Therefore `externalip` in `lnd.conf` would have to be changed accordingly each time a new IP was assigned, followed by a restart of `lnd.service`, which is needed to reload `lnd.conf`. This is unsustainable for continuous node running. Two possible solutions to prevent re-editing and restarting LND: 
- [Solution 1: NAT/UPnP](#dynamic-ip-solution-1---natupnp)
- [Solution 2: Dynamic DNS (DDNS)](#dynamic-ip-solution-2---dynamic-dns-ddns)

### *Static IP:* ###
Static IPs are rarely provided for home use internet connections. It is a feature mostly offered to cable or business connections. Having a static IP makes configuring of `lnd.conf` much easier. In this case option `externalip` needs a closer look.
````
; Adding an external IP will advertise your node to the network. This signals
; that your node is available to accept incoming channels. If you don't wish to
; advertise your node, this value doesn't need to be set. Unless specified
; (with host:port notation), the default port (9735) will be added to the
; address.
; externalip=
````

### *Dynamic IP: Solution 1 - NAT/UPnP:* ###
Dealing with dynamic IPs tends to be a bit more complex. LND provides an integrated approach to this: NAT. NAT tries to resolve dynamic IPs utilising built-in techniques in order to fetch a node's external IP address. Notable that LND doesn't handle the setting of `externalip` and `nat` at the same time well. Choose only one of them, based on your router's UPnP capabilities ([nat traversal](https://docs.lightning.engineering/lightning-network-tools/lnd/nat_traversal)).
````
; Instead of explicitly stating your external IP address, you can also enable
; UPnP or NAT-PMP support on the daemon. Both techniques will be tried and
; require proper hardware support. In order to detect this hardware support,
; `lnd` uses a dependency that retrieves the router's gateway address by using
; different built-in binaries in each platform. Therefore, it is possible that
; we are unable to detect the hardware and `lnd` will exit with an error
; indicating this. This option will automatically retrieve your external IP
; address, even after it has changed in the case of dynamic IPs, and advertise
; it to the network using the ports the daemon is listening on. This does not
; support devices behind multiple NATs.
; nat=true
````

### *Dynamic IP: Solution 2 - Dynamic DNS (DDNS):* ###
_Dynamic DNS (DDNS) is a method of automatically updating a name server in the Domain Name System (DNS), often in real time, with the active DDNS configuration of its configured hostnames, addresses or other information._ ([src](https://en.wikipedia.org/wiki/Dynamic_DNS))

 - [List of managed DNS providers](https://en.wikipedia.org/wiki/List_of_managed_DNS_providers)
 - [Self-hosted solutions](https://en.wikipedia.org/wiki/Comparison_of_DNS_server_software)

A script or an app regularly fetches the client's current IP address which is saved for later requests. LND is able to resolve a given domain / DDNS to the actual IP address as well. Log output of `HostAnnouncer` listed below:
````
[DBG] NANN: HostAnnouncer checking for any IP changes...
[DBG] NANN: No IP changes detected for hosts: [ln.example.com]
...
[DBG] NANN: HostAnnouncer checking for any IP changes...
[DBG] NANN: IP change detected! ln.example.com:9735: 111.11.11.11:9735 -> 222.22.22.22:9735
````
In this case `lnd.conf` needs to know a reserved DNS domain instead of an external IP. Option `externalhosts` has to be set:
````
[Application Options]
# specify DDNS domain (port is optional)
externalhosts=ln.example.com:9735
````

Lightning explorers like [1ml.com](https://1ml.com) and [amboss.space](https://www.amboss.space) show and use IP addresses only. The node itself also only makes use of the resolved IP addresses (see `lncli getinfo`). Domains can be some fancy giveaway for peering invitations on chat groups or printed on business cards ... who knows what it might be good for in the future.

## **Wrap-Up:** ##

Summing up the introduced LND options in this article, here are some examples of complete configurations:

*Static IP:*
````
[Application Options]
# specify an external IP address e.g. 222.22.22.22:9735
externalip=222.22.22.22:9735
# specify an interface (IPv4/IPv6) and port (default 9735) to listen on
listen=0.0.0.0:9735 # listen on IPv4 interface or listen=[::1]:9735 for IPv6 interface

[tor]
tor.active=true
tor.v3=true
# activate split connectivity
tor.skip-proxy-for-clearnet-targets=true
````

*Dynamic IP - NAT:*
````
[Application Options]
# specify an interface (IPv4/IPv6) and port (default 9735) to listen on
listen=0.0.0.0:9735 # listen on IPv4 interface or listen=[::1]:9735 for IPv6 interface
nat=true

[tor]
tor.active=true
tor.v3=true
# activate split connectivity
tor.skip-proxy-for-clearnet-targets=true
````

*Dynamic IP - DDNS:*
````
[Application Options]
# specify an interface (IPv4/IPv6) and port (default 9735) to listen on
listen=0.0.0.0:9735 # listen on IPv4 interface or listen=[::1]:9735 for IPv6 interface
externalhosts=ln.example.com:9735

[tor]
tor.active=true
tor.v3=true
# activate split connectivity
tor.skip-proxy-for-clearnet-targets=true
````

After restarting LND is now offering two ways to connect (URIs). These can be verified by typing `lncli getinfo`:
````
"uris": [
        "<pubkey>@<onion-address>.onion:9735",
        "<pubkey>@222.22.22.22:9735"
    ],
````

_______________________________________________________________

Written by [TrezorHannes](https://github.com/TrezorHannes) and [osito](https://github.com/blckbx).
