#!/bin/bash

hostnamectl set-hostname lb1.nukeviet.vn

chmod +x /root/setup/module/*.sh
source /root/setup/config.sh

/root/setup/module/csf.sh

csf -a "$IP_WEBAPP1_NUKEVIET"
csf -a "$IP_WEBAPP2_NUKEVIET"
csf -a "$IP_DB1_NUKEVIET"
csf -a "$IP_DB2_NUKEVIET"

if [ "$IP_WEBAPP3_NUKEVIET" != "" ]; then
	csf -a "$IP_WEBAPP3_NUKEVIET"
fi

if [ "$IP_DB3_NUKEVIET" != "" ]; then
	csf -a "$IP_DB3_NUKEVIET"
fi

csf -r

/root/setup/module/php.sh
/root/setup/module/nginx.sh
/root/setup/module/memcached.sh
/root/setup/module/nfs-server.sh

# Khởi động lại PHP-FPM
systemctl restart php-fpm
systemctl restart nginx
reboot
