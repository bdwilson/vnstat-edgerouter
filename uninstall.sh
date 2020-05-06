#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
        echo 'This script must be run by root' >&2
        exit 1
fi

echo 'Are you sure you would like to uninstall? (y/n)'
read answer
if [ "$answer" != "${answer#[Yy]}" ]; then
	echo 'Backing up vnstat data files to /config/vnstat'
	/config/scripts/backup.sh
	if [ -f /etc/vnstat.conf ]; then 
		cp -Rp /etc/vnstat.conf /config/vnstat
	fi 
	if [ -x /etc/init.d/vnstat ]; then
		service vnstat stop
		rm -f /etc/init.d/vnstat
	fi
	if [ -d /var/log/vnstat ]; then
		cp -Rp /var/log/vnstat /config
		rm -rf /var/log/vnstat
	fi 
	if [ -d /var/log/stat ]; then
		rm -rf /var/log/stat
	fi 
	if [ -L /var/www/htdocs/media/stat ]; then
		rm -f /var/www/htdocs/media/stat
	fi
	if [ -L /config/scripts/post-config.d/vnstat-restore.sh ]; then
		rm -f /config/scripts/post-config.d/vnstat-restore.sh
	fi
	OUT=`grep vnstat /etc/lighttpd/lighttpd.conf`
	RC=$?
	if [ ${RC} == 0 ]; then
    	echo 'Backing up /etc/lighttpd/lighttpd.conf to /etc/lighttpd/lighttpd.conf.vnstat'
        cp /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf.vnstat
		if [ -f /etc/lighttpd/lighttpd.conf.bak ]; then
			echo 'Found previous version of lighttpd.conf, restoring it.'
        	cp /etc/lighttpd/lighttpd.conf.bak /etc/lighttpd/lighttpd.conf
		else 
	        echo 'Removing vnstat configuration from /etc/lighttpd/lighttpd.conf'
			grep -v '/config/vnstat' /etc/lighttpd/lighttpd.conf.bak /etc/lighttpd/lighttpd.conf
		fi
        echo 'Restarting lighttpd'
        /bin/kill -SIGTERM `cat /var/run/lighttpd.pid`
        /usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf
	fi
	OUT=`grep "/config/vnstat/backup.sh" /var/spool/cron/crontabs/root`
	RC=$?
	if [ ${RC} == 0 ]; then
        echo 'Removing nightly cronjob to copy data files from RAM to disk'
		cp /var/spool/cron/crontabs/root /tmp/root.cron
		grep -v '/config/vnstat' /tmp/root.cron > /var/spool/cron/crontabs/root
	fi
	echo "You can now safely remove /config/vnstat directory. If you wish to reinstall, you should save this directory."
fi
