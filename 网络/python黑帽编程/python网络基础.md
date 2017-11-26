# python网络基础


## 套接字编程

三种最流行的套接字类型是:`stream`, `datagram` 和 `raw`

`stream`和`datagram`套接字可以直接与`TCP`协议进行接口，而 `raw` 套接字则接口到 `IP` 协议，但套接字并不限于 `TCP/IP`

Python 提供了两个基本的套接字模块:
- 第一个是 `socket`，它提供了标准的 `BSD Sockets API`
- 第二个是 `socketServer`， 它提供了服务器中心类，可以简化网络服务器的开发

### SOCKET函数

```python
socket.socket([family[, type[, proto]]])
```
- `family`: 套接字对象使用的地址族:
    - `AF_INET` IPv4地址族
    - `AF_INET6` IPv6地址族
    - `AF_UNIX` 针对类UNIX系统的套接字
- `type`:
    - `socket.SOCK_STREAM` 基于 TCP 的流式 socket 通信
    - `socket.SOCK_DGRAM` 基于 UDP 的数据报式 socket 通信
    - `socket.SOCK_RAW`
    - `socket.SOCK_SEQPACKET`