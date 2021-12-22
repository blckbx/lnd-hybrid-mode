## **Special Case: VPN Setup** ##
To prevent exposure of a node's real IP address connecting through VPN is an approach if anonymity is crucial. To achieve this, some preconditions must be checked and met:

- ✅ VPN server or provider is able to forward ports.
- ✅ VPN setup is able to split-tunnel processes.
- ✅ Home setup is able to forward specific ports (router/modem).
- ✅ Home setup is able to allow incoming traffic (firewall).

Check? Let's go!

0. Declarations
````
internal_port = Internal LND listening port (for easy setup: internal_port = port-forwarded-VPN_port, but does not necessarily have to be)
port_forwarded_VPN_port = VPN assigned forwarding port
static_VPN_IP = IP of your VPN service/provider
ddns_domain = DDNS (DNS domain) for IP resolution
````

1. Firewall: allowing incoming port
````
sudo ufw allow <internal_port> comment 'lnd-vpn-port'
sudo ufw reload
````

2. Router/Modem: forwarding / mapping internal port to VPN assigned port

This step is managed very individually due to high amount of routers and modems out there. Usually GUI-based webinterfaces let define ports to be forwarded for specific devices within a local network.


3. LND: configuring `lnd.conf` for VPN setup:
 - If VPN provides a static IP: 
````
...
[Application Options]
externalip=<static_VPN_IP>[:<port_forwarded_VPN_port>]
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
externalhosts=<ddns_domain>[:<port_forwarded_VPN_port>]
listen=0.0.0.0:<internal_port> // listen on IPv4 interface
#listen=[::1]:<internal_port> // listen on IPv6 interface, if used

[tor]
tor.skip-proxy-for-clearnet-targets=true
...
````
Note: Internal port and assigned VPN port are not necessarily the same. A router/modem may be configured to map any internal to any external port.


4. VPN: Configure VPN connection and check port reachability

Set up a VPN connection with whatever your VPN provider recommends (individual step). Check if the opened port is reachable from the outside by running `nc` (on Linux) and ping from the internet e.g. with [dnstools.ch](http://en.dnstools.ch/port-scan.html).
````
1. run: nc -l -p 9999 (9999 is port_forwarded_VPN_port)
2. ping port 9999 from the internet
````

5. Split-tunneling (depends on VPN client): Add Tor process to be excluded of VPN traffic manually (needs to be re-done on Tor restart!)

Most VPNs route all traffic through their network to protect against data leakage. In this case Tor traffic should be excluded from the VPN network because it is anonymized per se, we want to achieve split connectivity and therefore make use of faster clearnet responding times. 
````
pgrep -x tor // returns pid of tor process
<vpn cli split-tunnel command> pid add $(pgrep -x tor) // optional step: if VPN provider supports CLI this step can be automated in a script, e.g. after detecting a new VPN IP
````

6. Restart LND and watch logs for errors
````
tail -f ~/.lnd/logs/bitcoin/mainnet/lnd.log // adjust to your node setup
````

7. Lookup node addresses:

If everything is set, two uri addresses are displayed now. 
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

To test clearnet connectivity find and ask other clearnet peers to connect to your node, e.g.: `lncli connect <pubkey>@222.22.22.22:9999`
Successful connection:
````
lncli connect <pubkey>@222.22.22.22:9999
{

}
````
