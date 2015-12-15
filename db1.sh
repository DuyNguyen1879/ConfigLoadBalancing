#!/bin/bash

hostnamectl set-hostname db1.nukeviet.vn

cd /root/setup/
chmod +x /root/setup/*.sh
/root/setup/csf.sh
/root/setup/php.sh
/root/setup/nginx.sh
/root/setup/phpMyAdmin.sh

# Khởi động lại PHP-FPM
systemctl restart php-fpm
systemctl restart nginx

/root/setup/mysql.sh