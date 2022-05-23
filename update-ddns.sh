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
sleep 10

# something went wrong, no IP returned
if [ "$newip" = "" ]; then
   exit 1
fi

# create temp file if not already present
if [ ! -f "$FILE" ]; then
    echo "null" > $FILE
fi

# get last saved IP from temp file
ip=$(cat $FILE)

# compare saved IP to new IP, call update-URL if they differ
if [ "$ip" != "$newip" ]; then
   echo $newip > $FILE
   echo "IP ("$newip") change detected"
   curl -s $UPDATEURL &>/dev/null
else
   echo "No IP ("$newip") change detected"
fi

exit 0
