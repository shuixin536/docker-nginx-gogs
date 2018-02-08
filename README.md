# docker-nginx-gogs

```
docker run -d -p 10030:3000 -p 10443:443 -v /Users/zyx/Documents/tempgit/gogs/docker-nginx-gogs:/data -v /Users/zyx/Documents/tempgit/gogs/docker-nginx-gogs/etc/nginx/nginx.conf:/etc/nginx/nginx.conf shuixin536/docker-nginx-gogs:public
```

需要宿主机访问可以使用添加参数-p 10030:3000 -p 10022:22 -p 10080:80 -p 10443:443 

docker内部对外端口
ssh 22
gogs 3000
https 443

外部需要配置的东西，该git server只支持https
1. https证书，目录根据volume映射，保证路径所在目录/data/cert/github.example.win.pem
```
-v /Users/zyx/Documents/tempgit/gogs/docker-nginx-gogs:/data
```

2. 需要映射volume的nginx
```
-v /Users/zyx/Documents/tempgit/gogs/docker-nginx-gogs/etc/nginx/nginx.conf:/etc/nginx/nginx.conf
```

nginx.conf 的样例，修改
1. https证书：/data/cert/github.example.win.pem
2. 域名：github.example.win
```
#user  nobody;
worker_processes  4;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    send_timeout 1800;
    sendfile        on;
    keepalive_timeout  6500;
    
    server {
			server_name _; # This is just an invalid value which will never trigger on a real hostname.
			listen 80;
			#access_log /var/log/nginx/access.log vhost;
			return 503;
		}
		# github.example.win
		upstream github.example.win {
						## Can be connect with "bridge" network
					# clever_panini
					server 0.0.0.0:3000;
		}
		
		server {
		    listen 80;
		    server_name github.example.win;
		    return 302 https://$server_name$request_uri;
		}
    # HTTPS server
    server {
        listen       443;
        server_name  github.example.win;

        ssl                  on;
        ssl_certificate      /data/cert/github.example.win.pem;
        ssl_certificate_key  /data/cert/github.example.win.key;

        location / {
          proxy_pass          http://github.example.win;
          proxy_set_header    X-Real-IP        $remote_addr;
        }
    }
}
```


安装完成以后在浏览器打开
https://github.example.win:443
这里的端口看实际情况域名跳转了

第一次打开时候会自动跳转到
https://github.example.win:443/install
数据库类型选择为sqlite3
数据库路径存储为/data/gogs.db，这个是用来存储后续注册用户信息的；放置在/data目录，在宿主机中也可以访问
仓库根目录修改为/data/gogs-repositories，也方便宿主机备份
运行系统用户，保持不修改，但是在点击保存时候会报错，提示正确的系统用户，修改为提示用户即可
应用 URL修改为https://github.example.win:4443即可

管理员帐号设置---默认新建的第一个用户就是管理员；也可以在这里创建一个