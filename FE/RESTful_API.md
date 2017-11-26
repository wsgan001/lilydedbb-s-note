# RESTful API 设计

主要参考：[阮一峰的网络日志 RESTful API 设计指南](http://www.ruanyifeng.com/blog/2014/05/restful_api.html)


### 协议

`API`与用户的通信协议，总是使用`HTTPS`协议


### 域名
应该尽量将`API`部署在专用域名之下。
```
https://api.example.com
```


### 版本（Versioning）

应该将`API`的版本号放入`URL`
```
https://api.example.com/v1/
```
另一种做法是，将版本号放在`HTTP`头信息中


### HTTP动词

对于资源的具体操作类型，由`HTTP`动词表示。
常用的`HTTP`动词有下面五个（括号里是对应的SQL命令）。
- `GET`（`SELECT`）：从服务器取出资源（一项或多项）
- `POST`（`CREATE`）：在服务器新建一个资源
- `PUT`（`UPDATE`）：在服务器更新资源（客户端提供改变后的完整资源）
- `PATCH`（`UPDATE`）：在服务器更新资源（客户端提供改变的属性）
- `DELETE`（`DELETE`）：从服务器删除资源


### 状态码（Status Codes）

服务器向用户返回的状态码和提示信息，常见的有以下一些（方括号中是该状态码对应的`HTTP`动词）
- 200 OK - [GET]：服务器成功返回用户请求的数据，该操作是幂等的（Idempotent）
- 201 CREATED - [POST/PUT/PATCH]：用户新建或修改数据成功
- 202 Accepted - [*]：表示一个请求已经进入后台排队（异步任务）
- 204 NO CONTENT - [DELETE]：用户删除数据成功
- 400 INVALID REQUEST - [POST/PUT/PATCH]：用户发出的请求有错误，服务器没有进行新建或修改数据的操作，该操作是幂等的
- 401 Unauthorized - [*]：表示用户没有权限（令牌、用户名、密码错误）
- 403 Forbidden - [*] 表示用户得到授权（与401错误相对），但是访问是被禁止的
- 404 NOT FOUND - [*]：用户发出的请求针对的是不存在的记录，服务器没有进行操作，该操作是幂等的
- 406 Not Acceptable - [GET]：用户请求的格式不可得（比如用户请求JSON格式，但是只有XML格式）
- 410 Gone -[GET]：用户请求的资源被永久删除，且不会再得到的
- 422 Unprocesable entity - [POST/PUT/PATCH] 当创建一个对象时，发生一个验证错误
- 500 INTERNAL SERVER ERROR - [*]：服务器发生错误，用户将无法判断发出的请求是否成功


### 错误处理（Error handling）

如果状态码是`4xx`，就应该向用户返回出错信息。一般来说，返回的信息中将`error`作为键名，出错信息作为键值即可
```json
{
    error: "Invalid API key"
}
```