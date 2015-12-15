#!/bin/sh

# Chúng ta cần phải cài đặt các gói NFS trên máy chủ NFS, cài đặt nó bằng cách sử dụng lệnh sau đây. 
yum install -y nfs-utils nfs-utils-lib libnfsidmap
yum install -y nfs-utils libnfsidmap

#Cấu hình dưới dạng dịch vụ dịch vụ NFS.

systemctl enable rpcbind
systemctl start rpcbind

source $(dirname $0)/config.sh

sleep 5
logshowmount="$( ( showmount -e "$IP_LB1_NUKEVIET" ) 2>&1 )"
if [[ $logshowmount == *"Export list for $IP_LB1_NUKEVIET"* ]]
then
	echo "showmount ok: $logshowmount"
	mkdir -p /home/nginx/nukeviet4/public_html
	chown -R nginx:nginx /home/nginx/nukeviet4/public_html
	mount -t nfs "$IP_LB1_NUKEVIET:/home/nginx/nukeviet4/public_html" /home/nginx/nukeviet4/public_html
	echo "$IP_LB1_NUKEVIET:/home/nginx/nukeviet4/public_html /home/nginx/nukeviet4/public_html nfs rw,sync,hard,intr 0 0" >> "/etc/fstab"
fi
