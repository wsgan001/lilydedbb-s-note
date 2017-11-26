# CORS

原文链接：[跨域资源共享 CORS 详解](http://www.ruanyifeng.com/blog/2016/04/cors.html)

> CORS: 跨域资源共享（Cross-origin resource sharing）

> 允许浏览器向跨源服务器，发出`XMLHttpRequest`请求，从而克服了AJAX只能同源使用的限制

`CORS`需要浏览器和服务器同时支持。目前，所有浏览器都支持该功能，IE浏览器不能低于IE10

整个`CORS`通信过程，都是浏览器自动完成，不需要用户参与。对于开发者来说，`CORS`通信与同源的`AJAX`通信没有差别，代码完全一样。浏览器一旦发现`AJAX`请求跨源，就会自动添加一些附加的头信息，有时还会多出一次附加的请求，但用户不会有感觉

因此，实现`CORS`通信的关键是服务器。只要服务器实现了`CORS`接口，就可以跨源通信


## 简单请求和非简单请求
浏览器将CORS请求分成两类：`简单请求（simple request）`和`非简单请求（not-so-simple request）`
只要同时满足以下两大条件，就属于简单请求。

- 请求方法是以下三种方法之一：
    - HEAD
    - GET
    - POST
- HTTP的头信息不超出以下几种字段：
    - Accept
    - Accept-Language
    - Content-Language
    - Last-Event-ID
    - Content-Type：只限于三个值`application/x-www-form-urlencoded`、`multipart/form-data`、`text/plain`

凡是不同时满足上面两个条件，就属于非简单请求。
**浏览器对这两种请求的处理，是不一样的**


## 对于简单请求

对于简单请求，浏览器直接发出`CORS`请求。具体来说，就是在头信息之中，增加一个`Origin`字段

如：
```
GET /cors HTTP/1.1
Origin: http://api.bob.com
Host: api.alice.com
Accept-Language: en-US
Connection: keep-alive
User-Agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36
```
上面的头信息中，`Origin`字段用来说明，本次请求来自哪个源（`协议 + 域名 + 端口`）。服务器根据这个值，决定是否同意这次请求

如果`Origin`指定的源，不在许可范围内，服务器会返回一个正常的`HTTP`回应。浏览器发现，这个回应的头信息没有包含`Access-Control-Allow-Origin`字段，就知道出错了，从而抛出一个错误，被`XMLHttpRequest`的`onerror`回调函数捕获。注意，这种错误无法通过状态码识别，因为`HTTP`回应的状态码有可能是`200`

如果`Origin`指定的域名在许可范围内，服务器返回的响应，会多出几个头信息字段
```
Access-Control-Allow-Origin: http://api.bob.com
Access-Control-Allow-Credentials: true
Access-Control-Expose-Headers: FooBar
Content-Type: text/html; charset=utf-8
```
其中：
- `Access-Control-Allow-Origin`

    该字段是必须的。它的值要么是请求时`Origin`字段的值，要么是一个`*`，表示接受任意域名的请求
- `Access-Control-Allow-Credentials`

    该字段可选。它的值是一个布尔值，表示是否允许发送`Cookie`。默认情况下，`Cookie`不包括在`CORS`请求之中。设为`true`，即表示服务器明确许可，`Cookie`可以包含在请求中，一起发给服务器。这个值也只能设为`true`，如果服务器不要浏览器发送`Cookie`，删除该字段即可
- `Access-Control-Expose-Headers`

    该字段可选。`CORS`请求时，`XMLHttpRequest`对象的`getResponseHeader()`方法只能拿到6个基本字段：`Cache-Control`、`Content-Language`、`Content-Type`、`Expires`、`Last-Modified`、`Pragma`。如果想拿到其他字段，就必须在`Access-Control-Expose-Headers`里面指定。上面的例子指定，`getResponseHeader('FooBar')`可以返回`FooBar`字段的值

**withCredentials 属性**

**`CORS`请求默认不发送`Cookie`和`HTTP`认证信息**。如果要把`Cookie`发到服务器:

一方面要服务器同意，指定`Access-Control-Allow-Credentials`字段
```
Access-Control-Allow-Credentials: true
```
另一方面，开发者必须在`AJAX`请求中打开`withCredentials`属性
```
var xhr = new XMLHttpRequest();
xhr.withCredentials = true;
```
否则，即使服务器同意发送`Cookie`，浏览器也不会发送。或者，服务器要求设置`Cookie`，浏览器也不会处理

但是，如果省略`withCredentials`设置，有的浏览器还是会一起发送`Cookie`。这时，可以显式关闭`withCredentials`
```
xhr.withCredentials = false;
```

**需要注意的是，如果要发送`Cookie`，`Access-Control-Allow-Origin`就不能设为星号，必须指定明确的、与请求网页一致的域名。同时，`Cookie`依然遵循同源政策，只有用服务器域名设置的`Cookie`才会上传，其他域名的`Cookie`并不会上传，且（跨源）原网页代码中的`document.cookie`也无法读取服务器域名下的`Cookie`**


## 对于非简单请求

**非简单请求的CORS请求，会在正式通信之前，增加一次HTTP查询请求，称为"预检"请求（preflight）**

### 预检请求
浏览器发现请求是一个非简单请求是，就自动发出一个"`预检`"请求，要求服务器确认可以这样请求。下面是这个"`预检`"请求的HTTP头信息
```
OPTIONS /cors HTTP/1.1
Origin: http://api.bob.com
Access-Control-Request-Method: PUT
Access-Control-Request-Headers: X-Custom-Header
Host: api.alice.com
Accept-Language: en-US
Connection: keep-alive
User-Agent: Mozilla/5.0...
```

"`预检`"请求用的请求方法是`OPTIONS`，表示这个请求是用来询问的。头信息里面，关键字段是`Origin`，表示请求来自哪个源。
除了`Origin`字段，"`预检`"请求的头信息包括两个特殊字段
- `Access-Control-Request-Method`

    该字段是必须的，用来列出浏览器的`CORS`请求会用到哪些HTTP方法
- `Access-Control-Request-Headers`

    该字段是一个逗号分隔的字符串，指定浏览器`CORS`请求会额外发送的头信息字段

### 预检请求的回应
服务器收到"`预检`"请求以后，检查了`Origin`、`Access-Control-Request-Method`和`Access-Control-Request-Headers`字段以后，确认允许跨源请求，就可以做出回应
```
HTTP/1.1 200 OK
Date: Mon, 01 Dec 2008 01:15:39 GMT
Server: Apache/2.0.61 (Unix)
Access-Control-Allow-Origin: http://api.bob.com
Access-Control-Allow-Methods: GET, POST, PUT
Access-Control-Allow-Headers: X-Custom-Header
Content-Type: text/html; charset=utf-8
Content-Encoding: gzip
Content-Length: 0
Keep-Alive: timeout=2, max=100
Connection: Keep-Alive
Content-Type: text/plain
```
上面的`HTTP`回应中，关键的是`Access-Control-Allow-Origin`字段，表示`http://api.bob.com`可以请求数据。该字段也可以设为`*`，表示同意任意跨源请求

如果浏览器否定了"`预检`"请求，会返回一个正常的`HTTP`回应，但是没有任何`CORS`相关的头信息字段。这时，浏览器就会认定，服务器不同意预检请求，因此触发一个错误，被`XMLHttpRequest`对象的`onerror`回调函数捕获。控制台会打印出如下的报错信息。
```
XMLHttpRequest cannot load http://api.alice.com.
Origin http://api.bob.com is not allowed by Access-Control-Allow-Origin.
```

服务器回应的其他`CORS`相关字段如下。
```
Access-Control-Allow-Methods: GET, POST, PUT
Access-Control-Allow-Headers: X-Custom-Header
Access-Control-Allow-Credentials: true
Access-Control-Max-Age: 1728000
```

- Access-Control-Allow-Methods

    该字段必需，它的值是逗号分隔的一个字符串，表明服务器支持的所有跨域请求的方法。注意，返回的是所有支持的方法，而不单是浏览器请求的那个方法。这是为了避免多次"`预检`"请求
- Access-Control-Allow-Headers

    如果浏览器请求包括`Access-Control-Request-Headers`字段，则`Access-Control-Allow-Headers`字段是必需的。它也是一个逗号分隔的字符串，表明服务器支持的所有头信息字段，不限于浏览器在"`预检`"中请求的字段
- Access-Control-Allow-Credentials

    该字段与简单请求时的含义相同
- Access-Control-Max-Age

    该字段可选，用来指定本次预检请求的有效期，单位为秒。在此期间，不用发出另一条预检请求


## 与JSONP的比较

`CORS`与`JSONP`的使用目的相同，但是比`JSONP`更强大。
`JSONP`只支持`GET`请求，`CORS`支持所有类型的`HTTP`请求。`JSONP`的优势在于支持老式浏览器，以及可以向不支持`CORS`的网站请求数据


## koa-cors

```js
var koa = require('koa');
var cors = require('kcors');

var app = koa();
app.use(cors());
```
`cors`方法可以传入一个对象`options`
```js
{
    origin：允许发来请求的域名，对应响应的`Access-Control-Allow-Origin`，
    allowMethods：允许的方法，默认'GET,HEAD,PUT,POST,DELETE'，对应`Access-Control-Allow-Methods`，
    exposeHeaders： 允许客户端从响应头里读取的字段，对应`Access-Control-Expose-Headers`，
    allowHeaders：这个字段只会在预请求的时候才会返回给客户端，标示了哪些请求头是可以带过来的，对应`Access-Control-Allow-Headers`，
    maxAge：也是在预请求的时候才会返回，标明了这个预请求的响应所返回信息的最长有效期，对应`Access-Control-Max-Age`
    credentials：标示该响应是合法的，对应`Access-Control-Allow-Credentials`
}
```