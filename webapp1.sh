#!/bin/bash

cd /root/setup/
chmod +x /root/setup/*.sh
/root/setup/csf.sh
/root/setup/php.sh
/root/setup/nginx.sh

# Cấu hình lại PHP để gọi từ lb1:
source /root/setup/config.sh
sed -i 's/listen = 127.0.0.1:9000/listen = "$IP_WEBAPP1_NUKEVIET":9000/g' /etc/php-fpm.d/www.conf
sed -i 's/listen.allowed_clients = 127.0.0.1/listen.allowed_clients = "$IP_LB1_NUKEVIET"/g' /etc/php-fpm.d/www.conf
reboot