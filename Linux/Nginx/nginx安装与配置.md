# nginx 安装与配置

#### (Take ```CentOS 7``` as an example)

## Install
### Add Nginx Repository
To add the ```CentOS 7``` EPEL repository, open terminal and use the following command:
```
$ sudo yum install epel-release
```

### Install Nginx
Now that the ```Nginx``` repository is installed on your server, install Nginx using the following yum command:
```
$ sudo yum install nginx
```
After you answer yes to the prompt, Nginx will finish installing on your ```virtual private server (VPS)```.

### Start Nginx
```Nginx``` does not start on its own. To get ```Nginx``` running, type:
```
$ sudo systemctl start nginx
```
If you are running a firewall, run the following commands to allow ```HTTP``` and ```HTTPS``` traffic:
```
$ sudo firewall-cmd --permanent --zone=public --add-service=http
$ sudo firewall-cmd --permanent --zone=public --add-service=https
$ sudo firewall-cmd --reload
```
Before continuing, you will probably want to enable ```Nginx``` to start when your system boots. To do so, enter the following command:
```
$ sudo systemctl enable nginx
```

### Start, Stop and Restart

```
$ sudo service nginx start
$ sudo service nginx stop
$ sudo service nginx restart
```
or
```
$ sudo systemctl start nginx
$ sudo systemctl stop nginx
$ sudo systemctl restart nginx
```
The default ```index.html``` page that is distributed with ```nginx``` on ```CentOS``` is located in ```/usr/share/nginx/html```

### Check Nginx Configuration File
We can check nginx configuration file by typing:
```
$ nginx -t
```
If the configuration file is ok, the output should like this:
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### Configure Nginx

The configuration file is ```/etc/nginx/nginx.conf```.

Proxy node server like this:
```
......
http {
    ......
    server {
    ......
        location /dbb {
            proxy_pass  http://127.0.0.1:3001/;
            proxy_redirect default ;
        }

        location /lily {
            proxy_pass  http://127.0.0.1:3002/;
            proxy_redirect default ;
        }

        error_page  404              /404.html;

    ......
    }
    ......
}
```

---

#### (Take ```Ubuntu Server``` as an example)

### Install Nginx

```
$ sudo apt-get update
$ sudo apt-get install nginx
```

### Adjust the Firewall
Before we can test Nginx, we need to reconfigure our firewall software to allow access to the service. Nginx registers itself as a service with ufw, our firewall, upon installation. This makes it rather easy to allow Nginx access.

We can list the applications configurations that ufw knows how to work with by typing:
```
$ sudo ufw app list
```
You should get a listing of the application profiles:

Output
```
Available applications:
  Nginx Full
  Nginx HTTP
  Nginx HTTPS
  OpenSSH
```

As you can see, there are three profiles available for Nginx:

* ```Nginx Full```: This profile opens both port ```80``` (normal, unencrypted web traffic) and port ```443``` (TLS/SSL encrypted traffic)
* ```Nginx HTTP```: This profile opens only port ```80``` (normal, unencrypted web traffic)
* ```Nginx HTTPS```: This profile opens only port ```443``` (TLS/SSL encrypted traffic)

It is recommended that you enable the most restrictive profile that will still allow the traffic you've configured. Since we haven't configured SSL for our server yet, in this guide, we will only need to allow traffic on port 80.

```
$ sudo ufw allow 'Nginx HTTP'
```

### Check your Web Server
At the end of the installation process, Ubuntu 16.04 starts Nginx. The web server should already be up and running.

We can check with the systemd init system to make sure the service is running by typing:
```
$ systemctl status nginx
```
output:
```
* nginx.service - A high performance web server and a reverse proxy server
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2017-01-02 15:48:16 CST; 7min ago
 Main PID: 27574 (nginx)
   CGroup: /system.slice/nginx.service
           |-27574 nginx: master process /usr/sbin/nginx -g daemon on; master_process on
           `-27575 nginx: worker process

Jan 02 15:48:16 VM-60-61-ubuntu systemd[1]: Starting A high performance web server and a reverse proxy server...
Jan 02 15:48:16 VM-60-61-ubuntu systemd[1]: nginx.service: Failed to read PID from file /run/nginx.pid: Invalid argument
Jan 02 15:48:16 VM-60-61-ubuntu systemd[1]: Started A high performance web server and a reverse proxy server.
```

### Start, Stop and Restart

```
$ sudo service nginx start
$ sudo service nginx stop
$ sudo service nginx restart
```
or
```
$ sudo systemctl start nginx
$ sudo systemctl stop nginx
$ sudo systemctl restart nginx
```

## On ```macOS```

Install nginx by homebrew:
```
$ brew install nginx
```

Start nginx just type:
```
$ nginx
```

We can open Navigator it by going to URL ```http://localhost:8080``` to test nginx.

The default place of ```nginx.conf``` on Mac after installing with brew is:
```
/usr/local/etc/nginx/nginx.conf
```

We can stop/reload nginx by typing:
```
$ sudo nginx -s stop
$ sudo nginx -s reload
```

The defalut index page is :
```
/usr/local/var/www/html
```