# vnstat-edgerouter
vnstat GUI for Ubiquiti Edgerouter

## Requirements

1. Enable debian packages on your EdgeOS device: https://help.ui.com/hc/en-us/articles/205202560-EdgeMAX-Add-other-Debian-packages-to-EdgeOS
2. SSH to your device and install vnstat and vnstati: <code> sudo apt-get -y install vnstat vnstati curl </code>
3. <code> curl -fsSLo /tmp/vnstat-edgerouter.run https://github.com/bdwilson/vnstat-edgerouter/raw/master/vnstat-edgerouger.run && sudo sh /tmp/vnstat-edgerouter.run </code>
4. If you don't want to run the above command, get the repo local to your device, perhaps in /tmp/vnstat, and run <code> sudo ./install.sh </code>

You should now be able to access http://your.router.ip/media/stat/ (it will take awhile to get stats unless you're upgrading). 

## Notes

This has only been tested on EdgeOS 1.x <b>NOT</b> 2.x. If you test it on 2.x, please let me know. It should be easy enough to uninstall if things don't work.

## Uninstall

SSH to your device and run <code> sudo /config/vnstat/uninstall.sh </code>

## Upgrading EdgeOS?

Make sure you run <code> sudo /config/vnstat/backup.sh </code> before you upgrade. After your upgrade you *shouldn't* have to do anything as there is a script <code> /config/scripts/post-config.d/vnstat-restore.sh </code> that will run on boot. If you've upgraded to an unsupported version where they made lighttpd changes. If you've done this, you may need to <code> sudo /config/vnstat/uninstall.sh </code> to debug the issue.

## Upgrading this code?

Re-run the installer (step #3) above.

