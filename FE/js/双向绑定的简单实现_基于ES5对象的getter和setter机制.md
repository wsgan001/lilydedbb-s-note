# 双向绑定的简单实现——基于ES5对象的getter/setter机制

原文链接：[https://zhuanlan.zhihu.com/p/25003235](https://zhuanlan.zhihu.com/p/25003235)

在```双向绑定的简单实现——基于“脏检测”```中，使用“```脏检测```”的机制，实现了一个简单的双向绑定计数器。尽管逻辑比较清晰简单，性能也还可以，但每次都遍历DOM节点，也是会有一些性能浪费的。```ES5```提供了```Object.defineProperty```与```Object.defineProperties```两个```API```，允许为对象的属性增设```getter/setter```函数。利用它们，可以很方便地监听数据变更，并且在变更时加入自己的逻辑。

本文将利用```ES5```对象的```getter/setter```机制，模仿```Vue```的原理，来实现一个简单的双向绑定（暂且称为```Lue```吧）

### 语法设计

本次基于```Vue```的三个指令：```v-model```、```v-bind```和```v-click```，来实现数据双向绑定。DOM结构：
```html
<div id="app">
    <form>
        <input type="text" v-model="count" />
        <button type="button" v-click="increment">increment</button>
    </form>
    <p v-bind="count"></p>
</div>
```
希望使用类似```Vue```的语法创建一个```Lue```实例：
```js
new Lue({
    el: "#app",
    data: {
        count: 0,
    },
    methods: {
        increment: function(){
            this.count++;
        }
    }
});
```

### 开始

需要创建一个```Lue```类：
```js
function Lue(options){
    this._init(options);
}
```
其中包含一个```_init```初始化函数，定义如下：
```js
Lue.prototype._init = function (options) {
    this.$options = options;
    this.$el = document.querySelectorAll(options.el)
    this.$data = options.data;
    this.$methods = options.methods;
};
```

### 绑定数据对象的改造

为了实现双向绑定，首先需要使用```Object.defineProperty```对```data```中的数据对象进行改造，添加```getter/setter```函数，使其在赋值和取值时能够被监听
```js
// 对象属性重定义
Lue.prototype.convert = function (key, value) {
    var binding = this._binding[key];
    Object.defineProperty(this.$data, key, {
        enumerable:true,
        configurable:true,
        get: function () {
            return value;
        },
        set: function (newValue) {
            if(value != newValue) {
                value = newValue;
                // 遍历该数据对象的directive并依次调用update
                binding._directives.forEach(function (item) {
                    item.update();
                })
            }
        }
    })
};
```

对```data```中的数据对象进行遍历调用```convert```：
```js
// 遍历数据域，添加getter/setter
Lue.prototype._parseData = function (obj) {
    var value;
    for (var key in obj) {
        if(obj.hasOwnProperty(key)){
            value=obj[key];
            if(typeof value ==='object'){
                this._parseData(value);
            } else {
                this.convert(key, value);
            }
        }
    }
};
```

### 绑定函数的改造

对于```methods```域中的函数，由于API要求函数作用域与```vm.$data```一致，因此需要对其中的函数进行改造：
```js
//遍历函数域，对绑定的函数进行改造
Lue.prototype._parseFunc = function (funcList) {
    var self = this;
    for (var key in funcList) {
        if (funcList.hasOwnProperty(key)) {
            var func = funcList[key];
            funcList[key] = (function () {
                return function () {
                    func.apply(self.$data, arguments);
                }
            })();
        }
    }
};
```

上述两个改造流程必须发生在初始化阶段:
```js
Lue.prototype._init=function(options){
    this.$options=options;                              //传入的实例配置
    this.$el=document.querySelector(options.el);        //实例绑定的根节点
    this.$data=options.data;                            //实例的数据域
    this.$methods=options.methods;                      //实例的函数域

    this._parseData(this.$data);
    this._parseFunc(this.$methods);
};
```

至此，对于```Lue```实例的数据与函数的初始化就完成了。下面需要考虑的是，当数据发生变化时，如何更新```DOM```元素呢？

最容易想到的一个做法是遍历所有含有```v-bind```指令的```DOM```模板，利用相应的绑定数据在内存中拼装成一个```fragment```，然后再将新的```fragment```替换旧的```DOM```结构。但是这个方案存在两个问题：

* 修改未绑定至```DOM```的数据时，也会引发```DOM```的重新渲染。
* 修改某个数据会导致所有```DOM```重新渲染，而非只更新数据变动了的相关```DOM```

为了解决这个问题，需要引入```Directive```

## Directive（指令）

Directive的作用就是建立一个DOM节点和对应数据的映射关系。它的定义和原型方法如下：

```js
function Directive (name, el, vm, exp, attr) {
    this.name = name;         //指令名称，例如文本节点，该值设为"text"
    this.el = el;             //指令对应的DOM元素
    this.vm = vm;             //指令所属Lue实例
    this.exp = exp;           //指令对应的值，本例如"count"
    this.attr = attr;         //绑定的属性值，本例为"innerHTML"

    this.update();          //首次绑定时更新
}

Directive.prototype.update = function () {
    this.el[this.attr] = this.vm.$data[this.exp];
};
```

**如何让数据对象的```setter```在触发时，调用与之相关的```directive```？**

首先需要在实例化时建立一个```_binding```对象，该对象集合了真正与DOM绑定的那些数据对象（data中声明的对象的子集）。因此又一次修改```_init```函数：
```js
Lue.prototype._init=function(options){
    this.$options=options;                              //传入的实例配置
    this.$el=document.querySelector(options.el);        //实例绑定的根节点
    this.$data=options.data;                            //实例的数据域
    this.$methods=options.methods;                      //实例的函数域

    //与DOM绑定的数据对象集合
    //每个成员属性有一个名为_directives的数组，用于在数据更新时触发更新DOM的各directive
    this._binding={};
    this._parseData(this.$data);
    this._parseFunc(this.$methods);
};
```
_binding对象中属性的一个例子如下：
```js
this._binding={
    count:{
        _directives:[]          //该数据对象的相关指令数组
    }
}
```

然后改写遍历数据域的函数与绑定数据时的setter函数：
```js
// 遍历数据域，添加getter/setter
Lue.prototype._parseData = function (obj) {
    var value;
    for (var key in obj) {
        if (obj.hasOwnProperty(key)) {
            value = obj[key];
            this._binding[key] = {
                _directives: []
            };
            if (typeof value === 'object') {
                this._parseData(value);
            } else {
                this.convert(key, value);
            }
        }
    }
};
```
```js
set: function (newValue) {
    if(value != newValue) {
        value = newValue;
        // 遍历该数据对象的directive并依次调用update
        binding._directives.forEach(function (item) {
            item.update();
        })
    }
}
```

### 编译DOM节点

实现双向绑定的最后一步，就是编译带有v-model、v-click与v-bind指令的DOM节点。加入一个名为_compile的原型函数：
```js
Lue.prototype._compile = function (root) {
    var self = this;
    var nodes = root.children;
    for (var i = 0; i < nodes.length; i++) {
        var node = nodes[i];
        // 若该元素有子节点，则先递归编译其子节点
        if (node.children.length) {
            this._compile(node);
        }

        if (node.hasAttribute('v-click')) {
            node.addEventListener('click', (function () {
                var attrVal = node.getAttribute('v-click');
                var args = /\(.*\)/.exec(attrVal);
                if(args) {              //如果函数带参数,将参数字符串转换为参数数组
                    args = args[0];
                    attrVal = attrVal.replace(args, '');
                    args = args.replace(/[\(|\)|\'|\"]/g, '').split(',');
                } else {
                    args = [];
                }
                return function () {
                    self.$methods[attrVal].apply(self.$data, args);
                }
            })());
        }

        if(node.hasAttribute(('v-model')) && node.tagName == 'INPUT' || node.tagName == 'TEXTAREA'){
            //如果是input或textarea标签
            node.addEventListener('input', (function (key) {
                var attrVal = node.getAttribute('v-model');
                //将value值的更新指令添加至_directives数组
                self._binding[attrVal]._directives.push(new Directive('input', node, self, attrVal, 'value'))
                return function () {
                    self.$data[attrVal] = nodes[key].value;
                }
            })(i));
        }

        if(node.hasAttribute('v-bind')){
            var attrVal = node.getAttribute('v-bind');
            //将innerHTML的更新指令添加至_directives数组
            self._binding[attrVal]._directives.push(new Directive('text', node, self, attrVal, 'innerHTML'))
        }
    }
};
```

改写```Lue```的```_init```原型方法，使其在初始化时即对DOM进行编译：
```js
Lue.prototype._init=function(options){
    this.$options=options;                              //传入的实例配置
    this.$el=document.querySelector(options.el);        //实例绑定的根节点
    this.$data=options.data;                            //实例的数据域
    this.$methods=options.methods;                      //实例的函数域

    //与DOM绑定的数据对象集合
    //每个成员属性有一个名为_directives的数组，用于在数据更新时触发更新DOM的各directive
    this._binding={};
    this._parseData(this.$data);
    this._parseFunc(this.$methods);

    this._compile(this.$el);                //编译DOM节点
};
```
至此，便实现了一个基于```getter/setter```，模仿```Vue```的简单的双向绑定。整个体系搭建并不复杂，只需要注意其中三个核心的部分：```getter/setter```，```Directive```以及```binding```。细心的读者不难发现，在本文的实现中，如果线程频繁触发数据变更，会导致```DOM```频繁更新，非常影响性能。在真正的生产环境中，```DOM```的更新不是数据变更后立马更新，而是被加入到批处理队列，等待主线程运行完后再进行批处理。

### 完整代码
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>双向绑定的简单实现——基于ES5对象的getter/setter机制</title>
</head>
<body>
<div id="app">
    <form>
        <input type="text" v-model="count" />
        <button type="button" v-click="increment">increment</button>
        <button type="button" v-click="alert('Hello world')">alert</button>
    </form>
    <p v-bind="count"></p>
</div>
<script type="text/javascript">

    function Lue(options) {
        this._init(options);
    }

    Lue.prototype._init = function (options) {
        this.$options = options;
        this.$el = document.querySelector(options.el)
        this.$data = options.data;
        this.$methods = options.methods;

        //与DOM绑定的数据对象集合
        //每个成员属性有一个名为_directives的数组，用于在数据更新时触发更新DOM的各directive
        this._binding = {};

        this._parseData(this.$data);
        this._parseFunc(this.$methods);

        this._compile(this.$el);                //编译DOM节点
    };

    // 对象属性重定义
    Lue.prototype.convert = function (key, value) {
        var binding = this._binding[key];
        Object.defineProperty(this.$data, key, {
            enumerable:true,
            configurable:true,
            get: function () {
                return value;
            },
            set: function (newValue) {
                if(value != newValue) {
                    value = newValue;
                    // 遍历该数据对象的directive并依次调用update
                    binding._directives.forEach(function (item) {
                        item.update();
                    })
                }
            }
        })
    };

    // 遍历数据域，添加getter/setter
    Lue.prototype._parseData = function (obj) {
        var value;
        for (var key in obj) {
            if (obj.hasOwnProperty(key)) {
                value = obj[key];
                this._binding[key] = {
                    _directives: []
                };
                if (typeof value === 'object') {
                    this._parseData(value);
                } else {
                    this.convert(key, value);
                }
            }
        }
    };

    //遍历函数域，对绑定的函数进行改造
    Lue.prototype._parseFunc = function (funcList) {
        var self = this;
        for (var key in funcList) {
            if (funcList.hasOwnProperty(key)) {
                var func = funcList[key];
                funcList[key] = (function () {
                    return function () {
                        func.apply(self.$data, arguments);
                    }
                })();
            }
        }
    };

    Lue.prototype._compile = function (root) {
        var self = this;
        var nodes = root.children;
        for (var i = 0; i < nodes.length; i++) {
            var node = nodes[i];
            // 若该元素有子节点，则先递归编译其子节点
            if (node.children.length) {
                this._compile(node);
            }

            if (node.hasAttribute('v-click')) {
                node.addEventListener('click', (function () {
                    var attrVal = node.getAttribute('v-click');
                    var args = /\(.*\)/.exec(attrVal);
                    if(args) {              //如果函数带参数,将参数字符串转换为参数数组
                        args = args[0];
                        attrVal = attrVal.replace(args, '');
                        args = args.replace(/[\(|\)|\'|\"]/g, '').split(',');
                    } else {
                        args = [];
                    }
                    return function () {
                        self.$methods[attrVal].apply(self.$data, args);
                    }
                })());
            }

            if(node.hasAttribute(('v-model')) && node.tagName == 'INPUT' || node.tagName == 'TEXTAREA'){
                //如果是input或textarea标签
                node.addEventListener('input', (function (key) {
                    var attrVal = node.getAttribute('v-model');
                    //将value值的更新指令添加至_directives数组
                    self._binding[attrVal]._directives.push(new Directive('input', node, self, attrVal, 'value'))
                    return function () {
                        self.$data[attrVal] = nodes[key].value;
                    }
                })(i));
            }

            if(node.hasAttribute('v-bind')){
                var attrVal = node.getAttribute('v-bind');
                //将innerHTML的更新指令添加至_directives数组
                self._binding[attrVal]._directives.push(new Directive('text', node, self, attrVal, 'innerHTML'))
            }
        }
    };

    function Directive (name, el, vm, exp, attr) {
        this.name = name;         //指令名称，例如文本节点，该值设为"text"
        this.el = el;             //指令对应的DOM元素
        this.vm = vm;             //指令所属Lue实例
        this.exp = exp;           //指令对应的值，本例如"count"
        this.attr = attr;         //绑定的属性值，本例为"innerHTML"

        this.update();          //首次绑定时更新
    }

    Directive.prototype.update = function () {
        this.el[this.attr] = this.vm.$data[this.exp];
    };

    window.onload = function () {
        new Lue({
            el: "#app",
            data: {
                count: 0,
            },
            methods: {
                increment: function(){
                    this.count++;
                }
            }
        });
    }
</script>
</body>
</html>
```