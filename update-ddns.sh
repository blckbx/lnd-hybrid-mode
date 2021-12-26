#!/usr/bin/bash

# For some DDNS providers it is possible to trigger an IP update manually
# this script checks the current IP and compares it with the last one fetched.
# If it differs, new IP is saved and update-URL is triggered. DDNS provider fetches new IP.
# usage: setup script as cronjob every x hours

# local file to save and compare fetched external IP
FILE=$PWD/ip.txt
# Update-URL of DDNS provider, e.g.: https://<yourdnsprovider.com>/key=<accountsecret>&host=<yourdomain> (pls check readme/faq of your provider)
UPDATEURL=<UPDATE-URL>

newip=$(curl -s https://api.ipify.org)

if [[ ! -f "$FILE" ]]; then
    echo "null" > $FILE
fi

ip=$(cat $FILE)

if [[ "$ip" != "$newip" ]]; then
   echo $newip > $FILE
   echo "IP ("$newip") change detected"
   curl -s $UPDATEURL
else
   echo "No IP ("$newip") change detected"
fi
