# 添加和删除FTP用户并设置权限

**ftp为vsftp**

在```linux```中添加```ftp```用户，并设置相应的权限，操作步骤如下：

* 被设置用户名为```test```。被限制路径为```/home/test```

* 新建建用户（在```root```用户下）：
```
# 增加用户test，并制定test用户的主目录为/home/test
$ useradd -d /home/test test
$ passwd test //为test设置密码
```

* 更改用户相应的权限设置：
```
# 限定用户test不能telnet，只能ftp
$ usermod -s /sbin/nologin test
# 用户test恢复正常
$ usermod -s /sbin/bash test
# 更改用户test的主目录为/test
$ usermod -d /test test
```

* 限制用户只能访问```/home/test```，不能访问其他路径
修改```/etc/vsftpd/vsftpd.conf```如下：
```
......
# 限制访问自身目录
chroot_list_enable=YES
# (default follows)
chroot_list_file=/etc/vsftpd/vsftpd.chroot_list
......
```
编辑 ```vsftpd.chroot_list``` 文件，将受限制的用户添加进去，每个用户名一行
改完配置文件，重启```vsftpd```服务器
```
$ service vsftpd restart
```

* 如果需要允许用户修改密码，但是又没有telnet登录系统的权限：
```
# 用户telnet后将直接进入改密界面
$ usermod -s /usr/bin/passwd test
```

* 如果要删除用户，用下面代码：
```
$ userdel test
```