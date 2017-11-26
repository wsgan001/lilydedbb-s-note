# js的浅复制和深复制

> - 浅复制：浅复制是复制引用，复制后的引用都是指向同一个对象的实例，彼此之间的操作会互相影响
> - 深复制：深复制不是简单的复制引用，而是在堆中重新分配内存，并且把源对象实例的所有属性都进行新建复制，以保证深复制的对象的引用图不包含任何原有对象或对象图上的任何对象，复制后的对象与原来的对象是完全隔离的

### Array的slice和concat方法

Array的`slice`和`concat`方法都会返回一个新的数组实例，但是这两个方法对于数组中的对象元素却没有执行深复制，而只是复制了引用了，因此这两个方法并不是真正的深复制，通过以下代码进行理解：

```js
var array = [1,2,3];
var array_shallow = array;
var array_concat = array.concat();
var array_slice = array.slice(0);
console.log(array === array_shallow);   //true
console.log(array === array_slice);     //false
console.log(array === array_concat);    //false
```
可以看出，`concat`和`slice`返回的不同的数组实例，这与直接的引用复制是不同的

```js
var array = [1, [1,2,3], {name:"array"}];
var array_concat = array.concat();
var array_slice = array.slice(0);
//改变array_concat中数组元素的值
array_concat[1][0] = 5;
console.log(array[1]);    //[5,2,3]
console.log(array_slice[1]);  //[5,2,3]
//改变array_slice中对象元素的值
array_slice[2].name = "array_slice";
console.log(array[2].name);   //array_slice
console.log(array_concat[2].name); //array_slice
```
可以看出`concat`和`slice`并不是真正的深复制，数组中的对象元素(`Object`,`Array`等)只是复制了引用


### JSON对象的parse和stringify

`JSON`对象是`ES5`中引入的新的类型（支持的浏览器为IE8+），`JSON`对象`parse`方法可以将`JSON`字符串反序列化成JS对象，`stringify`方法可以将`JS`对象序列化成`JSON`字符串，借助这两个方法，也可以实现对象的深复制

Example:
```js
var source = {
    name:"source",
    child:{
        name:"child"
    }
}
var target = JSON.parse(JSON.stringify(source));
//改变target的name属性
target.name = "target";
console.log(source.name);   //source
console.log(target.name);   //target
//改变target的child
target.child.name = "target child";
console.log(source.child.name);  //child
console.log(target.child.name);  //target child
```

这个方法使用较为简单，可以满足基本的深复制需求，而且能够处理JSON格式能表示的所有数据类型，但是**对于正则表达式类型、函数类型等无法进行深复制(而且会直接丢失相应的值)**，同时如果对象中存在循环引用的情况也无法正确处理
