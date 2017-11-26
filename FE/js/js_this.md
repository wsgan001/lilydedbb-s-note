# js this

参考：[前端基础进阶（五）：全方位解读this](http://www.jianshu.com/p/d647aa6d1ae6)

执行上下文的生命周期：

> - 创建
>   - 生成变量对象
>   - 建立作用域链
>   - 确定this指向
> - 执行
>   - 变量赋值
>   - 函数引用
>   - 执行其他代码
> - 执行完毕后出栈，等待被回收


### 几个重要结论

- **`this` 的指向，是在函数被调用的时候确定的**

- **在函数执行过程中，`this` 一旦被确定，就不可更改了**


## 函数中的this

**在一个函数上下文中，`this` 由调用者提供，由调用函数的方式来决定。如果调用者函数，被某一个对象所拥有，那么该函数在调用时，内部的`this`指向该对象。如果函数独立调用，那么该函数内部的`this`，则指向`undefined`。但是在非严格模式中，当`this`指向`undefined`时，它会被自动指向全局对象**

Example:
```js
// 为了能够准确判断，我们在函数内部使用严格模式，因为非严格模式会自动指向全局
function fn() {
    'use strict';
    console.log(this);
}

fn();  // fn是调用者，独立调用
window.fn();  // fn是调用者，被window所拥有
```
`fn()` 作为独立调用者，按照定义的理解，它内部的 `this` 指向就为`undefined`。而`window.fn()`则因为`fn`被`window`所拥有，内部的`this`就指向了`window`对象。


**当`obj`在全局声明时，无论`obj.c`在什么地方调用，这里的`this`都指向全局对象，而当`obj`在函数环境中声明时，这个`this`指向`undefined`，在非严格模式下，会自动转向全局对象**

Example:
```js
'use strict';
var a = 20;
function foo () {
    var a = 1;
    var obj = {
        a: 10,
        c: this.a + 20, // TypeError: Cannot read property 'a' of undefined
        fn: function () {
            return this.a;
        }
    }
    return obj.c;

}
console.log(foo()); // 运行会报错
```


## 使用call，apply显示指定this

call与apply，让我们可以自行手动设置this的指向

call与apply后面的参数，都是向将要执行的函数传递参数。其中call以一个一个的形式传递，apply以数组的形式传递。这是他们唯一的不同

```js
function fn(num1, num2) {
    console.log(this.a + num1 + num2);
}
var obj = {
    a: 20
}

fn.call(obj, 100, 10); // 130
fn.apply(obj, [20, 10]); // 50
```

### call/apply 的使用场景：

- 将类数组对象转换为数组

```js
function test() {
    console.log(arguments); // { '0': 2, '1': 8, '2': 9, '3': 10, '4': 3 }

    // 使用call/apply将arguments转换为数组, 返回结果为数组，arguments自身不会改变
    var arg = [].slice.call(arguments);

    console.log(arg); // [ 2, 8, 9, 10, 3 ]
}

test(2, 8, 9, 10, 3);
```

- 根据自己的需要灵活修改this指向
- 实现继承

```js
// 定义父级的构造函数
var Person = function(name, age) {
    this.name = name;
    this.age  = age;
    this.gender = ['man', 'woman'];
}

// 定义子类的构造函数
var Student = function(name, age, high) {

    // use call
    Person.call(this, name, age);
    this.high = high;
}
Student.prototype.message = function() {
    console.log('name:'+this.name+', age:'+this.age+', high:'+this.high+', gender:'+this.gender[0]+';');
}

new Student('xiaom', 12, '150cm').message(); // name:xiaom, age:12, high:150cm, gender:man;
```

- 在向其他执行上下文的传递中，确保this的指向保持不变

```js
var obj = {
    a: 20,
    getA: function() {
        setTimeout(function() {
            console.log(this.a)
        }, 1000)
    }
}

obj.getA();
```

常规的解决办法很简单，就是使用一个变量，将this的引用保存起来:

```js
var obj = {
    a: 20,
    getA: function() {
        var self = this;
        setTimeout(function() {
            console.log(self.a)
        }, 1000)
    }
}
```

另外就是借助闭包与apply方法，封装一个bind方法:

```js
function bind(fn, obj) {
    return function() {
        return fn.apply(obj, arguments);
    }
}

var obj = {
    a: 20,
    getA: function() {
        setTimeout(bind(function() {
            console.log(this.a)
        }, this), 1000)
    }
}

obj.getA();
```

也可以使用ES5中已经自带的bind方法:

```js
var obj = {
    a: 20,
    getA: function() {
        setTimeout(function() {
            console.log(this.a)
        }.bind(this), 1000)
    }
}
```