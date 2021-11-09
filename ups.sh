#!/bin/sh
ups=192.168.0.12
port=3493
user=servers

nc -z $ups $port > /dev/null
if [ "$?" = "1" ]; then
echo "are you sure you have the right address and port? maybe the user is wrong?"
    exit 1
fi
timestamp=$( date +%T )
status=$( upsc $user@$ups:$port 2>&1 | grep -v '^Init SSL' | grep ups.status: | awk '{ print $2 }' )
if echo "$status" | grep 'OL' ; then
   echo Power is on... yay!
   exit 1
else
# Typical of me, I'm not sure about having it shutdown, so it's echoed. I've been having "data stale" problems.
   echo "shutdown -P" | mail -s "Is the power out?!" ubuntu
fi
# if the power is out... ask for percentaget of battery
batt=$( upsc $user@$ups:$port 2>&1 | grep -v '^Init SSL' | grep battery.charge: | awk '{ print $2 }' )
echo "$batt"
if [ "$batt" -gt "95" ]; then
    exit 1
else
# Again, the shutdown it echoed, but it emails me. Luckily the power's stayed on and I'm too lazy to unplug it.
    echo "shutdown -P" | mail -s "Is the power out? There is $batt percent left!" ubuntu
fi
