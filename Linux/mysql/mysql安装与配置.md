# mysql 安装与配置

Source: [How To Install MySQL on CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-centos-7)

#### (Take ```CentOS 7``` as an example)


### Install MySQL
Locate the desired version on the site `https://dev.mysql.com/downloads/repo/yum/`:

Here take `MySQL version 5.7` as example:
```
$ wget https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
```
Once the rpm file is saved, we will verify the integrity of the download by running `md5sum` and comparing it with the corresponding `MD5` value listed on the site:
```
$ md5sum mysql57-community-release-el7-9.noarch.rpm
```
```
Output
1a29601dc380ef2c7bc25e2a0e25d31e  mysql57-community-release-el7-9.noarch.rpm
```
Compare this output with the appropriate `MD5` value on the site `https://dev.mysql.com/downloads/repo/yum/`

Install the package:
```
$ sudo rpm -ivh mysql57-community-release-el7-9.noarch.rpm
```

This adds two new `MySQL` yum repositories, and we can now use them to install `MySQL` server:
```
$ sudo yum install mysql-server
```

Press `y` to confirm that you want to proceed. Since we've just added the package, we'll also be prompted to accept its `GPG` key. Press `y` to download it and complete the install.


### Starting MySQL

We'll start the daemon with the following command:
```
$ sudo systemctl start mysqld
```

During the installation process, a temporary password is generated for the MySQL root user. Locate it in the mysqld.log with this command:
```
$ sudo grep 'temporary password' /var/log/mysqld.log
```


### Configuring MySQL

`MySQL` includes a security script to change some of the less secure default options for things like remote root logins and sample users.

Use this command to run the security script.
```
$ sudo mysql_secure_installation
```

This will prompt you for the default root password. As soon as you enter it, you will be required to change it.
```
# Output
The existing password for the user account root has expired. Please set a new password.

New password:
```

Enter a new **12-character password that contains at least one uppercase letter, one lowercase letter, one number and one special character**. Re-enter it when prompted.

You'll receive feedback on the strength of your new password, and then you'll be immediately prompted to change it again. Since you just did, you can confidently say No:
```
# Output
Estimated strength of the password: 100
Change the password for root ? (Press y|Y for Yes, any other key for No) :
```

After we decline the prompt to change the password again, we'll press `Y` and then `ENTER` to all the subsequent questions in order to remove anonymous users, disallow remote root login, remove the test database and access to it, and reload the privilege tables.


### Testing MySQL

We can verify our installation and get information about it by connecting with the mysqladmin tool, a client that lets you run administrative commands. Use the following command to connect to `MySQL` as `root` (`-u root`), prompt for a password (`-p`), and return the version.
```
$ mysqladmin -u root -p version
```

You should see output similar to this:
```
# Output
mysqladmin  Ver 8.42 Distrib 5.7.16, for Linux on x86_64
Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Server version          5.7.16
Protocol version        10
Connection              Localhost via UNIX socket
UNIX socket             /var/lib/mysql/mysql.sock
Uptime:                 2 min 17 sec

Threads: 1  Questions: 6  Slow queries: 0  Opens: 107  Flush tables: 1  Open tables: 100  Queries per second avg: 0.043
```

This indicates your installation has been successful.