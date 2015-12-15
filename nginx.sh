#!/bin/bash

# Scripts Viết cho cài đặt Server Tren CentOS 7 Cho NukeViet.

if [ $(id -u) != "0" ]; then
    printf "Ban phai dang nhap bang user root.\n"
    exit
fi

if [[ $(arch) != "x86_64" ]] ; then
	echo "NukeViet Script chi hoat dong tren CentOS 7.1 64bit."
	exit
fi

timedatectl set-timezone Asia/Ho_Chi_Minh

rm -f um.repos.d/nginx.repo
cat > "/etc/yum.repos.d/nginx.repo" <<END
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1
END

sudo yum install nginx git -y
sudo systemctl start nginx
sudo systemctl enable nginx

#Cấu hình worker_processes bằng số CPU của máy, tắt thông tin phiên bản của nginx
cpucores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
cat > "/etc/nginx/nginx.conf" <<END
user  nginx;
worker_processes  $cpucores;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
	worker_connections  1024;
}

http {
	include       /etc/nginx/mime.types;
	default_type  application/octet-stream;

	log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

	access_log  /var/log/nginx/access.log  main;

	sendfile        on;
	#tcp_nopush     on;

	keepalive_timeout  65;

	#gzip  on;

	server_tokens off;

	include /etc/nginx/conf.d/*.conf;
}
END


# Tạo thư mục chứa NukeViet, chạy với tất cả các domain thông qua truy cập vào IP
mkdir -p /home/nginx/nukeviet4/public_html
mkdir -p /home/nginx/nukeviet4/private_html
mkdir -p /home/nginx/nukeviet4/logs
chown -R nginx:nginx /home/nginx/
chown -R nginx:nginx /var/log/nginx
chown -R nginx:nginx /var/lib/php/session

cat > "/etc/nginx/conf.d/default.conf" <<END
upstream fpm_nukeviet {
	#ip_hash;
	server 127.0.0.1:9000;
	#server 192.168.56.101:9000;
	#server 192.168.56.102:9000;
}

server {
	listen       80;
	server_name  localhost;
	
	access_log /home/nginx/nukeviet4/logs/access.log combined buffer=256k flush=60m;
	error_log /home/nginx/nukeviet4/logs/error.log;

	root   /home/nginx/nukeviet4/public_html;
	index  index.html index.htm index.php;


	rewrite ^/(.*?)robots\.txt\$ /robots.php?action=\$http_host break;
	rewrite ^/(.*?)sitemap\.xml\$ /index.php?nv=SitemapIndex break;
	rewrite "^/(.*?)sitemap\-([a-z]{2})\.xml\$" /index.php?language=\$2&nv=SitemapIndex break;
	rewrite "^/(.*?)sitemap\-([a-z]{2})\.([a-zA-Z0-9-]+)\.xml\$" /index.php?language=\$2&nv=\$3&op=sitemap break;

	if (!-e \$request_filename){
		rewrite (.*)(\/|\.html)\$ /index.php;
		rewrite /(.*)tag/(.*)\$ /index.php;
		rewrite /install/(.*)(\.rewrite)$ /install/rewrite.php;
	}

	location ~ ^/admin/([a-z0-9]+)/(.*)\$ {
		deny all;
	}

	location ~ ^/(config|includes)/(.*)\$ {
		deny all;
	}

	location ~ ^/data/(cache|config|ip|ip6|logs)/(.*)\$ {
		deny all;
	}

	location ~ ^/(files|uploads|themes)/(.*).(php|ini|tpl|php3|php4|php5|phtml|shtml|inc|asp|aspx|pl|py|jsp|asp|sh|cgi)\$ {
		deny all;
	}	
	
	location ~ \.php$ {
		#fastcgi_pass   127.0.0.1:9000;
		fastcgi_pass	fpm_nukeviet;
		fastcgi_index  index.php;
		fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
		include        fastcgi_params;
	}

	location ~* \.(3gp|gif|jpg|jpeg|png|ico|wmv|avi|asf|asx|mpg|mpeg|mp4|pls|mp3|mid|wav|swf|flv|exe|zip|tar|rar|gz|tgz|bz2|uha|7z|doc|docx|xls|xlsx|pdf|iso)\$ {
		gzip_static off;
		#add_header Pragma public;
		add_header Cache-Control "public, must-revalidate, proxy-revalidate";
		access_log off;
		expires 30d;
		break;
	}

	location ~* \.(js|css|eot|svg|ttf|woff|woff2)$ {
		#add_header Pragma public;
		add_header Cache-Control "public, must-revalidate, proxy-revalidate";
		access_log off;
		expires 30d;
		break;
	}

	location ~* \.(html|htm|txt)$ {
		#add_header Pragma public;
		add_header Cache-Control "public, must-revalidate, proxy-revalidate";
		access_log off;
		expires 1d;
		break;
	}	
}

END

# Khởi động lại PHP-FPM
systemctl restart nginx
chown -R nginx:nginx /home/nginx/nukeviet4/public_html/