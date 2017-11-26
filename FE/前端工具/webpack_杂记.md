# webpack 杂记

### require-ensure

```js
require.ensure(dependencies: String[], callback: function([require]), [chunkName: String])
```

`require.ensure` 在需要的时候才下载依赖的模块，当参数指定的模块都下载下来了（下载下来的模块还没执行），便执行参数指定的回调函数。`require.ensure`会创建一个`chunk`，且可以指定该`chunk`的名称，如果这个`chunk`名已经存在了，则将本次依赖的模块合并到已经存在的`chunk`中，最后这个`chunk`在`webpack`构建的时候会单独生成一个文件

- `dependencies`: 依赖的模块数组
- `callback`: 回调函数，该函数调用时会传一个require参数
- `chunkName`: 模块名，用于构建时生成文件时命名使用

**注意：`require.ensure` 的模块只会被下载下来，不会被执行，只有在回调函数使用`require`(模块名)后，这个模块才会被执行**