# Electron + React + Node.js + ES6 开发桌面软件

原文：[Electron + React + Node.js + ES6 开发桌面软件](http://www.jianshu.com/p/578aacbe7980)


## 创建项目 & 添加依赖 & 配置

```
$ npm init
```
```
$ npm install --save-dev electron-prebuilt electron-reload electron-packager

$ npm install --save-dev babel babelify babel-preset-es2015 babel-preset-react babel-plugin-transform-es2015-spread

$ npm install --save-dev browserify watchify

$ npm install --save react react-dom react-tap-event-plugin

$ npm install --save material-ui
```

### `babel` 配置

创建`.babelrc` 文件：
```json
{
    "presets": [
        "es2015",
        "react"
    ],

    "plugins": [
        "transform-object-rest-spread"
    ]
}
```

### `watchify` & `electron-packager` & `electron` 配置

在 `scripts` 下面配置了三个命令：`start`、`watch`、`package`，分别用于启动 App、检测并转换代码、打包 App

```json
"scripts": {
    "start": "electron .",
    "watch": "watchify app/appEntry.js -t babelify -o public/js/bundle.js --debug --verbose",
    "package": "electron-packager ./ DemoApps --overwrite --app-version=1.0.0 --platform=win32 --arch=all --out=../DemoApps --version=1.2.1 --icon=./public/img/app-icon.icns"
}
```

配置之后`package.json`如下：
```json
{
  "name": "electron-app",
  "version": "1.0.0",
  "description": "A minimal Electron application",
  "main": "main.js",
  "scripts": {
    "start": "electron .",
    "watch": "watchify app/appEntry.js -t babelify -o public/js/bundle.js --debug --verbose",
    "package": "electron-packager ./ DemoApps --overwrite --app-version=1.0.0 --platform=win32 --arch=all --out=../DemoApps --version=1.2.1 --icon=./public/img/app-icon.icns"
  },
  "author": "lilydedbb",
  "license": "ISC",
  "devDependencies": {
    "babel": "^6.5.2",
    "babel-plugin-transform-es2015-spread": "^6.22.0",
    "babel-preset-es2015": "^6.22.0",
    "babel-preset-react": "^6.22.0",
    "babelify": "^7.3.0",
    "browserify": "^14.0.0",
    "electron-packager": "^8.5.1",
    "electron-prebuilt": "^1.4.13",
    "electron-reload": "^1.1.0",
    "watchify": "^3.9.0"
  },
  "dependencies": {
    "material-ui": "^0.16.7",
    "react": "^15.4.2",
    "react-dom": "^15.4.2",
    "react-tap-event-plugin": "^2.0.1"
  }
}
```


## Electron 开发

> Electron 提供两个进程来完成这个任务：一个主进程，负责创建 Native 窗口，与操作系统进行 Native 的交互；一个渲染进程，负责渲染 HTML 页面，执行 js 代码。两个进程之间的交互通过 Electron 提供的 IPC API 来完成

在 `package.json` 文件中，指定了 `main` 为 `main.js`，`Electron` 启动后会首先在主进程加载执行这个 `js` 文件——需要在这个进程里面创建窗口，调用方法以加载页面（index.html）

### `main.js`
```js
/**
 * Created by dbb on 2017/2/9.
 */
'use strict'
const electron = require('electron')
const {app, BrowserWindow, Menu, ipcMain, ipcRenderer} = electron

let isDevelopment = true

if (isDevelopment) {
    require('electron-reload')(__dirname, {
        ignored: /node_modules|[\/\\]\./
    })
}

var mainWnd = null

function createMainWnd() {
    mainWnd = new BrowserWindow({
        width: 800,
        height: 600,
        icon: 'public/img/app-icon.png'
    })

    if (isDevelopment) {
        mainWnd.webContents.openDevTools()
    }

    mainWnd.loadURL(`file://${__dirname}/index.html`)

    mainWnd.on('closed', () => {
        mainWnd = null
    })
}

app.on('ready', createMainWnd)

app.on('window-all-closed', () => {
    app.quit()
})
```

在 app `ready` 事件中，创建了主窗口，并通过 `BrowserWindow` 的 `loadURL` 方法加载了本地目录下的 `index.html` 页面。在 `app` 的 `window-all-closed` 事件中，调用 `app.quit` 方法退出整个 `App`

另外通过引入 `electron-reload` 模块，让本地文件更新后，自动重新加载页面：
```js
require('electron-reload')(__dirname, {ignored: /node_modules|[\/\\]\./})
```

### `index.html`
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Electron Apps</title>

    <link rel="stylesheet" type="text/css" href="public/css/main.css">
</head>
<body>
    <div id="content">
    </div>

    <script src="public/js/bundle.js"></script>
    </body>
</html>
```
引入了 `public/js/bundle.js` 这个 `Javascript` 文件，这个文件是通过 `babelify` 转换生成的

### `app/appEntry.js`

`public/js/bundle.js` 是通过 `app/appEntry.js` 生成而来，所以，`appEntry.js` 文件主要负责 HTML 页面渲染——通过 `React` 来实现它

```js
/**
 * Created by dbb on 2017/2/9.
 */
'use strict'

import React from 'react'
import ReactDom from 'react-dom'
import injectTapEventPlugin from 'react-tap-event-plugin'

const events = window.require('events')
const path = window.require('path')
const fs = window.require('fs')

const electron = window.require('electron')
const {ipcRenderer, shell} = electron
const {dialog} = electron.remote

import getMuiTheme from 'material-ui/styles/getMuiTheme'
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider'
import TextField from 'material-ui/TextField'
import RaisedButton from 'material-ui/RaisedButton'

let muiTheme = getMuiTheme({
    fontFamily: 'Microsoft YaHei'
})

class MainWindow extends React.Component {

    constructor (props) {
        super(props)
        injectTapEventPlugin()

        this.state = {
            userName: null,
            password: null
        }
    }

    render () {
        <MuiThemeProvider muiTheme={muiTheme}>
            <div style={styles.root}>
                <img style={styles.icon} src='public/img/app-icon.png'/>
                <TextField
                    hintText='请输入用户名'
                    value={this.state.userName}
                    onChange={(event) => {this.setState({userName: event.target.value})}}/>
                <TextField
                    hintText='请输入密码'
                    type='password'
                    value={this.state.password}
                    onChange={(event) => {this.setState({password: event.target.value})}}/>
                <div style={styles.buttons_container}>
                    <RaisedButton
                        label="登录" primary={true}
                        onClick={this._handleLogin.bind(this)}/>
                    <RaisedButton
                        label="注册" primary={false} style={{marginLeft: 60}}
                    onClick={this._handleRegistry.bind(this)}/>
                </div>
            </div>
        </MuiThemeProvider>
    }

    handleLogin () {
        let options = {
            type: 'info',
            buttons: ['确定'],
            title: '登陆',
            message: this.state.userName,
            defaultId: 0,
            cancelId: 0
        }
        dialog.showMessageBox(options, (response) => {
            if (response == 0) {
                console.log('OK pressed!')
            }
        })
    }
}

const styles = {
    root: {
        position: 'absolute',
        left: 0,
        top: 0,
        right: 0,
        bottom: 0,
        display: 'flex',
        flex: 1,
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center'
    },
    icon: {
        width: 100,
        height: 100,
        marginBottom: 40
    },
    buttons_container: {
        paddingTop: 30,
        width: '100%',
        display: 'flex',
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center'
    }
}

let mainWndComponent = ReactDom.render(
    <MainWindow/>,
    document.getElementById('content')
)
```

### 运行 & 打包

首先启动 `Watchify`，主要是让其监控本地文件修改，实时转换生成 `public/js/bundle.js` 文件：
```
$ npm run watch
```

接下来调用 `start` 命令就可以启动 App 了：
```
$ npm run start
```

打包：
```
$ npm run package
```