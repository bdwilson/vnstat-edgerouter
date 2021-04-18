#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
        echo 'This script must be run by root' >&2
        exit 1
fi

if [ ! -x /usr/bin/vnstat ] && [ ! -x /usr/bin/vnstati ]; then
	echo 'You need to install vnstat and vnstati on your device. Please see README.md'
else 
	cp /config/vnstat/vnstat.conf /etc
	chmod 755 /etc/vnstat.conf
	if [ ! -x /etc/init.d/vnstat ]; then
		cp /config/vnstat/vnstat.init /etc/init.d/vnstat
		service vnstat restart
	fi
	if [ ! -d /var/log/vnstat ]; then
		mkdir -p /var/log/vnstat
	fi 
	chmod 755 /var/log/vnstat
	if [ ! -d /var/log/stat ]; then
		mkdir -p /var/log/stat
		cp -Rp /config/vnstat/html/* /var/log/stat
	fi 
	chmod -R 755 /var/log/stat
	chmod 775 /var/log/stat/vnstat_img
	chgrp www-data /var/log/stat/vnstat_img
	if [ ! -L /var/www/htdocs/media/stat ]; then
		ln -s /var/log/stat /var/www/htdocs/media
	fi
	if [ -f /config/vnstat/eth0 ]; then
		echo 'Restoring backup of vnstat data file'
		cp -Rp /config/vnstat/eth0 /var/log/vnstat
		chmod 755 /var/log/vnstat/eth0
		service vnstat restart
	fi
	if [ ! -L /var/www/htdocs/media/stat ]; then
		ln -s /var/log/stat /var/www/htdocs/media
	fi
	if [ ! -L /config/scripts/post-config.d/vnstat-restore.sh ]; then
		ln -s /config/vnstat/restore.sh /config/scripts/post-config.d/vnstat-restore.sh
	fi

	# update lighttpd config
	OUT=`grep vnstat /etc/lighttpd/lighttpd.conf`
	RC=$?
	if [ ${RC} != 0 ] ; then
		if [ -f "/config/vnstat/lighttpd.conf" ]; then
			echo 'Backing up original /etc/lighttpd/lighttpd.conf to /etc/lighttpd/lighttpd.conf.bak'
			cp /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf.bak
			echo 'Updating /etc/lighttpd/lighttpd.conf'
			echo 'include "/config/vnstat/lighttpd.conf"' >> /etc/lighttpd/lighttpd.conf
			echo 'Restarting lighttpd'
			/bin/kill -SIGTERM `cat /var/run/lighttpd.pid`
			/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf
		else
			echo '/config/vnstat/lighttpd.conf not found. Incorrect vnstat installation'
		fi
	fi
	
	# update cron	
	OUT=`grep "/config/vnstat/backup.sh" /var/spool/cron/crontabs/root`
	RC=$?
	if [ ${RC} != 0 ] ; then
		echo 'Adding nightly cronjob to copy data files from RAM to disk'
		echo '23 11 * * * /config/vnstat/backup.sh' >> /var/spool/cron/crontabs/root 
	fi

    # create initial vnstat file if it doesn't exist.
	if [ ! -f /var/log/vnstat/eth0 ]; then
		vnstat -u -i eth0
	fi
fi
