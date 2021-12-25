#!/usr/bin/bash

# For some DDNS providers it is possible to trigger an IP update manually
# this script checks the current IP and compares it with the last one fetched.
# If it differs, new IP is saved and update-URL is triggered. DDNS provider fetches new IP.
# usage: setup script as cronjob every x hours

FILE=$PWD/ip.txt
UPDATEURL=<UPDATE-URL>

newip=$(curl -s https://api.ipify.org)

# if [[ ! -f "$FILE" ]]; then 
#    echo "null" > $FILE
# fi

ip=$(cat $FILE)

if [[ "$ip" != "$newip" ]]; then
   echo $newip > $FILE
   echo "IP ("$newip") change detected"
   curl -s $UPDATEURL
else
   echo "No IP ("$newip") change detected"
fi
