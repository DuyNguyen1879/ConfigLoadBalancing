#!/bin/bash

cd /root/setup/
chmod +x /root/setup/*.sh
/root/setup/csf.sh
/root/setup/php.sh
/root/setup/nginx.sh
/root/setup/memcached.sh
/root/setup/nfs-server.sh

# Khởi động lại PHP-FPM
systemctl restart php-fpm
systemctl restart nginx
reboot