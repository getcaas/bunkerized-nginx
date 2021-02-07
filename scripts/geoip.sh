#!/bin/sh

# load some functions
. /opt/scripts/utils.sh

# MMDB from https://db-ip.com/db/download/ip-to-country-lite
URL="https://download.db-ip.com/free/dbip-country-lite-$(date +%Y-%m).mmdb.gz"
wget -O /tmp/geoip.mmdb.gz "$URL" > /dev/null 2>&1
if [ "$?" -eq 0 ] && [ -f /tmp/geoip.mmdb.gz ] ; then
	gunzip -f /tmp/geoip.mmdb.gz > /dev/null 2>&1
	if [ "$?" -ne 0 ] ; then
		job_log "[GEOIP] can't extract DB from $URL"
		exit 1
	fi
	mv /tmp/geoip.mmdb /etc/nginx
	if [ -f /tmp/nginx.pid ] ; then
		/usr/sbin/nginx -s reload > /dev/null 2>&1
		if [ "$?" -eq 0 ] ; then
			cp /etc/nginx/geoip.mmdb /cache
			job_log "[NGINX] successfull nginx reload after GeoIP DB update"
		else
			job_log "[NGINX] failed nginx reload after GeoIP DB update"
			if [ -f /cache/geoip.mmdb ] ; then
				cp /cache/geoip.mmdb /etc/nginx/geoip.mmdb
				/usr/sbin/nginx -s reload > /dev/null 2>&1
			fi
		fi
	else
		cp /etc/nginx/geoip.mmdb /cache
	fi
else
	job_log "[GEOIP] can't download DB from $URL"
fi

rm -f /tmp/geoip* 2> /dev/null
