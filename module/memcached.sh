#!/bin/sh

yum  install -y memcached
systemctl start memcached
systemctl enable memcached

# Mở để nhiều máy khác vào được
sed -i 's/OPTIONS=/#OPTIONS=/g' /etc/sysconfig/memcached
systemctl restart memcached