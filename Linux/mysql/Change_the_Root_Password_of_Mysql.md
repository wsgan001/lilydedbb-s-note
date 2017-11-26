# Change the Root Password of Mysql

```
# Stop mysql:
$ systemctl stop mysqld

# Set the mySQL environment option
$ systemctl set-environment MYSQLD_OPTS="--skip-grant-tables"

# Start mysql usig the options you just set
$ systemctl start mysqld

# Login as root
mysql -u root

# Update the root user password with these mysql commands
mysql> UPDATE mysql.user SET authentication_string = PASSWORD('MyNewPassword')
    -> WHERE User = 'root' AND Host = 'localhost';
mysql> FLUSH PRIVILEGES;
mysql> quit

# Stop mysql
$ systemctl stop mysqld

# Unset the mySQL envitroment option so it starts normally next time
$ systemctl unset-environment MYSQLD_OPTS

# Start mysql normally:
$ systemctl start mysqld

# Try to login using your new password:
$ mysql -u root -p
```