# js 闭包

参考：[前端基础进阶（四）：详细图解作用域链与闭包](http://www.jianshu.com/p/21a16d44f150)

**闭包的定义：当函数可以记住并访问所在的作用域(全局作用域除外)时，就产生了闭包，即使函数是在当前作用域之外执行**

> 简单来说，假设函数A在函数B的内部进行定义了，并且当函数A在执行时，访问了函数B内部的变量对象，那么B就是一个闭包

函数的执行上下文，在执行完毕之后，生命周期结束，那么该函数的执行上下文就会失去引用。其占用的内存空间很快就会被垃圾回收器释放。**可是闭包的存在，会阻止这一过程**

### Example 1

```js
var fn = null;
function foo() {
    var a = 2;
    function innnerFoo() {
        console.log(a);
    }
    fn = innnerFoo; // 将 innnerFoo的引用，赋值给全局变量中的fn
}

function bar() {
    fn(); // 此处的保留的innerFoo的引用
}

foo();
bar(); // 2
```

在上面的例子中，`foo()`执行完毕之后，按照常理，其执行环境生命周期会结束，所占内存被垃圾收集器释放。但是通过`fn = innerFoo`，函数`innerFoo`的引用被保留了下来，复制给了全局变量`fn`。这个行为，导致了`foo`的变量对象，也被保留了下来。于是，函数`fn`在函数`bar`内部执行时，依然可以访问这个被保留下来的变量对象。所以此刻仍然能够访问到变量`a`的值，此时称`foo`为闭包

**因此，通过闭包，我们可以在其他的执行上下文中，访问到函数的内部变量**

**虽然例子中的闭包被保存在了全局变量中，但是闭包的作用域链并不会发生任何改变。在闭包中，能访问到的变量，仍然是作用域链上能够查询到的变量**

### Example 2

```js
var fn = null;
function foo() {
    var a = 2;
    function innnerFoo() {
        console.log(c); // 在这里，试图访问函数bar中的c变量，会抛出错误
        console.log(a);
    }
    fn = innnerFoo; // 将 innnerFoo的引用，赋值给全局变量中的fn
}

function bar() {
    var c = 100;
    fn(); // 此处的保留的innerFoo的引用
}

foo();
bar();
```

## 闭包的应用场景

- 延迟函数 `setTimeout`:

```js
function fn() {
    console.log('this is test.')
}
var timer =  setTimeout(fn, 1000);
console.log(timer);
```

`setTimeout`通过特殊的方式，保留了`fn`的引用，让`setTimeout`的变量对象，并没有在其执行完毕后被垃圾收集器回收。因此`setTimeout`执行结束后一秒，仍然能够执行`fn`函数

一个经典例子是：

```js
for (var i=1; i<=5; i++) {
    setTimeout( function timer() {
        console.log(i);
    }, i*1000 );
}
```

上面的代码，只会每间隔一秒就输出一个6，一共5s输出5个6，因为`setTimeout`保留了`timer`的引用，让其可以访问`setTimeout`的作用域上的i变量，但是访问的时候，i已经变为了6，所以访问到的是6，**即访问的是同一个i(改变之后的i)**

要想每间隔1s依次输出 `1， 2， 3， 4， 5`，则要：

```js
for (var i=1; i<=5; i++) {
    (function (i) {
        setTimeout( function timer() {
            console.log(i);
        }, i * 1000 );
    })(i);
}
```

而上面的代码，`timer`可以访问其作用域链上的i变量，作用域链指向的作用域即立即执行函数的作用于，立即执行函数的变量对象中的i属性，由于立即执行，保留了期望的值，故可以按照期望的那样，依次访问到 `1， 2， 3， 4， 5`，**这时访问的是不同的i**