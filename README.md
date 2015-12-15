# LoadBalancing
Xây dựng hệ thống cân bằng tải cho NukeViet. http://wiki.nukeviet.vn/web_server:cai-dat-server-chi-tai-cao

Hướng dẫn cài đặt.

1) Tắt tính năng selinux: /etc/selinux/config bằng cách sửa chữ 
```
SELINUX=enforcing
```
Thành
```
SELINUX=disabled
```
Khởi động lại máy chủ.

2) Check out file cài đặt tự động 
```
yum install git -y
git clone https://github.com/nukeviet/LoadBalancing.git /root/setup/
```

Khai báo lại các thông số trong file config.sh

sau đó chúng ta chạy lần lượt tool cài đặt
```
chmod +x /root/setup/*.sh
/root/setup/csf.sh
/root/setup/php.sh
/root/setup/nginx.sh

````


