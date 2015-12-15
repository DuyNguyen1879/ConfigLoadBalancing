#!/bin/sh

if [ -d "/home/nginx/nukeviet4/public_html" ]; then
	# Download phpMyAdmin
	cd /home/nginx/nukeviet4/public_html
	wget https://files.phpmyadmin.net/phpMyAdmin/4.5.2/phpMyAdmin-4.5.2-english.zip
	unzip phpMyAdmin-4.5.2-english.zip 
	mv /home/nginx/nukeviet4/public_html/phpMyAdmin-4.5.2-english /home/nginx/nukeviet4/public_html/phpMyAdmin
	chown -R nginx:nginx /home/nginx/nukeviet4/public_html/phpMyAdmin
	rm -f phpMyAdmin-4.5.2-english.zip
else
	echo "Chưa cài đặt nginx"
fi