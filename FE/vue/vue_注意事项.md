# Vue 注意事项

- 不要在`v-html`中使用`filters`
- 不要再子组件中改变`props`中，传递过来的变量
- 有时你想向已有对象上添加一些属性，例如使用 `Object.assign()` 或 `_.extend()` 方法来添加属性。但是，添加到对象上的新属性不会触发更新

    由于 JavaScript 的限制， Vue 不能检测以下变动的数组：
    1. 当你利用索引直接设置一个项时，例如： `vm.items[indexOfItem] = newValue`
    2. 当你修改数组的长度时，例如： `vm.items.length = newLength`

    为了避免第一种情况，以下两种方式将达到像 `vm.items[indexOfItem] = newValue` 的效果， 同时也将触发状态更新：
    ```js
    // Vue.set
    Vue.set(example1.items, indexOfItem, newValue)
    ```
    ```js
    // Array.prototype.splice`
    example1.items.splice(indexOfItem, 1, newValue)
    ```
    避免第二种情况，使用 splice：
    ```js
    example1.items.splice(newLength)
    ```