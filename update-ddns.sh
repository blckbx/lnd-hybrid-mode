#!/usr/bin/bash

# for some DDNS providers there is the possibility to trigger an IP update manually
# this script checks the current IP and compares it to the last one fetched
# if it differs, new IP is saved and Update-URL is triggered. DDNS provider gets new IP.
# usage: set script in cronjob every x hours

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
