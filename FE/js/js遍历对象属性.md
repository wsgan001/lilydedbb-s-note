# js 遍历对象属性


## Object.keys()

> The Object.keys() method returns an array of a given object's **++own enumerable properties++**, in the same order as that provided by a for...in loop (**++the difference being that a `for-in` loop enumerates properties in the prototype chain as well++**).

```js
var arr = ['a', 'b', 'c'];
console.log(Object.keys(arr)); // console: ['0', '1', '2']

var obj = { 0: 'a', 1: 'b', 2: 'c' };
console.log(Object.keys(obj)); // console: ['0', '1', '2']
```

`Object.keys()` returns an array of a given object's **++own enumerable properties++**:
```js
// getFoo is property which isn't enumerable
var myObj = Object.create({}, {
  getFoo: {
    value: function () { return this.foo; }
  }
});
myObj.foo = 1;
console.log(Object.keys(myObj)); // ['foo']
```
```js
var myObj = Object.create({}, {
  getFoo: {
    enumerable: true,
    value: function () { return this.foo; }
  }
});
myObj.foo = 1;
console.log(Object.keys(myObj)); // ["getFoo", "foo"]
```


## for ... in

```js
for (variable in object) {
    ...
}
```

> The `for...in` statement iterates over the enumerable properties of an object, in arbitrary order. For each distinct property, statements can be executed.

```js
var obj = { a: 1, b: 2, c: 3 };

for (var prop in obj) {
  console.log('obj.' + prop, '=', obj[prop]);
}
// obj.a = 1
// obj.b = 2
// obj.c = 3
```

**The difference between `Object.keys()` and `for ... in` is that `for-in` loop enumerates properties in the prototype chain as well:**

```js
function triangle () {
    this.a = 1;
    this.b = 2;
    this.c = 3;
}

function ColoredTriangle() {
    this.color = 'red';
}

ColoredTriangle.prototype = new triangle ();

var obj = new ColoredTriangle();

for (var prop in obj) {
    console.log('obj.' + prop + ' = ' + obj[prop]);
}
// obj.color = red
// obj.a = 1
// obj.b = 2
// obj.c = 3
```

**If you only want to consider properties attached to the object itself, and not its prototypes, use `getOwnPropertyNames()` or perform a `hasOwnProperty()` check (`propertyIsEnumerable` can also be used).**

The following example illustrates the use of `hasOwnProperty()`: the inherited properties are not displayed.

```js
for (var prop in obj) {
    if (obj.hasOwnProperty(prop)) {
        console.log('obj.' + prop + ' = ' + obj[prop]);
    }
}
// obj.color = red
```

The following example illustrates the use of `getOwnPropertyNames()`:

```js
console.log(Object.getOwnPropertyNames(obj)); // [ 'color' ]
```


## Array.prototype.forEach()

> The `forEach()` method executes a provided function once for each array element.

Parameters:

- `callback`: Function to execute for each element, taking three arguments:
    - `currentValue`: The current element being processed in the array.
    - `index`: The index of the current element being processed in the array.
    - `array`: The array that `forEach()` is being applied to.

```js
function logArrayElements(element, index, array) {
  console.log('a[' + index + '] = ' + element);
}

// Notice that index 2 is skipped since there is no item at
// that position in the array.
[2, 5, , 9].forEach(logArrayElements);
// a[0] = 2
// a[1] = 5
// a[3] = 9
```


## Object.getOwnPropertyNames()

```js
Object.getOwnPropertyNames(obj)
```

> The `Object.getOwnPropertyNames()` method returns an array of **all properties (enumerable or not)** found directly upon a given object.


## Object.prototype.hasOwnProperty()

```js
obj.hasOwnProperty(prop)
```

> The `hasOwnProperty()` method returns a boolean indicating whether the object has the specified property.