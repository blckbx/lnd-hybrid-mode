## How to set up hybrid mode on LND

_Proposed Agenda:_

- Caution clearnet! (security, exposure)
- Prerequisites: lnd-0.14.0-beta
- Pros and Cons of hybrid mode, esp. clearnet exposure
  - Availability despite Tor issues
  - therefore higher uptime
  - 
- Configuring LND.conf: 
  - nat/upnp
  - externalip
- Static VS Dynamic IPs
- Solution: DynDNS 
  - acquiring dyndns
  - externalhosts
  - NANN: LND's domain resolution
  - IP advertisement on platforms (Amboss, LN+, cheeserobot)
- 
