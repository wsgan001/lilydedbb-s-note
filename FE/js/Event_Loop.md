# Event loops

参考视频：[Philip Roberts: Help, I’m stuck in an event-loop.](https://vimeo.com/96425312)

参考文章：[JavaScript 运行机制详解：再谈Event Loop](http://www.ruanyifeng.com/blog/2014/10/event-loop.html)


## synchronous & asynchronous

所有任务可以分成两种，一种是同步任务（synchronous），另一种是异步任务（asynchronous）

- `同步任务`：在主线程上排队执行的任务，只有前一个任务执行完毕，才能执行后一个任务
- `异步任务`：不进入主线程、而进入"任务队列"（task queue）的任务，只有"任务队列"通知主线程，某个异步任务可以执行了，该任务才会进入主线程执行

异步执行的运行机制如下:（同步执行也是如此，因为它可以被视为没有异步任务的异步执行）

1. 所有同步任务都在主线程上执行，形成一个执行栈（execution context stack 或 call stack）
2. 主线程之外，还存在一个"任务队列"（task queue）。只要异步任务有了运行结果，就在"任务队列"之中放置一个事件
3. 一旦"执行栈"中的所有同步任务执行完毕，系统就会读取"任务队列"，看看里面有哪些事件。那些对应的异步任务，于是结束等待状态，进入执行栈，开始执行
4. 主线程不断重复上面的第三步


## Event loops

**只要主线程空了，就会去读取"任务队列"，这就是JavaScript的运行机制。这个过程会不断重复**

![image](../../images/event_loop.png)

上图中，主线程运行的时候，产生堆（heap）和栈（stack），栈中的代码调用各种外部API，它们在"任务队列"中加入各种事件（click，load，done）。只要栈中的代码执行完毕，主线程就会去读取"任务队列"，依次执行那些事件所对应的回调函数


## timer

`setTimeout()` 和 `setInterval()` 这两个函数来完成，它们的内部运行机制完全一样，区别在于前者指定的代码是一次性执行，后者则为反复执行

如果将 `setTimeout()` 的第二个参数设为 `0`，就表示当前代码执行完（执行栈清空）以后，立即执行（0毫秒间隔）指定的回调函数

```js
setTimeout(function(){console.log(1);}, 0);
console.log(2);
```

上面代码的执行结果总是`2`，`1`，因为只有在执行完第二行以后，系统才会去执行"任务队列"中的回调函数

总之，`setTimeout(fn,0)` 的含义是，指定某个任务在主线程最早可得的空闲时间执行，也就是说，尽可能早得执行。它在"任务队列"的尾部添加一个事件，因此要等到同步任务和"任务队列"现有的事件都处理完，才会得到执行

**需要注意的是，`setTimeout()` 只是将事件插入了"任务队列"，必须等到当前代码（执行栈）执行完，主线程才会去执行它指定的回调函数。要是当前代码耗时很长，有可能要等很久，所以并没有办法保证，回调函数一定会在 `setTimeout()` 指定的时间执行**


## Event Loop in Node.js

![image](../../images/eventloop_nodejs.png)

Node.js的运行机制如下:
1. `V8`引擎解析 JavaScript 脚本
2. 解析后的代码，调用 `Node API`
3. `libuv` 库负责`Node API` 的执行。它将不同的任务分配给不同的线程，形成一个 `Event Loop` （事件循环），以异步的方式将任务的执行结果返回给 `V8` 引擎
4. `V8` 引擎再将结果返回给用户

除了 `setTimeout` 和 `setInterval` 这两个方法， `Node.js` 还提供了另外两个与"任务队列"有关的方法：`process.nextTick` 和 `setImmediate`

### process.nextTick()

`process.nextTick` 方法可以在当前"执行栈"的尾部——下一次 `Event Loop`（主线程读取"任务队列"）之前——触发回调函数

也就是说，**它指定的任务总是发生在所有异步任务之前**

Example:

```js
process.nextTick(function A() {
  console.log(1);
  process.nextTick(function B(){console.log(2);});
});

setTimeout(function timeout() {
  console.log('TIMEOUT FIRED');
}, 0)
// 1
// 2
// TIMEOUT FIRED
```

上面代码中，**由于 `process.nextTick` 方法指定的回调函数，总是在当前"执行栈"的尾部触发**，所以不仅函数 `A` 比 `setTimeout` 指定的回调函数timeout先执行，而且函数 `B` 也比 `timeout` 先执行。这说明，**如果有多个 `process.nextTick` 语句（不管它们是否嵌套），将全部在当前"执行栈"执行**

## setImmediate

`setImmediate` 方法则是在当前"任务队列"的尾部添加事件，也就是说，它指定的任务总是在下一次 `Event Loop` 时执行，这与 `setTimeout(fn, 0)` 很像

Example:

```js
setImmediate(function A() {
  console.log(1);
  setImmediate(function B(){console.log(2);});
});

setTimeout(function timeout() {
  console.log('TIMEOUT FIRED');
}, 0);
```

上面代码中，`setImmediate` 与 `setTimeout(fn,0)` 各自添加了一个回调函数 `A` 和 `timeout` ，都是在下一次 `Event Loop` 触发

那么，哪个回调函数先执行呢？答案是不确定。运行结果可能是 `1--TIMEOUT FIRED--2` ，也可能是 `TIMEOUT FIRED--1--2`

Node.js文档中称，`setImmediate` 指定的回调函数，总是排在 `setTimeout` 前面。实际上，这种情况只发生在递归调用的时候

```js
setImmediate(function (){
  setImmediate(function A() {
    console.log(1);
    setImmediate(function B(){console.log(2);});
  });

  setTimeout(function timeout() {
    console.log('TIMEOUT FIRED');
  }, 0);
});
// 1
// TIMEOUT FIRED
// 2
```

上面代码中，`setImmediate` 和 `setTimeout` 被封装在一个 `setImmediate` 里面，它的运行结果总是 `1--TIMEOUT FIRED--2` ，这时函数 `A` 一定在 `timeout` 前面触发。**至于`2`排在`TIMEOUT FIRED`的后面（即函数`B`在`timeout`后面触发），是因为`setImmediate`总是将事件注册到下一轮`Event Loop`，所以函数`A`和`timeout`是在同一轮`Loop`执行，而函数`B`在下一轮`Loop`执行**

由此得到了 `process.nextTick` 和 `setImmediate` 的一个重要区别：**多个 `process.nextTick` 语句总是在当前"执行栈"一次执行完，多个 `setImmediate` 可能则需要多次 `loop` 才能执行完**

**因此递归调用 `process.nextTick`，将会没完没了，主线程根本不会去读取"事件队列"！**

```jd
process.nextTick(function foo() {
  process.nextTick(foo);
});
```

事实上，现在要是你写出递归的process.nextTick，Node.js会抛出一个警告，要求你改成setImmediate

另外，**由于 `process.nextTick` 指定的回调函数是在本次"事件循环"触发，而 `setImmediate` 指定的是在下次"事件循环"触发，所以很显然，前者总是比后者发生得早，而且执行效率也高**