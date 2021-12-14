## How to set up hybrid mode on LND

_Proposed Agenda:_

- Caution clearnet!
  - security: open incoming port
  - exposure to risk: localization
- Prerequisites: 
  - lnd-0.14.0-beta
- Pros and Cons of hybrid mode, esp. clearnet exposure
  - Availability despite Tor issues
  - therefore higher uptime
  - ...
- Configuring `lnd.conf: 
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
