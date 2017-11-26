# 防抖动（Debouncing）和节流阀（Throttling）

有一些浏览器事件可以在很短的时间内快速启动多次，例如 `resize`, `scroll`, `touchmove`, `mousemove` 事件等。例如，如果将事件侦听器绑定到窗口滚动事件上，并且用户继续非常快速地向下滚动页面，你的事件可能会在3秒的范围内被触发数千次。这可能会导致一些严重的性能问题

**函数防抖动 (`Debouncing`) 是解决这个问题的一种方式，通过限制需要经过的时间，直到再次调用函数**

实现函数防抖的方法是：把多个函数放在一个函数里调用，隔一定时间执行一次

Debouncing Simple Example:

```js
/**
 *
 * @param fn {Function}   实际要执行的函数
 * @param delay {Number}  延迟时间，单位是毫秒（ms）
 *
 * @return {Function}     返回一个“防反跳”了的函数
 */
function debounce (fn, delay) {
    // 定时器
    var timer = null
    return function () {
        // 保存函数调用时的上下文和参数，传递给 fn
        var cxt = this
        var args = arguments
        // 每次这个返回的函数被调用，就清除定时器，以保证不执行 fn
        clearTimeout(timer)
        // 当返回的函数被最后一次调用后（也就是用户停止了某个连续的操作），
        // 再过 delay 毫秒就执行 fn
        timer = setTimeout(function () {
            fn.apply(cxt, args)
        }, delay)
    }
}
```

`underscore.js` 中的`debounce`源码：

```js
_.debounce = function(func, wait, immediate) {
    var timeout, result;

    var later = function(context, args) {
        timeout = null;
        if (args) result = func.apply(context, args);
    };

    var debounced = restArgs(function(args) {
        if (timeout) clearTimeout(timeout);
        if (immediate) {
            var callNow = !timeout;
            timeout = setTimeout(later, wait);
            if (callNow) result = func.apply(this, args);
        } else {
            timeout = _.delay(later, wait, this, args);
        }

        return result;
    });

    debounced.cancel = function() {
        clearTimeout(timeout);
        timeout = null;
    };

    return debounced;
};
```

`underscore.js` 中的`debounce`还接受第三个参数`immediate`，这个参数是用来配置回调函数是在一个时间区间的最开始执行（`immediate`为`true`），还是最后执行（`immediate`为`false`），如果`immediate`为`true`，意味着是一个同步的回调，可以传递返回值。

关键的地方是，单独拿出了一个later函数通过控制timer来觉得连续的时间除一开始后，是不是要执行回调

关于防抖动（Debouncing）和节流阀（Throttling）的区别，参考文章：[The Difference Between Throttling and Debouncing](https://css-tricks.com/the-difference-between-throttling-and-debouncing/)

### Debouncing

> **Debouncing enforces that a function not be called again until a certain amount of time has passed without it being called**. As in "execute this function only if 100 milliseconds have passed without it being called

### Throttling

> **Throttling enforces a maximum number of times a function can be called over time**. As in "execute this function at most once every 100 milliseconds.


Throttling Simple Example:

```js
/**
 *
 * @param fn {Function}   实际要执行的函数
 * @param delay {Number}  执行间隔，单位是毫秒（ms）
 *
 * @return {Function}     返回一个“节流”函数
 */
function throttle (fn, threshold) {
    var last // 记录上次执行的时间
    var timer // 定时器
    // 默认间隔为 250ms
    threshold || (threshold = 250)
    // 返回的函数，每过 threshhold 毫秒就执行一次 fn 函数
    return function () {
        // 保存函数调用时的上下文和参数，传递给 fn
        var cxt = this
        var args = arguments
        var now = +new Date()
        // 如果距离上次执行 fn 函数的时间小于 threshhold，那么就放弃
        // 执行 fn，并重新计时
        if (last && now < last + threshold) {
            clearTimeout(timer)
            // 保证在当前时间区间结束后，再执行一次 fn
            timer = setTimeout(function () {
                last = now
                fn.apply(cxt, args)
            }, threshold)
        } else { // 在时间区间的最开始和到达指定间隔的时候执行一次 fn
            last = now
            fn.apply(cxt, args)
        }
    }
}
```

`underscore.js` 中的`throttle`源码：

```js
_.throttle = function(func, wait, options) {
    var timeout, context, args, result;
    var previous = 0;
    if (!options) options = {};

    var later = function() {
        previous = options.leading === false ? 0 : _.now();
        timeout = null;
        result = func.apply(context, args);
        if (!timeout) context = args = null;
    };

    var throttled = function() {
        var now = _.now();
        if (!previous && options.leading === false) previous = now;
        var remaining = wait - (now - previous);
        context = this;
        args = arguments;
        if (remaining <= 0 || remaining > wait) {
            if (timeout) {
                clearTimeout(timeout);
                timeout = null;
            }
            previous = now;
            result = func.apply(context, args);
            if (!timeout) context = args = null;
        } else if (!timeout && options.trailing !== false) {
            timeout = setTimeout(later, remaining);
        }
        return result;
    };

    throttled.cancel = function() {
        clearTimeout(timeout);
        previous = 0;
        timeout = context = args = null;
    };

    return throttled;
};
```

`underscore.js` 的`throttle`中的`previous`相当于自己实现代码中的`last`。还接受`leading`和`trailing`来控制真正回调触发的时机，这和`lodash`的`_.debounce` 差不太多