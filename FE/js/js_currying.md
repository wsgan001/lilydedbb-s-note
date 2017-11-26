# js 柯里化 (Currying)

参考：[前端基础进阶（八）：深入详解函数的柯里化](http://www.jianshu.com/p/5e1899fe7d6b)

> 柯里化（英语：Currying），又称为部分求值，是把接受多个参数的函数变换成接受一个单一参数（最初函数的第一个参数）的函数，并且返回一个新的函数的技术，新函数接受余下参数并返回运算结果。

如下效果：

```js
// 输出结果，可自由组合的参数
console.log(add(1, 2, 3, 4, 5));  // 15
console.log(add(1, 2, 3, 4)(5));  // 15
console.log(add(1)(2)(3)(4)(5));  // 15
```


### 函数的隐式转换

没有重新定义`toString`与`valueOf`时，函数的隐式转换会调用默认的`toString`方法，它会将函数的定义内容作为字符串返回，如：

```js
function fn() {
    return 20;
}
console.log(fn + 10);
// function fn() {
//     return 20;
// }10
```

如果主动定义了函数的 `toString` 方法，那么则以我们定义的 `toString` 方法规则进行隐式转换，如：

```js
function fn() {
    return 20;
}
fn.toString = function() {
    return 10;
}
console.log(fn + 10); // 20
```

如果`toString`和`valueOf`都定义了，则`valueOf`的优先级会`toString`高一点，即以`valueOf`定义的规则进行隐式转换，如：

```js
function fn() {
    return 20;
}
fn.toString = function() {
    return 10;
}
fn.valueOf = function() {
    return 5;
}
console.log(fn + 10); // 15
```


## 柯里化的简单实现

```js
function add () {
    var args = [].slice.apply(arguments)
    var adder = function () {
        var _adder = function () {
            [].push.apply(args, arguments)
            return _adder
        }
        _adder.toString = function () {
            return args.reduce(function (a, b) {
                return a + b
            })
        }
        return _adder
    }
    return adder(args)
}

console.log(add(1, 2, 3, 4, 5));  // 15
console.log(add(1, 2, 3, 4)(5));  // 15
console.log(add(1)(2)(3)(4)(5));  // 15
```