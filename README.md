# docker-nginx-gogs


docker run -d -p 10030:3000 -p 443:443 -v /Users/zyx/Documents/tempgit/gogs/docker-nginx-gogs:/data -v /Users/zyx/Documents/tempgit/gogs/docker-nginx-gogs/etc/nginx/nginx.conf:/etc/nginx/nginx.conf shuixin536/docker-nginx-gogs:public


需要宿主机访问可以使用添加参数-p 10030:3000 -p 10022:22 -p 10080:80 -p 10443:443 


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

