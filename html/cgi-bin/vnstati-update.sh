#!/bin/sh
vnstati -s -i eth0 -o /var/log/stat/vnstat_img/vnstat-summary.png
vnstati -h -i eth0 -o /var/log/stat/vnstat_img/vnstat-hourly.png
vnstati -m -i eth0 -o /var/log/stat/vnstat_img/vnstat-monthly.png
vnstati -d -i eth0 -o /var/log/stat/vnstat_img/vnstat-daily.png
printf "Status: 200\r\n\r\n"
exit
