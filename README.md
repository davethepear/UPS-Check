# UPS-Check
Check UPS Nut Server and decide what to do about it... this is a work in progress.

```
*/2 * * * * /home/user/scripts/ups.sh
```
if the command: `upsc servers@192.168.0.12:3493 ups.status` works, we're good.
yeah, your ip address and user name may be different... does it really need to be said?

find product and vendor id by typing `sudo usbreset`, it will look the same as the example.

this needs to be in `root's crontab` if you want the auto reset if the stale data bs shows up
```
sudo crontab -e
```

## Requirements
- nut
- nut-server
- nut-client
