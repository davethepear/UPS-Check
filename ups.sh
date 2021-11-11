#!/bin/sh
job=server # client OR server - is this a client only or is it on the server?
user=servers # user name, set in upsd.users
ups=192.168.0.12 # the ip or hostname of the nut server
port=3493 # the port used, especially through a firewall
pv=0764:0501 # product and vendor id of the ups
battlev=95 # the percentage of battery left before shutdown or whatever occurs
emailme=yes # yes OR no - do you want it to email you?
email=ubuntu # or your email addy, I use local mail
scriptdir=/home/ubuntu/scripts # where are you putting this file? no closing /
# read the readme?

nc -z $ups $port > /dev/null
if [ "$?" = "1" ]; then
    echo "Error: Server offline, wrong address and/or port, maybe the user is wrong?"
    exit 1
fi
timestamp=$( date +%T )
upsstatus=$(upsc $user@$ups:$port 2>&1 | grep -v '^Init SSL' | grep -E 'ups.status:|battery.charge:')
status=$(echo "$upsstatus" | grep "ups.status:" | awk '{ print $2 }')
batt=$(echo "$upsstatus" | grep "battery.charge:" | awk '{ print $2 }')
if [ "$status" = "OL" ]; then
   if [ "$1" = "-v" ]; then echo "Power is on... yay!"; fi
   if [ -f "$scriptdir/nomail" ]; then rm $scriptdir/nomail ; fi
   exit 0
elif [ "$status" = "OB" ]; then
# This will email me if we are on battery, it should only mail once.
   if [ "$1" = "-v" ]; then echo "On battery"; fi
    if [ "emailme" = "yes" ] && [ ! -f "$scriptdir/nomail" ]; then
       echo "The power may be out." | mail -s "Is the power out?! \n Battery is at: '$batt'%" $email
       touch $scriptdir/nomail
    fi
   # if the power is out... check for percentaget of battery
   # I have the batt level set pretty high, just to get a response from it. if it works, I'll set it lower.
   if [ "$batt" -gt "$battlev" ]; then
      if [ "$1" = "-v" ]; then  echo "Battery level: $batt%"; fi
      exit 0
   else
   # Again, the shutdown is echoed, but it emails me. Luckily the power's stayed on and I'm too lazy to unplug it.
       if [ "emailme" = "yes" ]; then echo "shutdown -P" | mail -s "Is the power out? The battery has $batt percent left!" $email ; fi
       # shutdown -P
       exit 0
   fi
else
   if [ "$job" = "client" ]; then exit 1; fi
   if [ "$1" = "-v" ]; then echo "Restarting UPS Daemon!"; fi
   /usr/bin/usbreset $pv
   if [ "emailme" = "no" ]; then /usr/bin/systemctl restart nut-driver 2>&1 ; fi
   if [ "emailme" = "yes" ]; then /usr/bin/systemctl restart nut-driver ; fi
   exit 1
fi
