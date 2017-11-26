# JavaScript 数组方法对比

原文：[JavaScript 数组方法对比](http://jinlong.github.io/2017/02/04/javascript-array-methods-mutating-vs-non-mutating/?utm_medium=hao.caibaojian.com&utm_source=hao.caibaojian.com)

## I. 新增：影响原数组

使用 `array.push()` 和 `array.ushift()` 新增元素会影响原来的数组

```js
let mutatingAdd = ['a', 'b', 'c', 'd', 'e']; 
mutatingAdd.push('f'); // ['a', 'b', 'c', 'd', 'e', 'f']
mutatingAdd.unshift('z'); // ['z', 'b', 'c', 'd', 'e' 'f']
```

## II. 新增：不影响原数组

两种方式新增元素不会影响原数组，第一种是 `array.concat()` 

```js
const arr1 = ['a', 'b', 'c', 'd', 'e'];
const arr2 = arr1.concat('f'); // ['a', 'b', 'c', 'd', 'e', 'f']  （注：原文有误，我做了修改 “.” ---> “,”）
console.log(arr1); // ['a', 'b', 'c', 'd', 'e']
```

第二种方法是使用 JavaScript 的展开（`spread`）操作符，展开操作符是`...`

```js
const arr1 = ['a', 'b', 'c', 'd', 'e'];
const arr2 = [...arr1, 'f']; // ['a', 'b', 'c', 'd', 'e', 'f']  
const arr3 = ['z', ...arr1]; // ['z', 'a', 'b', 'c', 'd', 'e']
```
展开操作符会复制原来的数组，从原数组取出所有元素，然后存入新的环境

## III. 移除：影响原数组

使用 `array.pop()` 和 `array.shift()` 移除数组元素时，会影响原来的数组

```
let mutatingRemove = ['a', 'b', 'c', 'd', 'e'];  
mutatingRemove.pop(); // ['a', 'b', 'c', 'd']  
mutatingRemove.shift(); // ['b', 'c', 'd']
array.pop() 和 array.shift()
```

返回被移除的元素，可以通过一个变量获取被移除的元素

```js
let mutatingRemove = ['a', 'b', 'c', 'd', 'e'];
const returnedValue1 = mutatingRemove.pop();  
console.log(mutatingRemove); // ['a', 'b', 'c', 'd']  
console.log(returnedValue1); // 'e'
const returnedValue2 = mutatingRemove.shift();  
console.log(mutatingRemove); // ['b', 'c', 'd']  
console.log(returnedValue2); // 'a'
```

`array.splice()` 也可以删除数组的元素

```js
let mutatingRemove = ['a', 'b', 'c', 'd', 'e'];  
mutatingRemove.splice(0, 2); // ['c', 'd', 'e']
```

像 `array.pop()` 和 `array.shift()` 一样，`array.splice()` 同样返回移除的元素

```js
let mutatingRemove = ['a', 'b', 'c', 'd', 'e'];  
let returnedItems = mutatingRemove.splice(0, 2);  
console.log(mutatingRemove); // ['c', 'd', 'e']  
console.log(returnedItems) // ['a', 'b']
```

## IV. 移除：不影响原数组

JavaScript 的 `array.filter()` 方法基于原数组创建一个新数组，新数组仅包含匹配特定条件的元素

```js
const arr1 = ['a', 'b', 'c', 'd', 'e'];
const arr2 = arr1.filter(a => a !== 'e'); // ['a', 'b', 'c', 'd']
// 或者
const arr2 = arr1.filter(a => {  
  return a !== 'e';
}); // ['a', 'b', 'c', 'd']
```

另一种不影响原数组的方式是 `array.slice()`（不要与 `array.splice()` 混淆）

```js
const arr1 = ['a', 'b', 'c', 'd', 'e'];  
const arr2 = arr1.slice(1, 5) // ['b', 'c', 'd', 'e']  
const arr3 = arr1.slice(2) // ['c', 'd', 'e']
```

## V. 替换：影响原数组

如果知道替换哪一个元素，可以使用 `array.splice()`

```js
let mutatingReplace = ['a', 'b', 'c', 'd', 'e'];  
mutatingReplace.splice(2, 1, 30); // ['a', 'b', 30, 'd', 'e']  
// 或者
mutatingReplace.splice(2, 1, 30, 31); // ['a', 'b', 30, 31, 'd', 'e']
```

## VI. 替换：不影响原数组

可以使用 `array.map()` 创建一个新数组，并且可以检查每一个元素，根据特定的条件替换它们

```js
const arr1 = ['a', 'b', 'c', 'd', 'e']  
const arr2 = arr1.map(item => {  
  if(item === 'c') {
    item = 'CAT';
  }
  return item;
}); // ['a', 'b', 'CAT', 'd', 'e']
```