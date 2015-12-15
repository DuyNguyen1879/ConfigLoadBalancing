#!/bin/sh

IP_LB1_NUKEVIET="103.255.236.130"
IP_WEBAPP1_NUKEVIET="103.255.236.131"
IP_WEBAPP2_NUKEVIET="103.255.236.132"
IP_WEBAPP3_NUKEVIET=""
IP_DB1_NUKEVIET="103.255.236.133"
IP_DB2_NUKEVIET="103.255.236.134"
IP_DB3_NUKEVIET=""

if [ $(id -u) != "0" ]; then
    printf "Ban phai dang nhap bang user root.\n"
    exit
fi

if [[ $(arch) != "x86_64" ]] ; then
	echo "NukeViet Script chi hoat dong tren CentOS 7.1 64bit."
	exit
fi

timedatectl set-timezone Asia/Ho_Chi_Minh