# webpack

### webpack 命令
```
$ webpack some.js some.bundle.js --module-bind 'css-loader!css-loader' --watch --progress --display-modules --display-reasons
```
- `--watch` 文件改变时，自动打包
- `--module-bind` 针对特定的文件，使用指定的`loader`
- `--display-modules` 展示所有的模块
- `--progress` 展示打包进度
- `--display-reason` 打包每个模块的原因

## webpack configuration

单独运行 `$ webpakc` 命令时，`webpack` 会在当前目录下自动寻找 `webpack.config.js` 文件作为其配置文件；也可以通过指定参数 `--config` 指定配置文件:

### webpack 配置文件
```js
module.exports = {
    entry: {
        page1: "./page1",
        page2: ["./entry1", "./entry2"]
    },
    output: {
        // Make sure to use [name] or [id] in output.filename
        //  when using multiple entry points
        path: "./dist", // 打包之后的文件路径
        filename: "js/[name].bundle.[hash].js", // 打包之后的文件名
        chunkFilename: "[id].bundle.[hash].js",
        publicPath: 'http://lilydedbb.net.cn/' // 指定打包之后，html文件引用时的公共路径 (需要 html-webpack-plugin 插件配合)
    }
};
```
- `entry` 为入口文件，可以有多个 `chunk`，如上面的`page1`、`page2`，每个 `chunk` 可以有多个文件，如上面的`page2: ["./entry1", "./entry2"]`
- `ouput` 为打包之后的输出，`path` 为输出文件的路径，`filename` 为打包之后的文件名；为使不同 `chunk` 的入口文件打包之后的文件不被覆盖，需要使打包之后的文件名唯一，可以使用 `[id]`、`[name]`、`[hash]`、`[chunkhash]` 四个变量：
    - `[name]` 为不同 `chunk` 的入口文件的`chunk`名，如上述的`page1`、`page2`
    - `[hash]` 为打包过程的hash值，每次打包会有不同的hash值
    - `[chunkhash]` 为打包不同`chunk`的hash值，不同的`chunk`其hash值不同，且只有在`chunk`内的文件变更时，该`chunk`的`chunkhash`才会发生变化
- `publicPath` 指定打包之后，html文件引用时的公共路径 (**需要 `html-webpack-plugin` 插件配合**)

    如没有指定 `publicPath` 时：
    ```html
    <script type="text/javascript" src="js/page2.bundle.dcf395eb96d2b948201f.js"></script><script type="text/javascript" src="js/page1.bundle.dcf395eb96d2b948201f.js"></script></head>
    ```
    指定之后：
    ```html
    <script type="text/javascript" src="http://lilydedbb.net.cn/js/page2.bundle.f68426159cda025864d9.js"></script><script type="text/javascript" src="http://lilydedbb.net.cn/js/page1.bundle.f68426159cda025864d9.js"></script></head>
    ```

### html-webpack-plugin 插件
打包过程中如果使用`[hash]`、`[chunkhash]`值，每次打包或者文件变更之后，输出的文件名都会不同，因此要使用`webpack`的`html-webpack-plugin`插件，动态改变html文件中引用的输出文件名
```
$ npm install html-webpack-plugin --save-dev
```

在配置文件中引用`html-webpack-plugin`插件：
```js
// webpack.config.js
var htmlWebpackPlugin = require('html-webpack-plugin')

module.exports = {
    // ...
    plugins: [
        new htmlWebpackPlugin({
            filename: "index.html", // 输出文件名
            template: "index.html", // 模版文件
            inject: "head", // 输出的html文件中，<script> 标签插入在哪儿，如果值为false，则不插入
            title: "webpack demo", // 自定义属性，可以在模版文件中通过 htmlWebpackPlugin.options.title 获得
            date: new Date(), // 自定义属性，可以在模版文件中通过 htmlWebpackPlugin.options.date 获得
            minify: { // 压缩输出html文件
                removeComments: true, // 去除注释
                collapseWhitespace: true // 去除空格
            }
        })
    ]
}
```
`html-webpack-plugin`插件：
- `template` 指定模版文件，即依据哪个文件生成相应的打包之后的html文件
- `filename` 指定生成的html文件名，同样可以使用`[id]`、`[name]`、`[hash]`、`[chunkhash]`变量
- `inject` 指定生成的html文件中`<script>`标签插入在哪儿，默认在`<body>`中
- `自定义属性` 可以在模版文件中使用 `ejs` 模版引擎的语法，从`htmlWebpackPlugin.options`进行读取，如模版文件如下：
    ```html
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <title><%= htmlWebpackPlugin.options.title %></title>
      </head>
      <body>
        <%= htmlWebpackPlugin.options.date %>

      </body>
    </html>
    ```
    则输出html文件：
    ```html
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <title>webpack demo</title>
      <script type="text/javascript" src="js/page2.bundle.dcf395eb96d2b948201f.js"></script><script type="text/javascript" src="js/page1.bundle.dcf395eb96d2b948201f.js"></script></head>
      <body>
        Tue Feb 21 2017 10:57:11 GMT+0800 (CST)

      </body>
    </html>
    ```
- `minify` 对生成的html文件进行压缩：
    ```html
    <!DOCTYPE html><html><head><meta charset="utf-8"><title>webpack demo</title><script type="text/javascript" src="js/page2.bundle.dcf395eb96d2b948201f.js"></script><script type="text/javascript" src="js/page1.bundle.dcf395eb96d2b948201f.js"></script></head><body>Tue Feb 21 2017 10:56:42 GMT+0800 (CST)</body></html>
    ```

### 多页面应用
目录结构如下的多页面应用：
```
├── package.json
├── src
│   └── js
│       ├── a.js
│       ├── app.js
│       ├── b.js
│       └── c.js
├── a.html
├── b.html
├── c.html
└── webpack.config.js
```
webpack配置文件：
```js
// webpack.config.js
var htmlWebpackPlugin = require('html-webpack-plugin')

module.exports = {
    entry: {
        app: "./src/js/app",
        a: "./src/js/a",
        b: "./src/js/b",
        c: "./src/js/c"
    },
    output: {
        path: "./dist",
        filename: "js/[name].bundle.[hash].js",
        publicPath: "http://lilydedbb.net.cn/"
    },
    plugins: [
        new htmlWebpackPlugin({
            template: "a.html",
            filename: "a.html",
            title: "page a",
            chunks: ["app", "a"]
        }),
        new htmlWebpackPlugin({
            template: "b.html",
            filename: "b.html",
            title: "page b",
            chunks: ["app", "b"]
        }),
        new htmlWebpackPlugin({
            template: "c.html",
            filename: "c.html",
            title: "page c",
            chunks: ["app", "c"]
        })
    ]
}
```
- 多个页面，用多个`htmlWebpackPlugin`插件处理就好，在`template`和`filename`中分别指定对应的模版文件和输出文件即可
- `htmlWebpackPlugin`的`chunks`属性为一个数组，为该页面要引入哪些`chunk`

打包之后目录结构如下：
```
dist/
├── a.html
├── b.html
├── c.html
└── js
    ├── a.bundle.b032c3aee9ca6673400a.js
    ├── app.bundle.b032c3aee9ca6673400a.js
    ├── b.bundle.b032c3aee9ca6673400a.js
    └── c.bundle.b032c3aee9ca6673400a.js
```

### Loader

#### 使用 `babel-loader` 转换 `ES6` 代码

安装`babel-loader`:
```
$ npm install --save-dev babel-loader babel-core
```

安装 `presets`:
```
$ npm install --save-dev babel-preset-latest
```

```js
// webpack.config.js
var path = require('path')

module.exports = {
    // ...
    module: {
        loaders: [
            {
                test: /\.js$/,
                loader: 'babel-loader',
                exclude: [ path.resolve(__dirname, 'node_modules') ],
                include: [ path.resolve(__dirname, 'src') ],
                query: {
                    presets: ['latest']
                }
            },
            //...
        ]
    },
    // ...
}
```

#### 使用 `css-loader` & `style-loader` 处理`css`文件

```
$ npm install --save-dev css-loader style-loader
```
```js
// webpack.config.js
module.exports = {
    // ...
    module: {
        loaders: [
            {
                test: /\.css$/,
                loader: 'style-loader!css-loader'
            },
            // ...
        ]
    },
    // ...
}
```


#### 使用`postcss-loader`自动增加浏览器前缀
```
$ npm install --save-dev postcss-loader
```
```js
// webpack.config.js
module.exports = {
    // ...
    module: {
        loaders: [
            {
                test: /\.css$/,
                loader: 'style-loader!css-loader?importLoaders=1!postcss-loader'// 最先经过 postcss-loader 的处理
                // importLoaders 参数是为了让css文件中 @import 引入的其他css文件也经过 postcss-loader 的处理
            },
            // ...
        ]
    },
    postcss: () => {
        return [
            require('autoprefixer')() // 使用 postcss 的 autoprefixer 插件自动增加浏览器前缀
        ]
    },
    // ...
}
```

#### 处理`sass` `less` 文件

处理 `less`:
```
$ npm install less less-loader --save-dev
```
```js
// webpack.config.js
module.exports = {
    // ...
    module: {
        loaders: [
            {
                test: /\.less$/,
                loader: 'style-loader!css-loader!postcss-loader!less-loader'
            },
            // ...
        ]
    },
    // ...
}
```

处理 `sass`:
```
$ npm install node-sass sass-loader --save-dev
```
```js
// webpack.config.js
module.exports = {
    // ...
    module: {
        loaders: [
            {
                test: /\.scss$/,
                loader: 'style-loader!css-loader!postcss-loader!sass-loader'
            },
            // ...
        ]
    },
    // ...
}
```

#### 处理模版文件

处理 `html` 模版：
```
$ npm install html-loader --save-dev
```
```js
// webpack.config.js
module.exports = {
    // ...
    module: {
        loaders: [
            {
                test: /\.html$/,
                loader: 'html-loader'
            },
            // ...
        ]
    },
    // ...
}
```
假设根html文件`index.html`:
```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title></title>
  </head>
  <body>
    <div id="app"></div>
  </body>
</html>
```
模版`layer.html`文件：
```html
<div class="layer">
  <div>this is a layer.</div>
</div>
```
`layer.js`:
```js
import tpl from './layer.html'
import './layer.scss'
function layer () {
  return {
    name: 'layer',
    tpl: tpl
  }
}

export default layer;
```
根`js`文件`app.js`：
```app.js
import Layer from './components/layer/layer.js'
import './css/common.css'

const App = function () {
  var app = document.getElementById('app')
  var layer = new Layer()
  app.innerHTML = layer.tpl
}

new App()
```

#### 处理图片

```
$ npm install file-loader --save-dev
```
```js
// webpack.config.js
module.exports = {
    // ...
    module: {
        loaders: [
            {
                test: /\.(png|jpg|gif|svg)$/i,
                loader: 'file-loader',
                query: {
                    name: 'assets/[name]-[hash:5].[ext]'
                }
            },
            // ...
        ]
    },
    // ...
}
```

使用 `url-loader`:
```
$ npm install url-loader --save-dev
```
```js
// webpack.config.js
module.exports = {
    // ...
    module: {
        loaders: [
            {
                test: /\.(png|jpg|gif|svg)$/i,
                loader: 'url-loader',
                query: {
                    limit: 20000, // 小于20KB的图片会被打包为 dataURL 格式
                    name: 'assets/[name]-[hash:5].[ext]'
                }
            },
            // ...
        ]
    },
    // ...
}
```