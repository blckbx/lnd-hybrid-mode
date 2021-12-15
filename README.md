## LND: Tor & Clearnet - How to use hybrid-mode

_Proposed TOC:_

- Caution clearnet!
  - security: open incoming port
  - exposure to risk: localization
- Prerequisites: 
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
  - IP advertisement on platforms (Amboss, LN+, cheeserobot)
- Special Case: VPN
  - port-forwarding VPN provider
  - configuring port in `lnd.conf`



## **Caution: Clearnet!** ##
A word of caution: Running a node behind the Tor network offers many advantages (anonymity, security and usability) and is therefore the recommended way. For nodes with a high number of connected channels and/or high availability requirements Tor can be a hinderance. Tor's organic network is prone to law regulation and censorship of a country's internet service providers. LND also allows running clearnet nodes which do not make use of the Tor network but directly connect to peers. This requires node administrators to take care of the underlying system's security policies. At least one port (default: 9735) needs to be forwarded and exposed to be able to get connected from remote peers. Setting up a firewall is highly recommended. Not only security is a topic to be thought about, but also there is the risk of being localized by clearnet IP.

## **Prerequisites:** ##
Hybrid mode was brought to life by Lightning Labs in version `0.14.0-beta`. 

## **Configuring `lnd.conf` for hybrid-mode:** ##
...

## **Static vs Dynamic IP:** ##
Static IPs are rarely provided for home used internet connections. Most internet provider change IPs on a regular basis or on reconnections. `externalip` in `lnd.conf` would have to be changed accordingly each time a new IP is assigned. Of cource a restart of the lnd.service is needed as well. This is unsustainable for 
continuous node running. A solution to this is: DDNS

## **Dynamic DNS:** ##
Dynamic DNS (DDNS) is a method of automatically updating a name server in the Domain Name System (DNS), often in real time, with the active DDNS configuration of its configured hostnames, addresses or other information. ([src](https://en.wikipedia.org/wiki/Dynamic_DNS))

List of managed DNS providers: https://en.wikipedia.org/wiki/List_of_managed_DNS_providers

Self-hosted solutions: https://en.wikipedia.org/wiki/Comparison_of_DNS_server_software

A script or an app regularly queries an URL to gather the client's current IP address. The IP is saved into a database for later use. LND is able to resolve a given domain / DDNS to its actual IP address. 
````
[DBG] NANN: HostAnnouncer checking for any IP changes...
[DBG] NANN: No IP changes detected for hosts: [ln.example.com]
...
[DBG] NANN: HostAnnouncer checking for any IP changes...
[DBG] NANN: IP change detected! ln.example.com:9735: 111.11.11.11:9735 -> 111.11.11.12:9735
````
To achieve this, `lnd.conf` needs to know the domain for resolution:
````
[Application Options]
externalhosts=ln.example.com
````
Additionally a port can be specified, if the default port (9735) can not be used:
````
[Application Options]
externalhosts=ln.example.com:9999
````


