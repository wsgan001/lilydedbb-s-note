# [Inheritance and the prototype chain](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Inheritance_and_the_prototype_chain)

### Inheriting properties

JavaScript objects are dynamic "bags" of properties (referred to as own properties). JavaScript objects have a link to a prototype object. When trying to access a property of an object, the property will not only be sought on the object but on the prototype of the object, the prototype of the prototype, and so on until either a property with a matching name is found or the end of the prototype chain is reached.

### Inheriting "methods"

JavaScript does not have "methods" in the form that class-based languages define them. In JavaScript, any function can be added to an object in the form of a property. An inherited function acts just as any other property, including `property shadowing` as shown above (in this case, a form of `method overriding`).

```js
var o = {
  a: 2,
  m: function() {
    return this.a + 1;
  }
};

console.log(o.m()); // 3
// When calling o.m in this case, 'this' refers to o

var p = Object.create(o);
// p is an object that inherits from o

p.a = 4; // creates an own property 'a' on p
console.log(p.m()); // 5
// when p.m is called, 'this' refers to p.
// So when p inherits the function m of o, 
// 'this.a' means p.a, the own property 'a' of p
```

### With a constructor

A "`constructor`" in JavaScript is "just" a function that happens to be called with the **`new operator`**.
```js
function Graph() {
  this.vertices = [];
  this.edges = [];
}

Graph.prototype = {
  addVertex: function(v) {
    this.vertices.push(v);
  }
};

var g = new Graph();

g.__proto__ === Graph.prototype
// true
```

### With Object.create

ECMAScript 5 introduced a new method: Object.create(). Calling this method creates a new object. The prototype of this object is the first argument of the function:
```js
var a = {a: 1}; 
// a ---> Object.prototype ---> null

var b = Object.create(a);
// b ---> a ---> Object.prototype ---> null
console.log(b.a); // 1 (inherited)

var c = Object.create(b);
// c ---> b ---> a ---> Object.prototype ---> null

c.__proto__ == b
// true
c.__proto__.__proto__ === a
// true
c.__proto__.__proto__.__proto__ === a.__proto__
// true
a.__proto__ === Object.prototype
// true
Object.prototype.__proto__ === null
// true
```

### `prototype` and `Object.getPrototypeOf`

**In short, `prototype` is for types, while `Object.getPrototypeOf()` is the same for `instances`**
```js
function Foo() {
    // ...
}
var o = new Foo()

Foo.prototype === Object.getPrototypeOf(o)
// true
```