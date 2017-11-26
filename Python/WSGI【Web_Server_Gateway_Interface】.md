## WSGI【Web Server Gateway Interface】

```python
# demo_http.py
from wsgiref.simple_server import make_server
from hello import app

httpd = make_server('', 8000, app)
print('Serving HTTP on port 8000...')

httpd.serve_forever()
```

```python
# hello.py
def app(environ, start_response):
    start_response('200 OK', [('Content-Type', 'text/html')])
    body = '<h1>Hello, %s </h1>' % (environ['PATH_INFO'][1:] or 'web')
    return [body.encode('utf-8')]
```
上面的```app()```函数就是符合```WSGI```标准的一个HTTP处理函数，它接收两个参数：

- ```environ```：一个包含所有HTTP请求信息的dict对象；

- ```start_response```：一个发送HTTP响应的函数

在```app()```函数中，调用：
```
start_response('200 OK', [('Content-Type', 'text/html')])
```
就发送了HTTP响应的Header，注意```Header```只能发送一次，也就是只能调用一次```start_response()```函数。```start_response()```函数接收两个参数，一个是HTTP响应码，一个是一组list表示的HTTP ```Header```，每个```Header```用一个包含两个str的tuple表示。

通常情况下，都应该把```Content-Type```头发送给浏览器。其他很多常用的```HTTP Header```也应该发送。

然后，函数的返回值body变量b将作为HTTP响应的Body发送给浏览器。

有了```WSGI```，关心的就是如何从```environ```这个dict对象拿到HTTP请求信息，然后构造HTML，通过```start_response()```发送```Header```，最后返回Body

==WSGI仅是一个标准，上面的app()函数遵循了这个标准，然后要实现app()函数的功能需要一个符合WSGI标准的WSGI服务器，符合WSGI标准的WSGI服务器有很多，这里供测试的Python内置模块wsgiref，是用纯Python编写的WSGI服务器的参考实现。所谓“参考实现”是指该实现完全符合WSGI标准，但是不考虑任何运行效率，仅供开发和测试使用==