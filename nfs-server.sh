#!/bin/sh

# Chúng ta cần phải cài đặt các gói NFS trên máy chủ NFS, cài đặt nó bằng cách sử dụng lệnh sau đây. 
yum install -y nfs-utils nfs-utils-lib libnfsidmap

#Cấu hình dưới dạng dịch vụ dịch vụ NFS.

systemctl enable rpcbind
systemctl enable nfs-server
#systemctl enable nfs-lock
#systemctl enable nfs-idmap

systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap

source $(dirname $0)/config.sh


#Chúng ta phải thay đổi “/etc/exports” tập tin để thực hiện một mục của thư mục “/home/nginx/nukeviet4/public_html” mà bạn muốn chia sẻ. 

if [ "$IP_WEBAPP3_NUKEVIET" != "" ]; then

cat > "/etc/exports" <<END
/home/nginx/nukeviet4/public_html $IP_WEBAPP1_NUKEVIET(rw,sync,no_root_squash)
/home/nginx/nukeviet4/public_html $IP_WEBAPP2_NUKEVIET(rw,sync,no_root_squash)
/home/nginx/nukeviet4/public_html $IP_WEBAPP3_NUKEVIET(rw,sync,no_root_squash)
END

else

cat > "/etc/exports" <<END
/home/nginx/nukeviet4/public_html $IP_WEBAPP1_NUKEVIET(rw,sync,no_root_squash)
/home/nginx/nukeviet4/public_html $IP_WEBAPP2_NUKEVIET(rw,sync,no_root_squash)
END

fi

systemctl restart nfs-server