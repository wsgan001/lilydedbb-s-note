# Linux Command Line

## 文件操作

```
$ ln <options> <source> <target>
```

options

- -b 删除，覆盖以前建立的链接
- -d 允许超级用户制作目录的硬链接
- -f 强制执行
- -i 交互模式，文件存在则提示用户是否覆盖
- -n 把符号链接视为一般目录
- -s 软链接(符号链接)
- -v 显示详细的处理过程


软链接：
1. 软链接，以路径的形式存在。类似于Windows操作系统中的快捷方式
2. 软链接可以 跨文件系统 ，硬链接不可以
3. 软链接可以对一个不存在的文件名进行链接
4. 软链接可以对目录进行链接

硬链接:
1. 硬链接，以文件副本的形式存在。但不占用实际空间。
2. 不允许给目录创建硬链接
3. 硬链接只有在同一个文件系统中才能创建


------


## 安装

### dpkg

```
$ dpkg -i chrome.deb
```

查看系统上所有的安装包
```
$ dpkg -l
```

查看这个包都安装了那些文件
```
$ dpkg -L <packagename>
```

查看某个特定文件来自于哪个软件包
```
$ dpkg -S /usr/bin/git
```


------


## 网络

### arp

arp命令用于操作主机的arp缓冲区，它可以显示arp缓冲区中的所有条目、删除指定的条目或者添加静态的ip地址与MAC地址对应关系

- -a <host>：显示arp缓冲区的所有条目；
- -H <Address Type>：指定arp指令使用的地址类型；
- -d <host>：从arp缓冲区中删除指定主机的arp条目；
- -D：使用指定接口的硬件地址；
- -e：以Linux的显示风格显示arp缓冲区中的条目；
- -i <interface>：指定要操作arp缓冲区的网络接口；
- -s <host>：设置指定的主机的IP地址与MAC地址的静态映射；
- -n：以数字方式显示arp缓冲区中的条目；
- -v：显示详细的arp缓冲区条目，包括缓冲区条目的统计信息；
- -f <file>：设置主机的IP地址与MAC地址的静态映射

```
$ arp -a
? (169.254.255.255) at (incomplete) on en3 [ethernet]
? (172.16.223.255) at ff:ff:ff:ff:ff:ff on vmnet8 ifscope [ethernet]
```


### Ping

ping命令用来测试主机之间网络的连通性

执行ping指令会使用ICMP传输协议，发出要求回应的信息，若远端主机的网络功能没有问题，就会回应该信息，因而得知该主机运作正常

```
$ ping www.baidu.com
PING www.a.shifen.com (119.75.217.109): 56 data bytes
64 bytes from 119.75.217.109: icmp_seq=0 ttl=53 time=20.512 ms
64 bytes from 119.75.217.109: icmp_seq=1 ttl=53 time=20.246 ms
64 bytes from 119.75.217.109: icmp_seq=2 ttl=53 time=20.256 ms
64 bytes from 119.75.217.109: icmp_seq=3 ttl=53 time=20.327 ms
64 bytes from 119.75.217.109: icmp_seq=4 ttl=53 time=20.480 ms
^C
--- www.a.shifen.com ping statistics ---
5 packets transmitted, 5 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 20.246/20.364/20.512/0.112 ms
```


### traceroute命令网络测试

traceroute命令用于追踪数据包在网络上的传输时的全部路径，它默认发送的数据包大小是40字节

通过traceroute我们可以知道信息从你的计算机到互联网另一端的主机是走的什么路径。当然每次数据包由某一同样的出发点（source）到达某一同样的目的地(destination)走的路径可能会不一样，但基本上来说大部分时候所走的路由是相同的

traceroute通过发送小的数据包到目的设备直到其返回，来测量其需要多长时间。一条路径上的每个设备traceroute要测3次。输出结果中包括每次测试的时间(ms)和设备的名称（如有的话）及其ip地址

**traceroute一台主机时，会看到有一些行是以星号表示的。出现这样的情况，可能是防火墙封掉了ICMP的返回信息，所以得不到什么相关的数据包返回数据**

```
$ traceroute www.baidu.com
traceroute: Warning: www.baidu.com has multiple addresses; using 180.97.33.107
traceroute to www.a.shifen.com (180.97.33.107), 64 hops max, 52 byte packets
 1  * * *
 2  zxq-xs-rjs8606.hust.edu.cn (115.156.255.149)  0.882 ms  0.890 ms  0.817 ms
 3  192.168.255.177 (192.168.255.177)  0.882 ms  0.656 ms  0.737 ms
 # ....
```

记录按序列号从1开始，每个纪录就是一跳 ，每跳表示一个网关，我们看到每行有三个时间，单位是ms，其实就是-q的默认参数。探测数据包向每个网关发送三个数据包后，网关响应后返回的时间；如果用 ` $ traceroute -q 4 www.58.com`，表示向每个网关发送4个数据包


### tracepath

tracepath 命令用来追踪并显示报文到达目的主机所经过的路由信息

```
$ tracepath <parameter>
```

参数
- 目的主机：指定追踪路由信息的目的主机；
- 端口：指定使用的UDP端口号


### nslookup

nslookup 命令是常用域名查询工具，就是查DNS信息用的命令

nslookup4有两种工作模式，即“交互模式”和“非交互模式”。在“交互模式”下，用户可以向域名服务器查询各类主机、域名的信息，或者输出域名中的主机列表。而在“非交互模式”下，用户可以针对一个主机或域名仅仅获取特定的名称或所需信息

进入交互模式，直接输入nslookup命令，不加任何参数，则直接进入交互模式，此时nslookup会连接到默认的域名服务器（即/etc/resolv.conf的第一个dns地址）。或者输入`$ nslookup -<nameserver>/<ip>`。进入非交互模式，就直接输入nslookup 域名就可以了

```
$ nslookup www.google.com
Server:		202.114.0.242
Address:	202.114.0.242#53

Non-authoritative answer:
Name:	www.google.com
Address: 216.58.200.36
```


### dig

dig命令是常用的域名查询工具，可以用来测试域名系统工作是否正常

```
dig <options> <parameter>
```

options
- @<服务器地址>：指定进行域名解析的域名服务器；
- -b：当主机具有多个IP地址，指定使用本机的哪个IP地址向域名服务器发送域名查询请求；
- -f<文件名称>：指定dig以批处理的方式运行，指定的文件中保存着需要批处理查询的DNS任务信息；
- -P：指定域名服务器所使用端口号；
- -t<类型>：指定要查询的DNS数据类型；
- -x：执行逆向域名查询；
- -4：使用IPv4；
- -6：使用IPv6；
- -h：显示指令帮助信息

parameter
- 主机：指定要查询域名主机；
- 查询类型：指定DNS查询的类型；
- 查询类：指定查询DNS的class；
- 查询选项：指定查询选项

```
$ dig www.google.com

; <<>> DiG 9.8.3-P1 <<>> www.google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 2389
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 4, ADDITIONAL: 4

;; QUESTION SECTION:
;www.google.com.			IN	A

;; ANSWER SECTION:
www.google.com.		21	IN	A	216.58.200.36

;; AUTHORITY SECTION:
google.com.		109752	IN	NS	ns3.google.com.
google.com.		109752	IN	NS	ns2.google.com.
google.com.		109752	IN	NS	ns1.google.com.
google.com.		109752	IN	NS	ns4.google.com.

;; ADDITIONAL SECTION:
ns1.google.com.		4833	IN	A	216.239.32.10
ns2.google.com.		109688	IN	A	216.239.34.10
ns4.google.com.		109688	IN	A	216.239.38.10
ns3.google.com.		109688	IN	A	216.239.36.10

;; Query time: 2 msec
;; SERVER: 202.114.0.242#53(202.114.0.242)
;; WHEN: Thu Jun  8 10:45:08 2017
;; MSG SIZE  rcvd: 184
```


### host

host命令是常用的分析域名查询工具，可以用来测试域名系统工作是否正常

```
$ host www.baidu.com
www.baidu.com is an alias for www.a.shifen.com.
www.a.shifen.com has address 180.97.33.108
www.a.shifen.com has address 180.97.33.107
$ host www.google.com
www.google.com has address 216.58.200.228
www.google.com has IPv6 address 2404:6800:4008:802::2004
```


### nc/netcat

nc命令是netcat命令的简称，都是用来设置路由器