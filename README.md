# LoadBalancing
Xây dựng hệ thống cân bằng tải cho NukeViet. http://wiki.nukeviet.vn/web_server:cai-dat-server-chi-tai-cao

Hướng dẫn cài đặt cho các máy chủ.

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

Khai báo lại các thông số trong file config.sh, với các máy WEBAPP, DB nếu có IP nội bộ thì nên khai báo IP nội bộ để tốc độ nhanh và ổn định hơn.


3) Cài đặt đồng thời các máy, tương ứng với file

```
- db1.sh (Máy này sẽ cài lâu nhất do dơwnload MariDB chậm)
- lb1.sh
- webapp1.sh
- webapp1.sh
- db1.sh
```

Ví dụ server lb1.sh
```
chmod +x /root/setup/lb1.sh
/root/setup/lb1.sh

```

Với máy db1.sh, db2.sh sẽ hiện thị mật khẩu kết nối cần lưu lại các thông số này để cài đặt NukeViet.

4) Cài đặt NukeViet

5) Cấu hình cân bằng tải.




