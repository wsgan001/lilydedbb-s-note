# nginx反向代理

## 正向代理与反向代理

### 正向代理的概念

`正向代理`，也就是代理,工作原理就像一个跳板，简单的说，我是一个用户，我访问不了某网站，但是我能访问一个代理服务器，这个代理服务器呢，他能访问那个我不能访问的网站，于是我先连上代理服务器，告诉他我需要那个无法访问网站的内容，代理服务器去取回来，然后返回给我。从网站的角度，只在代理服务器来取内容的时候有一次记录，有时候并不知道是用户的请求，也隐藏了用户的资料，这取决于代理告不告诉网站。

结论就是：`正向代理`是一个位于客户端和`原始服务器(origin server)`之间的服务器，为了从原始服务器取得内容，客户端向代理发送一个请求并指定目标(原始服务器)，然后代理向原始服务器转交请求并将获得的内容返回给客户端。客户端必须要进行一些特别的设置才能使用正向代理。

### 反向代理的概念

`反向代理（Reverse Proxy）`方式是指用代理服务器来接受`internet`上的连接请求，然后将请求转发给内部网络上的服务器，并将从服务器上得到的结果返回给```internet```上请求连接的客户端，此时代理服务器对外就表现为一个反向代理服务器。

举个例子，一个用户访问`http://www.example.com/readme`，但是 `www.example.com` 上并不存在 `readme` 页面，它是偷偷从另外一台服务器上取回来，然后作为自己的内容返回给用户。但是用户并不知情这个过程。对用户来说，就像是直接从 `www.example.com` 获取 `readme` 页面一样。这里所提到的 `www.example.com` 这个域名对应的服务器就设置了反向代理功能。

结论就是：`反向代理`正好相反，对于客户端而言它就像是原始服务器，并且客户端不需要进行任何特别的设置。客户端向反向代理的`命名空间(name-space)`中的内容发送普通请求，接着反向代理将判断向何处（`原始服务器(origin server)`）转交请求，并将获得的内容返回给客户端，就像这些内容原本就是它自己的一样。

**如：**

```
http {
    include mime.types;
    server_tokens off;

    ## 下面配置反向代理的参数
    server {
        listen    80;

        ## 1. 用户访问 http://ip:port，则反向代理到 https://github.com
        location / {
            proxy_pass  https://github.com;
            proxy_redirect     off;
            proxy_set_header   Host             $host;
            proxy_set_header   X-Real-IP        $remote_addr;
            proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
        }

        ## 2.用户访问 http://ip:port/README.md，则反向代理到
        ##   https://github.com/.../README.md
        location /README.md {
            proxy_set_header  X-Real-IP  $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass https://github.com/moonbingbing/openresty-best-practices/blob/master/README.md;
        }
    }
}
```

* `proxy_pass`

    `proxy_pass` 后面跟着一个 URL，用来将请求反向代理到 URL 参数指定的服务器上。例如上面例子中的 `proxy_pass https://github.com`，则将匹配的请求反向代理到 `https://github.com`。

* `proxy_set_header`

    默认情况下，反向代理不会转发原始请求中的 `Host` 头部，如果需要转发，就需要加上这句：`proxy_set_header Host $host;`

如把 `4000` 端口的 `gitbook serve` 服务代理到 `nginx` 服务的根目录：
```
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;


    server {
        listen       80;
        server_name  lilydedbb.net.cn;

        #root html;

        location / {
            proxy_pass http://127.0.0.1:4000/;
            proxy_http_version 1.1;
            proxy_redirect default;
            proxy_set_header Host $host;
            proxy_set_header Connection "";
            proxy_set_header X-Real-IP $remote_addr;
        }

        #error_page  404              /404.html;

        #error_page   500 502 503 504  /50x.html;
        #location = /50x.html {
        #    root   html;
        #}
    }

    # HTTPS server
    #
    server {
        listen       443 ssl;
        server_name  lilydedbb.net.cn;

        root html;

        location / {
            proxy_pass http://127.0.0.1:4000/;
            proxy_http_version 1.1;
            proxy_redirect default;
            proxy_set_header Host $host;
            proxy_set_header Connection "";
            proxy_set_header X-Real-IP $remote_addr;
        }

        error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        ssl on;
        ssl_certificate /etc/nginx/ssl/server.crt;
        ssl_certificate_key /etc/nginx/ssl/server.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;
    }
}
```