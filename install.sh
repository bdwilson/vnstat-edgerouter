#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
        echo 'This script must be run by root' >&2
        exit 1
fi

if [ ! -x /usr/bin/vnstat ] && [ ! -x /usr/bin/vnstati ]; then
        echo 'You need to install vnstat and vnstati on your device. Please see README.md for instructions.'
		echo 'Once you have your repos configured perform: sudo apt-get update; sudo apt-get install vnstati vnstat'
		exit 1
fi

if [ -d /config/vnstat ]; then
	echo 'It appears you already have this installed. Would you like to upgrade? (y/n)'
	read answer
	if [ "$answer" != "${answer#[Yy]}" ] ;then
		cp -Rp * /config/vnstat/
		if [ -f "/etc/vnstat.conf" ]; then
			echo 'Overwrіte /etc/vnstat.conf with the installers version (I will back up your installed version to /etc/vnstat.conf.bak either way)? (y/n)'
			read answer		
			if [ "$answer" != "${answer#[Yy]}" ] ;then
				cp -Rp /etc/vnstat.conf /etc/vnstat.conf.bak
				/config/vnstat/restore.sh
			else
				cp -Rp /etc/vnstat.conf /etc/vnstat.conf.bak
				/config/vnstat/restore.sh
				cp -Rp /etc/vnstat.conf.bak /etc/vnstat.conf
				service vnstat restart
			fi
		else
			/config/vnstat/restore.sh
		fi
	fi
else
	echo 'Would you like to install? (y/n)'
	read answer
	if [ "$answer" != "${answer#[Yy]}" ] ;then
		mkdir -p /config/vnstat
		cp -Rp * /config/vnstat/
		/config/vnstat/restore.sh
	fi
fi
	
