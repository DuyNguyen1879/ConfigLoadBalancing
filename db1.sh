#!/bin/bash

hostnamectl set-hostname db1.nukeviet.vn

cd /root/setup/
chmod +x /root/setup/*.sh
/root/setup/csf.sh
/root/setup/php.sh
/root/setup/nginx.sh
/root/setup/phpMyAdmin.sh
/root/setup/mysql.sh