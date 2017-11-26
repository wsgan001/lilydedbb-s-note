# PHP安装与配置

### Install PHP

PHP is the component of our setup that will process code to display dynamic content. It can run scripts, connect to our MySQL databases to get information, and hand the processed content over to our web server to display.

We can once again leverage the yum system to install our components. We're going to include the php-mysql package as well:

```
$ sudo yum install php php-mysql
```

This should install PHP without any problems. We need to restart the Apache web server in order for it to work with PHP. You can do this by typing this:

```
$ sudo systemctl restart httpd.service
```