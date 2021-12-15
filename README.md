## LND: Tor & Clearnet - How to use hybrid mode

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
A word of caution: Running a node behind the Tor network offers many advantages (anonymity, security and usability) and is therefore the recommended way. For nodes with a high number of connected channels and/or high availability requirements Tor can be a hinderance. Tor's organic network is prone to law regulation and censorship of a country's internet service providers. LND also allows running clearnet nodes which do not make use of the Tor network but directly connect to peers. This requires node administrators to take care of the underlying system's security policies. At least one port (default: 9735) needs to be forwarded and exposed to be able to get connected from remote peers. Setting up a firewall is highly recommended. Not only security is a topic to be thought about, but also there is the risk of being localized by the clearnet IP.

## **Prerequisites:** ##
Hybrid mode was brought to life by Lightning Labs in version `0.14.0-beta`. 
