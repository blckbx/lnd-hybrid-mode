## LND: Tor & Clearnet - How to use hybrid-mode

_Proposed TOC:_

- Caution clearnet!
  - security: open incoming port
  - exposure to risk: localization
- Preconditions: 
  - lnd-0.14.0-beta
- Pros and Cons of hybrid mode, esp. clearnet exposure
  - Availability despite Tor issues
  - therefore higher uptime
  - ...
- Configuring `lnd.conf`: 
  - nat/upnp
  - externalip
- Static VS Dynamic IPs
- Solution: DynDNS 
  - acquiring dyndns
  - externalhosts
  - NANN: LND's domain resolution
  - IP advertisement on platforms (Amboss, 1ml)
- Special Case: VPN
  - port-forwarding VPN provider
  - configuring port in `lnd.conf`
- Specific Adjustments for Umbrel Users
  - Check for Tor settings
- Anything to add for cert / SSL settings (?)



## **Caution: Clearnet!** ##
A word of caution: Running a node behind the Tor network offers many advantages (anonymity, security and usability) and is therefore the recommended way. For nodes maintaining a high number of connected channels and/or have high availability requirements Tor can be a hindrance. Tor's organic network is prone to law regulation and censorship of a country's internet service providers. LND also allows running clearnet nodes that do not make use of the Tor network but directly connect to peers. This requires node administrators to take care of the underlying system's security policies. At least one port (default: 9735) needs to be forwarded and exposed to be able to get connected by remote peers. [Setting up a firewall](https://www.maketecheasier.com/how-to-set-up-firewall-linux/) is highly recommended. Not only security is a topic to be thought about, also the risk of being localized by clearnet IP. **Only use hybrid-mode if privacy is not of concern!**

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

## **Configuring `lnd.conf` for hybrid-mode:** ##
For LND to advertise a node's clearnet connectivity it needs to know the external IP to connect to. For the sake of convenience, we are assuming a static IP in this chapter. If this is not the case for you, an alternative approach (DDNS) is described in the following part. First `lnd.conf` needs to be configured by the following options: `externalip`, `nat`, `listen`, `tor.skip-proxy-for-clearnet-targets`. Notable that LND doesn't handle the setting of `externalip` and `nat` at the same time well. Choose only one of them, based on your router's UPnP capabilities ([nat description](https://docs.lightning.engineering/lightning-network-tools/lnd/nat_traversal)). Example configuration below:
````
[Application Options]
externalip=<staticIP>[:<port>] //e.g. 222.22.22.22 (port defaults to 9735, if not specified)
#nat=true
listen=ipv4/ipv6[:<port>]

[tor]
tor.active=true
tor.v3=true
tor.skip-proxy-for-clearnet-targets=true
...
````

## **Static vs Dynamic IP:** ##
Static IPs are rarely provided for home use internet connections. Most internet providers change IPs on a regular basis or reconnections. Therefore `externalip` in `lnd.conf` would have to be changed accordingly each time a new IP was assigned. Followed by a restart of `lnd.service`, which is needed to reload `lnd.conf`. This is unsustainable for continuous node running. One possible solution: DDNS

## **Dynamic DNS:** ##
_Dynamic DNS (DDNS) is a method of automatically updating a name server in the Domain Name System (DNS), often in real time, with the active DDNS configuration of its configured hostnames, addresses or other information._ ([src](https://en.wikipedia.org/wiki/Dynamic_DNS))

List of managed DNS providers: https://en.wikipedia.org/wiki/List_of_managed_DNS_providers

Self-hosted solutions: https://en.wikipedia.org/wiki/Comparison_of_DNS_server_software

A script or an app regularly fetches the client's current IP address which is saved for later requests. LND is able to resolve a given domain / DDNS to the actual IP address as well. Log output of `HostAnnouncer` listed below:
````
[DBG] NANN: HostAnnouncer checking for any IP changes...
[DBG] NANN: No IP changes detected for hosts: [ln.example.com]
...
[DBG] NANN: HostAnnouncer checking for any IP changes...
[DBG] NANN: IP change detected! ln.example.com:9735: 111.11.11.11:9735 -> 222.22.22.22:9735
````
Achieving this, `lnd.conf` needs to know domain for resolution:
````
[Application Options]
externalhosts=ln.example.com
````
Additionally a port can be specified if default port (9735) can not be used:
````
[Application Options]
externalhosts=ln.example.com:9999
````
Lightning explorers like [1ml.com](https://1ml.com) and [amboss.space](https://www.amboss.space) show and use IP addresses only. The node itself also makes use of the resolved IP address only (see `lncli getinfo`). Domains can be some fancy give-away for peering invitations on chat groups or printed on business cards ... who knows what it might be good for in the future.

## **Special Case: VPN Setup** ##
If anonymity is crucial, setting up clearnet behind a VPN could be a solution. To achieve this, some preconditions must be checked and met:

- [x] VPN server or provider is able to forward ports.
- [x] VPN setup is able to split-tunnel processes.
- [x] Home setup is able to forward specific ports (router/modem).
- [x] Home setup is able to allow incoming traffic (firewall).

If so, let's go!

1. Firewall: allowing incoming port
````
sudo ufw allow <vpn port> comment 'lnd-vpn-port'
sudo ufw reload
````
2. Router/Modem: forwarding VPN port

This step is managed very individually due to the huge amount of routers and modems out there. Usually GUI-based webinterfaces let define ports to be forwarded for specific devices within a local network.

3. LND: configuring `lnd.conf` for VPN setup (VPN-IP and VPN-Port):
 - If VPN provides static IPs: 
````
...
[Application Options]
externalip=<static_VPN_IP>[:<port-forwarded_VPN_port>]
listen=0.0.0.0:<internal_port> // listen on IPv4 interface
#listen=[::1]:<internal_port> // listen on IPv6 interface, if used

[tor]
tor.skip-proxy-for-clearnet-targets=true
...
````
 - If VPN provides dynamic IPs and a DDNS was claimed: 
````
...
[Application Options]
externalhosts=<ddns_domain>[:<port-forwarded_VPN_port>]
listen=0.0.0.0:<internal_port> // listen on IPv4 interface
#listen=[::1]:<internal_port> // listen on IPv6 interface, if used

[tor]
tor.skip-proxy-for-clearnet-targets=true
...
````
Note: Internal port and assigned VPN port are not necessarily the same. A router/modem may be configured to map any internal to any external port.

4. VPN: Configure VPN connection and test open port

Set up a VPN connection with whatever your VPN provider recommends (individual step). Check if the opened port is reachable from the outside by running `nc` (on Linux) and ping from the internet e.g. with [dnstools.ch](http://en.dnstools.ch/port-scan.html).
````
nc -l -p 9999
````


5. Split-tunneling (depends on VPN client usage): Add Tor process to be excluded of VPN traffic manually (needs to be re-done on Tor restart!)
````
pgrep -x tor // returns pid of tor process
<vpn cli> split-tunnel pid add $(pgrep -x tor) // optional step: if VPN provider supports CLI this step can be automated in a script
````

6. Restart LND and watch logs for errors
````
tail -f ~/.lnd/logs/bitcoin/mainnet/lnd.log // adjust to your node setup
````

7. Lookup node addresses:

If everything went well, two uri addresses are now displayed. 
````
$ lncli getinfo

"uris": [
        "<pubkey>@<onion-address>.onion:9735",
        "<pubkey>@222.22.22.22:9999"
    ],
````
Alternatively check listening ports with `netstat`:
````
netstat -tulpen | grep lnd
````
Result:
````
tcp6       0      0 :::9999                :::*                    LISTEN      1000       11111111   1111111/lnd
````

8. Check connectivity with clearnet peers

To test clearnet connectivity find and ask other clearnet peers to try to connect to your node, e.g.: `lncli connect <pubkey>@222.22.22.22:9999`

_______________________________________________________________

Written by [TrezorHannes](https://github.com/TrezorHannes) and [osito](https://github.com/blckbx).
