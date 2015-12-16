#!/bin/bash

hostnamectl set-hostname db2.nukeviet.vn

chmod +x /root/setup/module/*.sh
source /root/setup/config.sh

/root/setup/module/csf.sh
csf -a "$IP_LB1_NUKEVIET"
csf -a "$IP_WEBAPP1_NUKEVIET"
csf -a "$IP_WEBAPP2_NUKEVIET"
if [ "$IP_WEBAPP3_NUKEVIET" != "" ]; then
	csf -a "$IP_WEBAPP3_NUKEVIET"
fi

csf -a "$IP_DB1_NUKEVIET"
if [ "$IP_DB3_NUKEVIET" != "" ]; then
	csf -a "$IP_DB3_NUKEVIET"
fi

csf -r

/root/setup/module/php.sh
/root/setup/module/nginx.sh
/root/setup/module/phpMyAdmin.sh

# Khởi động lại PHP-FPM
systemctl restart php-fpm
systemctl restart nginx

/root/setup/module/mysql.sh
