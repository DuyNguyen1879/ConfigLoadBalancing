#!/bin/sh

# Scripts Viết cho cài đặt Server Tren CentOS 7 Cho NukeViet.

if [ $(id -u) != "0" ]; then
    printf "Ban phai dang nhap bang user root.\n"
    exit
fi

if [[ $(arch) != "x86_64" ]] ; then
	echo "NukeViet Script chi hoat dong tren CentOS 7.1 64bit."
	exit
fi

# Cài đặt PHP
yum install epel-release -y
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

yum --enablerepo=remi,remi-php70 install -y php-fpm php-mysql php-common php-mbstring php-mcrypt php-gd php-xml php-zip php-memcached php-opcache

systemctl start php-fpm
systemctl enable php-fpm

sed -i 's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/g' /etc/php-fpm.d/www.conf

# Sua de thay IP tu dong
#sed -i 's/listen = 127.0.0.1:9000/listen = 192.168.56.101:9000/g' /etc/php-fpm.d/www.conf
#sed -i 's/listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 192.168.56.100/g' /etc/php-fpm.d/www.conf


sed -i 's/disable_functions =/disable_functions = show_source, system, shell_exec, passthru, exec, popen, proc_open/g' /etc/php.ini

# Khởi động lại PHP-FPM
systemctl restart php-fpm