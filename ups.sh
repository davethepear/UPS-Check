#!/bin/sh
ups=192.168.0.12 # the ip or hostname of the nut server
port=3493 # the port used, especially through a firewall
user=servers # user name, set in upsd.users
pv=0764:0501 # product and vendor id of the ups
# read the readme?

nc -z $ups $port > /dev/null
if [ "$?" = "1" ]; then
    echo "Error: Server offline, wrong address and/or port, maybe the user is wrong?"
    exit 1
fi
timestamp=$( date +%T )
status=$( upsc $user@$ups:$port 2>&1 ups.status | grep -v '^Init SSL' )
if [ "$status" = "OL" ]; then
   if [ "$1" = "-v" ]; then echo "Power is on... yay!"; fi
   exit 1
elif [ "$status" = "OB" ]; then
# Typical of me, I am not sure about having it shutdown, so it is echoed. I've been having data stale problems.
   if [ "$1" = "-v" ]; then echo "On battery"; fi
   # echo "shutdown -P" | mail -s "Is the power out?!" ubuntu
   exit 1
else
   if [ "$1" = "-v" ]; then echo "Restarting UPS Daemon!"; fi
   /usr/bin/usbreset $pv
   /usr/bin/systemctl restart nut-driver
   exit 0
fi
# if the power is out... ask for percentaget of battery
batt=$( upsc $user@$ups:$port battery.charge 2>&1 | grep -v '^Init SSL' )
# I have the batt level set pretty high, just to get a response from it. if it works, I'll set it lower.
if [ "$batt" -gt "95" ]; then
   if [ "$1" = "-v" ]; then  echo "$batt"
   fi
    exit 1
else
# Again, the shutdown it echoed, but it emails me. Luckily the power's stayed on and I'm too lazy to unplug it.
    echo "shutdown -P" | mail -s "Is the power out? There is $batt percent left!" ubuntu
fi
