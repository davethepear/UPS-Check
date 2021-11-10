# UPS-Check
Check UPS Nut Server and decide what to do about it... 
### this is a work in progress!
feel free to ree, or contribute...

### Usage
if the command: `upsc servers@192.168.0.12:3493 ups.status` works, we're good.
yeah, your ip address and user name may be different... does it really need to be said?

find product and vendor id by typing `sudo usbreset`, it will look the same as the example.
```
./ups.sh -v
```
I poorly scripted the -v so I could check the status without cron emailing me

### Automation
this needs to be in `root's crontab` if you want the auto reset if the stale data bs shows up
```
sudo crontab -e
```
```
*/2 * * * * /home/user/scripts/ups.sh
```
your user name and directory could be different!


### Requirements
- nut
- nut-server
- nut-client
