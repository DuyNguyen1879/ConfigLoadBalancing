#!/bin/sh

# Scripts Viết cho cài đặt Server Tren CentOS 7 Cho NukeViet.
if [ $(id -u) != "0" ]; then
    printf "Ban phai dang nhap bang user root.\n"
    exit
fi

printf "=========================================================================\n"
printf "Cai dat CSF... \n"
printf "=========================================================================\n"

# In case if firewall already comes built-in with your CentOS installation, then stop its service with this command:
systemctl disable firewalld
systemctl stop firewalld

#install iptables via yum command:
yum -y install iptables-services

#Create necessary files which are needed by ip-tables.
touch /etc/sysconfig/iptables
touch /etc/sysconfig/iptables6

#You can now safely start iptables service using sytemctl command:
systemctl start iptables
systemctl start ip6tables

#To make sure iptables service always runs each time your server reboot, then do this:
systemctl enable iptables
systemctl enable ip6tables

#Install the CSF dependencies.
yum -y install wget perl unzip net-tools perl-libwww-perl perl-LWP-Protocol-https perl-GDGraph -y

#Download and launch the CSF installer.
cd /opt
wget https://download.configserver.com/csf.tgz
tar -xzf csf.tgz
cd csf
sh install.sh

#Remove the installation files.
rm -rf /opt/csf
rm /opt/csf.tgz 

#Do not forget to firstly test if CSF can really work on your CentOS server:
perl /usr/local/csf/bin/csftest.pl

sed -i 's/TESTING = "1"/TESTING = "0"/g' /etc/csf/csf.conf

#Restart CSF service:
systemctl restart csf.service

source /root/setup/config.sh

csf -a "$IP_LB1_NUKEVIET"
csf -a "$IP_WEBAPP1_NUKEVIET"
csf -a "$IP_WEBAPP2_NUKEVIET"
csf -a "$IP_DB1_NUKEVIET"
csf -a "$IP_DB2_NUKEVIET"

if [ "$IP_WEBAPP1_NUKEVIET" != "" ]; then
	csf -a "$IP_WEBAPP3_NUKEVIET"
fi
if [ "$IP_DB3_NUKEVIET" != "" ]; then
	csf -a "$IP_DB3_NUKEVIET"
fi

csf -r