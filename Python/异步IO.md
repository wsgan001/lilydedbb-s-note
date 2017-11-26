## 异步IO

### 协程【coroutine】

Python对协程的支持是通过```generator```实现的
```python
def consumer():
    r = ''
    while True:
        n = yield r
        if not n:
            return
        print('[CONSUMER] Consuming %s...' % n)
        r = '200 OK'

def produce(c):
    c.send(None)
    n = 0
    while n < 5:
        n = n + 1
        print('[PRODUCER] Producing %s...' % n)
        r = c.send(n)
        print('[PRODUCER] Consumer return: %s' % r)
    c.close()

c = consumer()
produce(c)
```
注意到```consumer```函数是一个```generator```，把一个```consumer```传入```produce```后：

1. 首先调用```c.send(None)```启动生成器；
2. 然后，一旦生产了东西，通过```c.send(n)```切换到```consumer```执行；
3. ```consumer```通过```yield```拿到消息，处理，又通过```yield```把结果传回；
4. ```produce```拿到```consumer```处理的结果，继续生产下一条消息；
5. ```produce```决定不生产了，通过```c.close()```关闭```consumer```，整个过程结束
运行结果
```
[PRODUCER] Producing 1...
[CONSUMER] Consuming 1...
[PRODUCER] Consumer return: 200 OK
[PRODUCER] Producing 2...
[CONSUMER] Consuming 2...
[PRODUCER] Consumer return: 200 OK
[PRODUCER] Producing 3...
[CONSUMER] Consuming 3...
[PRODUCER] Consumer return: 200 OK
[PRODUCER] Producing 4...
[CONSUMER] Consuming 4...
[PRODUCER] Consumer return: 200 OK
[PRODUCER] Producing 5...
[CONSUMER] Consuming 5...
[PRODUCER] Consumer return: 200 OK
```

### asyncio
用asyncio的异步网络连接来获取sina、sohu和163的网站首页
```python
import asyncio

@asyncio.coroutine
def wget(host):
    print('wget %s...' % host)
    connect = asyncio.open_connection(host, 80)
    reader, writer = yield from connect
    header = 'GET / HTTP/1.0\r\nHost: %s\r\n\r\n' % host
    writer.write(header.encode('utf-8'))
    yield from writer.drain()
    while True:
        line = yield from reader.readline()
        if line == b'\r\n':
            break
        print('%s header > %s' % (host, line.decode('utf-8').rstrip()))
    writer.close()

loop = asyncio.get_event_loop()
tasks = [wget(host) for host in ['www.sina.com.cn', 'www.sohu.com', 'www.163.com']]
loop.run_until_complete(asyncio.wait(tasks))
loop.close()
```
```
wget www.sina.com.cn...
wget www.163.com...
wget www.sohu.com...
www.163.com header > HTTP/1.0 302 Moved Temporarily
www.163.com header > Server: Cdn Cache Server V2.0
www.163.com header > Date: Sun, 04 Dec 2016 14:31:37 GMT
www.163.com header > Content-Length: 0
www.163.com header > Location: http://www.163.com/special/0077jt/error_isp.html
www.163.com header > Connection: close
www.sohu.com header > HTTP/1.1 200 OK
www.sohu.com header > Content-Type: text/html
www.sohu.com header > Content-Length: 92426
www.sohu.com header > Connection: close
www.sohu.com header > Date: Sun, 04 Dec 2016 14:29:51 GMT
www.sohu.com header > Server: SWS
www.sohu.com header > Vary: Accept-Encoding
www.sohu.com header > Cache-Control: no-transform, max-age=120
www.sohu.com header > Expires: Sun, 04 Dec 2016 14:31:51 GMT
www.sohu.com header > Last-Modified: Sun, 04 Dec 2016 14:19:13 GMT
www.sohu.com header > Content-Encoding: gzip
www.sohu.com header > X-RS: 10511343.19686393.11189627
www.sohu.com header > FSS-Cache: HIT from 8162289.14912507.8916056
www.sohu.com header > FSS-Proxy: Powered by 2788255.4164521.3541940
www.sina.com.cn header > HTTP/1.1 200 OK
www.sina.com.cn header > Server: nginx
www.sina.com.cn header > Date: Sun, 04 Dec 2016 14:31:37 GMT
www.sina.com.cn header > Content-Type: text/html
www.sina.com.cn header > Last-Modified: Sun, 04 Dec 2016 14:30:57 GMT
www.sina.com.cn header > Vary: Accept-Encoding
www.sina.com.cn header > Expires: Sun, 04 Dec 2016 14:32:37 GMT
www.sina.com.cn header > Cache-Control: max-age=60
www.sina.com.cn header > X-Powered-By: shci_v1.03
www.sina.com.cn header > X-Cache: MISS from cernet194-227.sina.com.cn
www.sina.com.cn header > Connection: close
```
在```loop.run_until_complete(asyncio.wait(tasks))```中传入包含异步操作的tasks。```yield from```语法可以方便地调用另一个```generator```。由于```yield from```之后必须是一个```coroutine```，所以线程不会等待之后的IO操作，而是直接中断并执行下一个消息循环，从而做到每个task异步并发执行，然后等待```yield from```语句后的IO操作执行完毕之后，在继续执行之后的逻辑

### async/await
注意，```async```和```await```是针对```coroutine```的新语法，要使用新的语法，只需要做两步简单的替换：
1. 把```@asyncio.coroutine```替换为```async```
2. 把```yield from```替换为```await```

所以上面的代码完全等价于：
```python
import asyncio

async def wget(host):
    print('wget %s...' % host)
    connect = asyncio.open_connection(host, 80)
    reader, writer = await connect
    header = 'GET / HTTP/1.0\r\nHost: %s\r\n\r\n' % host
    writer.write(header.encode('utf-8'))
    await writer.drain()
    while True:
        line = await reader.readline()
        if line == b'\r\n':
            break
        print('%s header > %s' % (host, line.decode('utf-8').rstrip()))
    writer.close()

loop = asyncio.get_event_loop()
tasks = [wget(host) for host in ['www.sina.com.cn', 'www.sohu.com', 'www.163.com']]
loop.run_until_complete(asyncio.wait(tasks))
loop.close()
```

### aiohttp
模块```asyncio```可以实现单线程并发IO操作。如果仅用在客户端，发挥的威力不大。如果把```asyncio```用在服务器端，例如Web服务器，由于HTTP连接就是IO操作，因此可以用单线程```+coroutine```实现多用户的高并发支持
```python
import asyncio

from aiohttp import web

async def index(request):
    await asyncio.sleep(0.5)
    return web.Response(body=b'<h1>Index</h1>')

async def hello(request):
    await asyncio.sleep(0.5)
    text = '<h1>hello, %s!</h1>' % request.match_info['name']
    return web.Response(body=text.encode('utf-8'))

async def init(loop):
    app = web.Application(loop=loop)
    app.router.add_route('GET', '/', index)
    app.router.add_route('GET', '/hello/{name}', hello)
    srv = await loop.create_server(app.make_handler(), '127.0.0.1', 8000)
    print('Server started at http://127.0.0.1:8000...')
    return srv

loop = asyncio.get_event_loop()
loop.run_until_complete(init(loop))
loop.run_forever()
```
==注意```aiohttp```的初始化函数```init()```也是一个```coroutine```，```loop.create_server()```则利用```asyncio```创建```TCP```服务==
