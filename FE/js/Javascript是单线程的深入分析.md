# Javascript是单线程的深入分析

原文链接：[Javascript是单线程的深入分析](http://www.cnblogs.com/Mainz/p/3552717.html?utm_source=caibaojian.com)

## 引

首先看下面的代码：
```js
function foo() {
    console.log( 'first' );
    setTimeout( ( function(){ console.log( 'second' ); } ), 5);

}

for (var i = 0; i < 1000000; i++) {
    foo();
}
```
**执行结果会首先全部输出first，然后全部输出second**

## Javascript是单线程的

因为**JS运行在浏览器中，是单线程的，每个window一个JS线程**，既然是单线程的，在某个特定的时刻只有特定的代码能够被执行，并阻塞其它的代码。而浏览器是**事件驱动（`Event driven`）**的，浏览器中很多行为是**异步（`Asynchronized`）**的，会创建事件并放入执行队列中。javascript引擎是单线程处理它的任务队列，你可以理解成就是普通函数和回调函数构成的队列。++**当异步事件发生时，将他们放入执行队列，等待当前代码执行完成**++

## 异步事件驱动

浏览器是事件驱动的（`Event driven`），浏览器中很多行为是异步（`Asynchronized`）的。**当一个异步事件发生的时候，它就进入事件队列**。浏览器有一个内部大消息循环，`Event Loop`（`事件循环`），会轮询大的事件队列并处理事件。例如，浏览器当前正在忙于处理onclick事件，这时另外一个事件发生了（如：window.onSize），这个异步事件就被放入事件队列等待处理，只有前面的处理完毕了，空闲了才会执行这个事件。setTimeout也是一样，当调用的时候，js引擎会启动定时器timer，大约xxms以后执行xxx，当定时器时间到，就把该事件放到主事件队列等待处理（**浏览器不忙的时候才会真正执行**）。

## 浏览器不是单线程的

**虽然JS运行在浏览器中，是单线程的，每个window一个JS线程，但浏览器不是单线程的**

## AJAX是真的异步

**AJAX请求是由浏览器新开一个线程请求**。当请求的状态变更时，如果先前已设置回调，这异步线程就产生状态变更事件放到 JavaScript引擎的事件处理队列中等待处理。当浏览器空闲的时候出队列任务被处理，JavaScript引擎始终是单线程运行回调函数。javascript引擎确实是单线程处理它的任务队列，能理解成就是普通函数和回调函数构成的队列。

总结一下，**Ajax请求确实是异步的，这请求是由浏览器新开一个线程请求，事件回调的时候是放入Event loop单线程事件队列等候处理**

## setTimeout(func, 0)

**javascript是JS运行在浏览器中，是单线程的，每个window一个JS线程**

`setTimeout(func, 0)`那就是告诉js引擎，在0ms以后把func放到主事件队列中，等待当前的代码执行完毕再执行，注意：**++重点是改变了代码流程，把func的执行放到了等待当前的代码执行完毕再执行++**

它的用处有三个：

* 让浏览器渲染当前的变化（很多浏览器UI render和js执行是放在一个线程中，线程阻塞会导致界面无法更新渲染）
* 重新评估”script is running too long”警告
* 改变执行顺序

例如：下面的例子，点击按钮就会显示"calculating...."，如果删除setTimeout就不会。因为reDraw事件被进入事件队列到长时间操作的最后才能被执行，所以无法刷新。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<button id='do'> Do long calc!</button>
<div id='status'></div>
<div id='result'></div>
<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
<script>
    $('#do').on('click', function(){

        $('#status').text('calculating....'); //此处会触发redraw事件的fired，但会放到队列里执行，直到long()执行完。

        // without set timeout, user will never see "calculating...."
        // long();//执行长时间任务，阻塞

        // with set timeout, works as expected
        setTimeout(long, 0);//用定时器，执行长时间任务，放入执行队列，但在redraw之后了，根据先进先出原则

    })

    function long(){
        var result = 0
        for (var i = 0; i<1000; i++){
            for (var j = 0; j<1000; j++){
                for (var k = 0; k<1000; k++){
                    result = result + i+j+k
                }
            }
        }
        $('#status').text('calclation done') // has to be in here for this example. or else it will ALWAYS run instantly. This is the same as passing it a callback
    }
</script>

</body>
</html>
```

## 非阻塞js的实现（non-blocking javascript）

**js在浏览器中需要被下载、解释并执行这三步。在html body标签中的script都是阻塞的。也就是说，顺序下载、解释、执行**。尽管Chrome可以实现多线程并行下载外部资源，例如：script file、image、frame等（css比较复杂，在IE中不阻塞下载，但Firefox阻塞下载）。但是，由于js是单线程的，所以**尽管浏览器可以并发加快js的下载，但必须依次执行**。所以chrome中image图片资源是可以并发下载的，但外部js文件并发下载没有多大意义

实现非阻塞js（`non-blocking javascript`）有两个方法：

1. HTML5的defer和async关键字：
    * defer
    ```js
    <script type="text/javascript" defer src="foo.js"></script>
    ```
    * async
    ```js
    <script type="text/javascript" async src="foo.js"></script>
    ```

2. 动态加载js
```js
setTimeout(function(){
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.src = "foo.js";
    var head = true; //加在头还是尾
    if(head)
      document.getElementsByTagName("head")[0].appendChild(script);
    else
      document.body.appendChild(script);
}, 0);

//另外一个独立的动态加载js的函数
function loadJs(jsurl, head, callback){
    var script=document.createElement('script');
    script.setAttribute("type","text/javascript");

    if(callback){
        if (script.readyState){  //IE
            script.onreadystatechange = function(){
                if (script.readyState == "loaded" ||
                        script.readyState == "complete"){
                    script.onreadystatechange = null;
                    callback();
                }
            };
        } else {  //Others
            script.onload = function(){
                callback();
            };
        }
    }
    script.setAttribute("src", jsurl);

    if(head)
     document.getElementsByTagName('head')[0].appendChild(script);
    else
      document.body.appendChild(script);

}
```