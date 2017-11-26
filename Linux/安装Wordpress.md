# 安装Wordpress

### Download and Extract

```
$ wget http://wordpress.org/latest.tar.gz
$ tar -xzvf latest.tar.gz
```

The WordPress package will extract into a folder called `wordpress` in the same directory that you downloaded `latest.tar.gz`.

### Create the Database and a User (Using the MySQL Client)

```
$ mysql -u root -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 104
Server version: 5.7.19 MySQL Community Server (GPL)

Copyright (c) 2000, 2017, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> CREATE DATABASE databasename;
Query OK, 1 row affected (0.00 sec)

mysql> GRANT ALL PRIVILEGES ON databasename.* TO "wordpressusername"@"hostname"
    -> IDENTIFIED BY "password";
Query OK, 0 rows affected (0.00 sec)

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.01 sec)

mysql> EXIT
Bye
```

### Set up wp-config.php

Return to where you extracted the WordPress package in Step 1, rename the file wp-config-sample.php to wp-config.php, and open it in a text editor.

Enter your database information under the section labeled

```
 // ** MySQL settings - You can get this info from your web host ** //
```

#### DB_NAME
The name of the database you created for WordPress in Step 2.
#### DB_USER
The username you created for WordPress in Step 2.
#### DB_PASSWORD
The password you chose for the WordPress username in Step 2.
#### DB_HOST
The hostname you determined in Step 2 (usually localhost, but not always; see some possible DB_HOST values). If a port, socket, or pipe is necessary, append a colon (:) and then the relevant information to the hostname.
#### DB_CHARSET
The database character set, normally should not be changed (see Editing wp-config.php).
#### DB_COLLATE
The database collation should normally be left blank (see Editing wp-config.php).

Enter your secret key values under the section labeled

```
  * Authentication Unique Keys.
```

Save the wp-config.php file.

You don't have to remember the keys, just make them long, random and complicated -- or better yet, use the [online generator](https://api.wordpress.org/secret-key/1.1/salt/). You can change these at any point in time to invalidate all existing cookies. This does mean that all users will have to login again.

### Run the Install Script

Point a web browser to start the installation script.

- If you placed the WordPress files in the root directory, you should visit: `http://example.com/wp-admin/install.php`

- If you placed the WordPress files in a subdirectory called `blog`, for example, you should visit: `http://example.com/blog/wp-admin/install.php`