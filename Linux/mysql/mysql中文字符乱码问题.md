# mysql中文字符乱码问题

找到mysql的配置文件，如果不知道位置，可以通过下面的命令查询：
```
$ find / -name my.cnf
```

`CentOS`上配置文件一般是`/etc/my.cnf`

修改配置文件：
```
[mysql]
default-character-set=utf8
[mysqld]
character-set-server=utf8
````

然后进入mysql中查看，出现如下结果便修改成功
```
mysql> SHOW variables LIKE 'character%';
+--------------------------+----------------------------+
| Variable_name            | Value                      |
+--------------------------+----------------------------+
| character_set_client     | utf8                       |
| character_set_connection | utf8                       |
| character_set_database   | utf8                       |
| character_set_filesystem | binary                     |
| character_set_results    | utf8                       |
| character_set_server     | utf8                       |
| character_set_system     | utf8                       |
| character_sets_dir       | /usr/share/mysql/charsets/ |
+--------------------------+----------------------------+
8 rows in set (0.01 sec)
```

**注：**
- `character_set_client` 为客户端使用的字符集
- `character_set_connection` 为连接数据库的字符集设置类型，如果程序没有指明连接数据库使用的字符集类型则按照服务器端默认的字符集设置
- `character_set_database` 为数据库服务器中某个库使用的字符集设定，如果建库时没有指明，将使用服务器安装时指定的字符集设置
- `character_set_results` 为数据库给客户端返回时使用的字符集设定，如果没有指明，使用服务器默认的字符集
- `character_set_server` 为服务器安装时指定的默认字符集设定
- `character_set_system` 为数据库系统使用的字符集设定
