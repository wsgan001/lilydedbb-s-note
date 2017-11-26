# apache 安装与配置

#### (Take ```CentOS 7``` as an example)

## Install

### Install Apache

First, clean-up yum:
```
$ sudo yum clean all
```
As a matter of best practice we’ll update our packages:
```
$ sudo yum -y update
```
Installing Apache is as simple as running just one command:
```
$ sudo yum -y install httpd
```

### Allow Apache Through the Firewall

(If you don't start the firewall service, you can ignore this step)

Allow the default HTTP and HTTPS port, ports 80 and 443, through firewalld:
```
$ sudo firewall-cmd --permanent --add-port=80/tcp
```
```
$ sudo firewall-cmd --permanent --add-port=443/tcp
```
And reload the firewall:
```
$ sudo firewall-cmd --reload
```

### Configure Apache to Start on Boot

And then start Apache:
```
$ sudo systemctl start httpd
```
Be sure that Apache starts at boot:
```
$ sudo systemctl enable httpd
```
To check the status of Apache:
```
$ sudo systemctl status httpd
```
To stop Apache:
```
$ sudo systemctl stop httpd
```

---

#### (Take ```Ubuntu Server``` as an example)

### Install Apache and Allow in Firewall
```
$ sudo apt-get update
$ sudo apt-get install apache2
```

### Set Global ServerName to Suppress Syntax Warnings

Next, we will add a single line to the /etc/apache2/apache2.conf file to suppress a warning message. While harmless, if you do not set ServerName globally, you will receive the following warning when checking your Apache configuration for syntax errors:
```
$ sudo apache2ctl configtest
```
Output
```
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 127.0.1.1. Set the 'ServerName' directive globally to suppress this message
Syntax OK
```
Open up the main configuration file with your text edit:
```
$ sudo nano /etc/apache2/apache2.conf
```
Inside, at the bottom of the file, add a ServerName directive, pointing to your primary domain name. If you do not have a domain name associated with your server, you can use your server's public IP address:
```
# /etc/apache2/apache2.conf
. . .
ServerName server_domain_or_IP
```
Next, check for syntax errors by typing:
```
$ sudo apache2ctl configtest
```
Since we added the global ServerName directive, all you should see is:

Output
```
Syntax OK
```

Restart Apache to implement your changes:
```
$ sudo systemctl restart apache2
```

### Adjust the Firewall to Allow Web Traffic

If you look at the Apache Full profile, it should show that it enables traffic to ports 80 and 443:
```
$ sudo ufw app info "Apache Full"
```
Output
```
Profile: Apache Full
Title: Web Server (HTTP,HTTPS)
Description: Apache v2 is the next generation of the omnipresent Apache web
server.

Ports:
  80,443/tcp
```
Allow incoming traffic for this profile:
```
$ sudo ufw allow in "Apache Full"
```
You can do a spot check right away to verify that everything went as planned by visiting your server's public IP address in your web browser
