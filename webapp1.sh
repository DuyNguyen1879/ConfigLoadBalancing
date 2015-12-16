#!/bin/bash

hostnamectl set-hostname webapp1.nukeviet.vn

chmod +x /root/setup/module/*.sh
source /root/setup/config.sh

/root/setup/module/csf.sh
csf -a "$IP_LB1_NUKEVIET"
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

# Cấu hình lại PHP để gọi từ lb1:
source /root/setup/config.sh
sed -i "s/listen = 127.0.0.1:9000/listen = $IP_WEBAPP1_NUKEVIET:9000/g" /etc/php-fpm.d/www.conf
sed -i "s/listen.allowed_clients = 127.0.0.1/listen.allowed_clients = $IP_LB1_NUKEVIET/g" /etc/php-fpm.d/www.conf

/root/setup/module/nfs-client.sh
reboot
