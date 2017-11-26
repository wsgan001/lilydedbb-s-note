# jsonp跨域

参考：[直白的话告诉你在 javascript 中如何用 jsonp 实现跨域请求](https://gold.xitu.io/entry/589556d0128fe1006ca72c19?utm_medium=hao.caibaojian.com&utm_source=hao.caibaojian.com)

## JSONP
1. 首先在页面中定义好回调函数
2. 然后在页面通过插入相关标签待`query`参数的形式实现`jsonp`请求传递回调函数名字
3. 后台得到回调函数名字，并将需要处理的数据传递给回调函数，最后向前台返回回调函数的`调用`，最后一步切记是传回回调函数的调用

#### 客户端 `index.html`:
```html
<!DOCTYPE html>
<html lang="Zh-cn">
<head>
    <meta charset="utf-8"/>
    <title>demo</title>
</head>
<body>
<script type="text/javascript">
    //第一步，现在前台定义回调函数
    function addNum (num1, num2){
        var sum = num1 + num2;
        console.log("两数相加的结果是" + sum);
        return sum;
    };

    //第二步，插入script标签并通过传入query参数的形式传递回调函数的名字给后台
    (function () {
        var _script = document.createElement('script');
        _script.type = 'text/javascript';
        _script.src = 'http://localhost:8000/test?callback=addNum&a=1&b=2';
        document.body.appendChild(_script);
    })();
</script>
</body>
</html>
```

#### 服务端（使用`koa`实现）`server.js`:
```js
// server.js
'use strict'
const koa = require('koa')
const router = require('koa-router')()
const app = koa()
const port = process.env.PORT || 8000

router.get('/test', function *(){
    var callback = this.request.query.callback
    var a = this.request.query.a
    var b = this.request.query.b
    this.body = callback + "(" + a + "," + b + ")"
})

app.use(router.routes())
app.use(router.allowedMethods())

app.on('error', function (err, ctx) {
    console.log('server error: ', err)
    return this.body = SERVER_ERR
})

if (!module.parent) {
    app.listen(port)
}
```


#### 服务端（使用`express`实现）`server.js`:
```js
'use strict'
const express = require('express')
const app = express()
const port = process.env.PORT || 8000

app.get('/test', function (req, res){
    var callback = req.query.callback
    var a = req.query.a
    var b = req.query.b
    res.send(callback + "(" + a + "," + b + ")")
})

app.on('error', function (err, ctx) {
    console.log('server error: ', err)
    return this.body = SERVER_ERR
})

if (!module.parent) {
    app.listen(port)
}
```


#### 服务端（用`php`实现）`server.php`:
```php
<?php
    $frontendCallback = $_GET['callback'];
    $a = $_GET['a'];
    $b = $_GET['b'];
    echo $frontendCallback."($a, $b)";
?>
```
`index.html`中对应的请求改为：
```js
_script.src = 'http://localhost:8888/server.php?callback=addNum&a=1&b=2';
```