# JavaScript 注意点

- **`==` 与 `===` 的区别**
    `==` 比较时，会将两边的数值转换为同等类型，然后再去比较；
    `===` 为严格比较，会同时比较类型与值，只有当类型和值都相同时才为`true`

    **注：应当尽量使用`===`**
    ```js
    // Example of comparators
    0 == false; // true
    0 === false; // false

    2 == '2'; // true
    2 === '2'; // false
    ```

- **`null` 与 `undefined` 的区别**

    JavaScript 中，null 是一个可以被分配的值，设置为 null 的变量意味着其无值。而 undefined 则代表着某个变量虽然声明了但是尚未进行过任何赋值

    ```js
    console.log(typeof null) // object
    console.log(typeof undefined) // undefined
    console.log(null == undefined) // true
    console.log(null === undefined) // false
    ```

- `delete` 操作符：

    - `delete` 只是断开属性与对象的联系，而不会去操作对象中的属性

        ```js
        var obj = {
           a: 0,
           b: 1
        }
        console.log('a' in obj) // true
        delete obj.a
        console.log('a' in obj) // false
        for (var key in obj) {
            console.log(key + ': ' + obj[key]);
        }
        // b: 1
        ```

    - **`delete` 只能删除自有属性，不能删除继承属性（删除继承属性必须从定义这个属性的圆形对象删除它，而且这会影响到所有继承自这个原型的对象）**

    - `delete` 可以像删除对象属性一样使用来删除数组元素，但是`delete`操作符不改变数组长度，如：

        ```js
        a = [0, 1, 2, 3, 4, 5]
        console.log(a.length) // 6
        delete a[0]
        console.log(0 in a) // false
        console.log(a.length) // 6
        ```

- 移动平台浏览器中`touch`与`click`事件的触发顺序：

    **touchstart -> touchmove -> touchend -> click**

- 不可以冒泡的事件：
    - focus
    - blur
    - load
    - unload

- `mouseenter` and `mouseover`:

    不论鼠标指针穿过被选元素或其子元素，都会触发 `mouseenter` 事件；

    只有在鼠标指针穿过被选元素时，才会触发 `mouseenter` 事件
