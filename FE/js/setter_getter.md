# getter & setter

## [getter](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/get)

> The get syntax binds an object property to a function that will be called when that property is looked up

### Syntax
```
{get prop() { ... } }
{get [expression]() { ... } }
```

#### Parameters

- `prop` The name of the property to bind to the given function.
- `expression` Starting with ECMAScript 2015, you can also use expressions for a computed property name to bind to the given function.

Note the following when working with the get syntax:

- It can have an identifier which is either a number or a string;
- It must have exactly zero parameters;
- It must not appear in an object literal with another get or with a data entry for the same property (`{ get x() { }, get x() { } }` and `{ x: ..., get x() { }` } are forbidden).

**A getter can be removed using the `delete` operator.**

#### Example:

```js
var obj = {
  a: 1,
  get b () {
    return this.a + 1;
  }
}

obj.a
// 1
obj.b
// 2
obj.a = 4
// 4
obj.b
// 5
delete obj.b
// true
obj.b
// undefined
```

**Using a computed property name:**

Use expressions for a computed property name to bind to the given function.
```js
var str = 'b'
var obj = {
  a: 1,
  get [str] () {
    return this.a + 1;
  }
}

obj.b
// 2
delete obj.b
// true
obj.b
// undefined
```

**Defining a getter on existing objects using `defineProperty`:**

```js
var obj = {
  a: 1
}
Object.defineProperty(obj, 'b', { get: function () { return this.a + 1; }})
// Object {a: 1}a: 1b: 2get b: ()__proto__: Object
obj.b
// 2
```

```js
// Using a computed property name
var str = 'b';
var obj = {
  a: 1
}
Object.defineProperty(obj, str, { get: function () { return this.a + 1; }})
// Object {a: 1}
obj.b
// 2
```


## [setter](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/set)

> The set syntax binds an object property to a function to be called when there is an attempt to set that property

### Syntax
```
{set prop(val) { . . . }}
{set [expression](val) { . . . }}
```

#### Parameters

- `prop` The name of the property to bind to the given function.
- `val` An alias for the variable that holds the value attempted to be assigned to prop.
- `expression` Starting with ECMAScript 2015, you can also use expressions for a computed property name to bind to the given function.

### Examples

```js
var obj = {
  a: 1,
  set b (value) {
  	this.a += value;
  }
}

obj.b = 10
// 10
obj.a
// 11
```

**Using a computed property name:**

Use expressions for a computed property name to bind to the given function.
```js
var str = 'b'
var obj = {
  a: 1,
  set [str] (value) {
  	this.a += value;
  }
}

obj.b = 1
// 1
obj.a
// 2
```

**Defining a setter on existing objects using `defineProperty`:**

```js
var obj = {
  a: 1
}
Object.defineProperty(obj, 'b', { set: function (value) { this.a += value; } })
// Object {a: 1}
obj.b = 10
// 10
obj.a
// 11
```
```js
// Using a computed property name
var str = 'b'
var obj = {
  a: 1
}
Object.defineProperty(obj, str, { set: function (value) { this.a += value; } })
// Object {a: 1}
obj.b = 10
// 10
obj.a
// 11
```