## webpack-dev-server

```
$ npm install webpack-dev-server -g
```

```js
{
  // ...
  "scripts": {
    "build": "webpack",
    "dev": "webpack-dev-server --content-base dist/ --inline --hot"
  },
  // ...
}
```

`webpack-dev-server`默认会以当前目录为基本目录，除非指定它，所以这里制定打包之后的路径`dist/`

**`webpack-dev-server`生成的包并没有放在你的真实目录中，而是放在了内存中**

```js
// webpack.config.js
var path = require('path')
var webpack = require('webpack')
var htmlWebpackPlugin = require('html-webpack-plugin')

module.exports = {
    entry: {
        app: [
            'webpack-dev-server/client?http://localhost:8080/',
            'webpack/hot/only-dev-server',
            './js/index.js'
        ]
    },
    output: {
        filename: 'js/[name].bundle.js',
        publicPath: '/dist',
        path: path.resolve(__dirname, 'dist')
    },
    plugins: [
        new webpack.HotModuleReplacementPlugin(),
        new webpack.NoEmitOnErrorsPlugin()
    ]
}
```