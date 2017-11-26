# js数组方法

Main Referrence：[MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript)


### [Array.prototype.slice()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/slice)

#### Syntax
```js
arr.slice()
arr.slice(begin)
arr.slice(begin, end)
```

#### Description

slice does not alter. It returns a shallow copy of elements from the original array. Elements of the original array are copied into the returned array as follows:

- **For object references (and not the actual object), slice copies object references into the new array. Both the original and new array refer to the same object. If a referenced object changes, the changes are visible to both the new and original arrays**.
- **For strings, numbers and booleans (not String, Number and Boolean objects), slice copies the values into the new array**. Changes to the string, number or boolean in one array does not affect the other array.
**If a new element is added to either array, the other array is not affected**.


### [Array.prototype.splice()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/splice)

#### Syntax
```js
array.splice(start)
array.splice(start, deleteCount)
array.splice(start, deleteCount, item1, item2, ...)
```

#### Parameters

- `start`

    Index at which to start changing the array (with origin 0). If greater than the length of the array, actual starting index will be set to the length of the array. If negative, will begin that many elements from the end of the array.
- `deleteCount` Optional

    An integer indicating the number of old array elements to remove. If deleteCount is 0, no elements are removed. In this case, you should specify at least one new element. If deleteCount is greater than the number of elements left in the array starting at start, then all of the elements through the end of the array will be deleted.

    If deleteCount is omitted, deleteCount will be equal to (arr.length - start).

- `item1, item2, ...` Optional

    The elements to add to the array, beginning at the start index. If you don't specify any elements, splice() will only remove elements from the array.

#### Return value

An array containing the deleted elements. If only one element is removed, an array of one element is returned. If no elements are removed, an empty array is returned.

**==注释：请注意，splice() 方法与 slice() 方法的作用是不同的，splice() 方法会直接对数组进行修改==**


### [Array.prototype.shift()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/shift)

The `shift()` method removes the first element from an array and returns that element. This method changes the length of the array.

```js
var a = [1, 2, 3];
var b = a.shift();

console.log(a); // [2, 3]
console.log(b); // 1
```


### [Array.prototype.unshift()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/unshift)

The `unshift()` method adds one or more elements to the beginning of an array and returns the new length of the new array.
```js
var a = [1, 2, 3];
a.unshift(4, 5);

console.log(a); // [4, 5, 1, 2, 3]
```