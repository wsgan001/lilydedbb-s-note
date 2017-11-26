## TCP & UDP

### TCP
客户端tcp链接访问[Sina](https://www.sina.com.cn/)
```python
import socket

# 创建一个socket
# 创建Socket时，AF_INET指定使用IPv4协议，如果要用更先进的IPv6，就指定为AF_INET6。SOCK_STREAM指定使用面向流的TCP协议
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# 建立连接
s.connect(('www.sina.com.cn', 80))
# 发送数据
s.send(b'GET / HTTP/1.1\r\nHost: www.sina.com.cn\r\nConnection: close\r\n\r\n')

# 接收数据
buffer = []
while True:
    # 每次最多接收1k字节:
    d = s.recv(1024)
    if d:
        buffer.append(d)
    else:
        break
data = b''.join(buffer)

# 关闭连接
s.close()

header, html = data.split(b'\r\n\r\n', 1)
print(header.decode('utf-8'))
# 把接收的数据写入文件:
with open('sina.html', 'wb') as f:
    f.write(html)
```
创建```Socket```时，```AF_INET```指定使用```IPv4```协议，如果要用更先进的```IPv6```，就指定为```AF_INET6```。```SOCK_STREAM```指定使用面向流的```TCP```协议，这样，一个```Socket```对象就创建成功，但是还没有建立连接

服务器端tcp示例：
```python
# tcp_server.py
import socket
import threading
import time

# 创建一个基于IPv4和TCP协议的Socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# 监听端口
s.bind(('127.0.0.1', 9999))
# 调用listen()方法开始监听端口，传入的参数指定等待连接的最大数量
s.listen(5)
print('Waiting for connection...')

# 处理来自客户端的请求
def tcplink(sock, addr):
    print('Accept new connection from %s:%s...' % addr)
    sock.send(b'Welcome')
    while True:
        data = sock.recv(1024)
        time.sleep(1)
        if not data or data.decode('utf-8') == 'exit':
            break
        sock.send(('Hello, %s' % data.decode('utf-8')).encode('utf-8'))
    sock.close()
    print('Connection from %s:%s closed.' % addr)

# 通过一个永久循环来接受来自客户端的连接，accept()会等待并返回一个客户端的连接
while True:
    # 接受一个新连接
    sock, addr = s.accept()
    # 创建新线程来处理TCP连接
    # 每个连接都必须创建新线程（或进程）来处理，否则，单线程在处理连接的过程中，无法接受其他客户端的连接
    t = threading.Thread(target=tcplink, args=(sock, addr))
    t.start()
```
客户端tcp测试：
```python
# tcp_client.py
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# 建立连接:
s.connect(('127.0.0.1', 9999))
# 接收欢迎消息:
print(s.recv(1024).decode('utf-8'))
for data in [b'dbb', b'lily']:
    # 发送数据:
    s.send(data)
    print(s.recv(1024).decode('utf-8'))
s.send(b'exit')
s.close()
```
测试结果：
```
MacBook-Pro:python_summary dbb$ python3 tcp_server.py
Waiting for connection...
Accept new connection from 127.0.0.1:61858...
Connection from 127.0.0.1:61858 closed.
```
```
MacBook-Pro:python_summary dbb$ python3 tcp_client.py
Welcome
Hello, dbb
Hello, lily
```


### UDP

```python
# udp_server.py
import socket
import threading

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
# 绑定端口:
s.bind(('127.0.0.1', 9999))
# 绑定端口和TCP一样，但是不需要调用listen()方法，而是直接接收来自任何客户端的数据
print('Bind UDP on 9999...')

# 处理来自客户端的请求
def udplink(sock ,data, addr):
    print('Received from %s:%s.' % addr)
    sock.sendto(b'Hello, %s!' % data, addr)

# 接收来自客户端的连接
while True:
    # recvfrom()方法返回数据和客户端的地址与端口，这样，服务器收到数据后，直接调用sendto()就可以把数据用UDP发给客户端
    data, addr = s.recvfrom(1024)
    t = threading.Thread(target=udplink, args=(s, data, addr))
    t.start()
```

```python
# udp_client.py
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
for data in [b'dbb', b'lily']:
    # 发送数据:
    s.sendto(data, ('127.0.0.1', 9999))
    # 接收数据:
    # 从服务器接收数据仍然调用recv()方法
    print(s.recv(1024).decode('utf-8'))
s.close()
```

测试结果：
```
MacBook-Pro:python_summary dbb$ python3 udp_server.py
Bind UDP on 9999...
Received from 127.0.0.1:51226.
Received from 127.0.0.1:51226.
```
```
MacBook-Pro:python_summary dbb$ python3 udp_client.py
Hello, dbb!
Hello, lily!
```