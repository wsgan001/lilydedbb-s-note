# ```vue2``` + ```koa1``` 开发笔记

## 准备

安装vue：
```
$ npm install vue
```
使用 ```vue-cli``` 生成项目：
```
# 全局安装 vue-cli
$ npm install --global vue-cli
# 创建一个基于 webpack 模板的新项目
$ vue init webpack Demo_vue_and_koa
# 安装依赖
$ cd Demo_vue_and_koa
$ npm install
$ npm run dev
```
然后使用 ```yarn```(比```npm```更快一些)：
```
$ brew install yarn
```
安装```Vue```的项目依赖并安装```Koa```的项目依赖：
```
$ yarn && yarn add koa koa-router@5.4 koa-logger koa-json koa-bodyparser
```
**==注意：安装koa-router的5.4版，因为7.X版本是支持Koa2的==**

### 项目目录结构

建立```server```文件夹以及子文件夹：
```
├── server // Koa后端，用于提供Api
    ├── config // 配置文件夹
    ├── controllers // controller-控制器
    ├── models // model-模型
    ├── routes // route-路由
    └── schema // schema-数据库表结构
```
创建一个```app.js```文件，作为```Koa```的启动文件。

```
.
├── README.md
├── app.js
├── build
│   ├── build.js
│   ├── check-versions.js
│   ├── dev-client.js
│   ├── dev-server.js
│   ├── utils.js
│   ├── webpack.base.conf.js
│   ├── webpack.dev.conf.js
│   └── webpack.prod.conf.js
├── config
│   ├── dev.env.js
│   ├── index.js
│   ├── prod.env.js
│   └── test.env.js
├── index.html
├── package.json
├── server
│   ├── config
│   ├── controllers
│   ├── models
│   ├── schema
│   └── toutes
├── src
│   ├── App.vue
│   ├── assets
│   │   └── logo.png
│   ├── components
│   │   └── Hello.vue
│   └── main.js
├── static
├── test
│   ├── e2e
│   │   ├── custom-assertions
│   │   │   └── elementCount.js
│   │   ├── nightwatch.conf.js
│   │   ├── runner.js
│   │   └── specs
│   │       └── test.js
│   └── unit
│       ├── index.js
│       ├── karma.conf.js
│       └── specs
│           └── Hello.spec.js
└── yarn.lock
```

编辑```app.js```文件：
```js
const app = require('koa')(),
    router = require('koa-router')(),
    json = require('koa-json'),
    logger = require('koa-logger')

app.use(require('koa-bodyparser')())
app.use(json())
app.use(logger())

app.use(function *(next) {
    let start = new Date()
    yield next
    let ms = new Date - start
    console.log('%s %s - %s', this.method, this.url, ms)
})

app.on('error', function (err, ctx) {
    console.log('server error: ', err)
})

app.listen(8000, () => {
    console.log('koa is listening in 8000')
})

module.exports = app
```
然后在控制台输入 ```$ node app.js```，能看到输出 ```koa is listening in 8000```


## 前端页面构建

采用的 ```Vue2``` 的前端UI框架是 ```element-ui```:
```
# 安装
$ yarn add element-ui
```

CSS预处理用 ```stylus```:
```
# 安装stylus-loader是为了让webpack能够渲染stylus
$ yarn add stylus stylus-loader
```

把 ```element-ui``` 引入项目，编辑 ```src/main.js```:
```js
// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-default/index.css'

Vue.use(ElementUI) // Vue全局使用

/* eslint-disable no-new */
new Vue({
  el: '#app',
  template: '<App/>',
  components: { App }
})
```

实现响应式页面，在 ```index.html``` 中插入一行：
```html
<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
```

启动开发模式，这个模式有 ```webpack``` 的热加载
```
$ npm run dev
```

### 登陆界面

在 ```src/components```目录新建一个 ```Login.vue```文件:
```html
<template>
    <el-row class="content">
        <el-col :xs="24" :sm="{span: 6, offset: 9}">
            <span class="title">
                欢迎登陆
            </span>
            <el-row>
                <el-input v-model="account" placeholder="账号" type="text"></el-input>
                <el-input v-model="password" placeholder="密码" type="password"></el-input>
                <el-button type="primary">登录</el-button>
            </el-row>
        </el-col>
    </el-row>
</template>
<style lang="stylus" scoped>
    .el-row.content
        padding 16px
    .title
        font-size 28px
    .el-input
        margin 12px 0
    .el-button
        width 100%
        margin-top 12px
</style>
<script>
export default {
  data () {
    return {
      account: '',
      password: ''
    }
  }
}
</script>
```

注意：
> * **```template```标签内的直接子元素最多只能挂载一个**
> * **```style```标签内有个```scoped```属性，这个属性能够使这些样式只在这个组件内生效**

把```Login.vue```页面注册到```Vue```之下，改写```app.vue```:
```html
<template>
  <div id="app">
    <img src="./assets/logo.png">
    <Login></Login> <!--使用Login组件-->
  </div>
</template>

<script>
import Login from './components/Login' // 引入Login组件

export default {
  name: 'app',
  components: {
    Login // 注册组件
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
```

### TodoList页面

TodoList页面同理
```html
<template>
    <el-row class="content">
        <el-col :xs="{span: 20, offset: 2}" :sm="{span: 8, offset: 8}">
            <span>
                欢迎：{{name}}！你的待办事项是：
            </span>
            <el-input placeholder="请输入待办事项" v-model="todos" @keyup.enter.native="addTodos"></el-input>
            <el-tabs v-model="activeName">
                <el-tab-pane label="待办事项" name="first">
                    <el-col :xs="24">
                        <template v-if="!Done"> <!--v-if和v-for不能同时在一个元素内使用，因为Vue总会先执行v-for-->
                            <template v-for="(item, index) in list">
                                <div class="todo-list" v-if="item.status == 0">
                                    <span class="item">
                                        {{ index + 1 }}. {{item.content}}
                                    </span>
                                    <span class="pull-right">
                                        <el-button size="small" type="primary" @click="finished(index)">完成</el-button>
                                        <el-button size="small" :plain="true" type="danger" @click="remove(index)">删除</el-button>
                                    </span>
                                </div>
                            </template>
                        </template>
                        <div v-else-if="Done">
                            暂无待办事项
                        </div>
                    </el-col>
                </el-tab-pane>
                <el-tab-pane label="已完成事项" name="second">
                    <template v-if="count > 0">
                        <template v-for="(item, index) in list">
                            <div class="todo-list" v-if="item.status == 1">
                                <span class="item finished">
                                    {{ index + 1 }}. {{item.content}}
                                </span>
                                <span class="pull-right">
                                    <el-button size="small" type="primary" @click="restore(index)">还原</el-button>
                                </span>
                            </div>
                        </template>
                    </template>
                    <div v-else>
                        暂无已完成事项
                    </div>
                </el-tab-pane>
            </el-tabs>
        </el-col>
    </el-row>
</template>
<style lang="stylus" scoped>
    .el-input
        margin 20px auto
    .todo-list
        width 100%
        margin-top 8px
        padding-bottom 8px
        border-bottom 1px solid #eee
        overflow hidden
        text-align left
    .item
        font-size 20px
        &.finished
            text-decoration line-through
            color #ddd
    .pull-right
        float right
</style>
<script>
export default {
  data () {
    return {
      name: 'Molunerfinn',
      todos: '',
      activeName: 'first',
      list: [],
      count: 0
    }
  },
  computed: {
    Done () {
      let count = 0
      let length = this.list.length
      for (let i in this.list) {
        this.list[i].status === 1 ? count += 1 : ''
      }
      this.count = count
      if (count === length || length === 0) {
        return true
      } else {
        return false
      }
    }
  },
  methods: {
    addTodos () {
      if (this.todos === '') {
        return
      }
      let obj = {
        status: false,
        content: this.todos
      }
      this.list.push(obj)
      this.todos = ''
    },
    finished (index) {
      this.$set(this.list[index], 'status', true) // 通过set的方法让数组的变动能够让Vue检测到
      this.$message({
        type: 'success',
        message: '任务完成'
      })
    },
    remove (index) {
      this.list.splice(index, 1)
      this.$message({
        type: 'info',
        message: '任务删除'
      })
    },
    restore (index) {
      this.$set(this.list[index], 'status', false)
      this.$message({
        type: 'info',
        message: '任务还原'
      })
    }
  }
}
</script>
```

**注意**：
> * ```v-if```和```v-for```放在一个元素内同时使用，因为```Vue```总会先执行```v-for```，所以导致```v-if```不会被执行。替代地，可以使用一个额外的```template```元素用来放置```v-if```或者```v-for```从而达到同样的目的。
> * 计算属性对于直接的数据比如```a: 2 -> a: 3```这样的数据变动可以直接检测到。但是如果是本例中的```list```的某一项的```status```这个属性变化了，如果直接使用```list[index].status = true```这样的写法的话，```Vue```将无法检测到数据变动。替代地，可以使用set方法（全局是```Vue.set()```，实例中是```this.$set()```），通过set方法可以让数据的变动变得可以被检测到。从而让计算属性能够捕捉到变化。

### 页面路由

由于不采用服务端渲染，所以页面路由走的是前端路由。安装一下```vue-router```:
```
$ yarn add vue-router
```

然后挂载一下路由，改写```main.js```:
```js
import Vue from 'vue'
import App from './App'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-default/index.css'
import VueRouter from 'vue-router'

Vue.use(ElementUI) // Vue全局使用
Vue.use(VueRouter)

import Login from './components/Login'
import TodoList from './components/todoList'

const router = new VueRouter({
  mode: 'history', // 开启HTML5的history模式，可以让地址栏的url长得跟正常页面跳转的url一样
  base: __dirname,
  routes: [
    {
      path: '/', // 默认首页打开是登录页
      component: Login
    },
    {
      path: '/todoList',
      component: TodoList
    },
    {
      path: '*', // 输入其他不存在的地址自动跳回首页
      redirect: '/'
    }
  ]
})

new Vue({
  router: router,
  render: h => h(App)
}).$mount('#app')
```

把路由视图放到页面上，改写```app.vue```:
```html
<template>
  <div id="app">
    <img src="./assets/logo.png">
    <router-view></router-view> <!-- 原本的Login换成了router-view 这就是路由视图渲染的目标元素-->
  </div>
</template>

<script>
export default {
  name: 'app' // 不需要再引入`Login`\`TodoList`组件了，因为在路由里已经注册了
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
```

然后实现点击登录按钮就跳转到```/todoList```:
```
......
<!-- 给input增加键盘事件，当输入完密码回车也执行loginToDo方法 -->
<el-input v-model="password" placeholder="密码" type="password" @keyup.enter.native="loginTodo"></el-input>
<!-- 增加一个click方法 loginToDo -->
<el-button type="primary" @click="loginTodo">登录</el-button>
......
<script>
export default {
  data () {
    return {
      account: '',
      password: ''
    }
  },
  methods: {
    loginTodo () {
      this.$router.push('/todolist') // 编程式路由，通过push方法，改变路由
    }
  }
}
</script>
```
前端搭建到此结束

## 后端

### 构建数据表

使用 ```mysql```:

* user 表
```
+-----------+----------+------+-----+---------+----------------+
| Field     | Type     | Null | Key | Default | Extra          |
+-----------+----------+------+-----+---------+----------------+
| id        | int(11)  | NO   | PRI | NULL    | auto_increment |
| user_name | char(50) | NO   |     | NULL    |                |
| password  | char(32) | YES  |     | NULL    |                |
+-----------+----------+------+-----+---------+----------------+
```
* list 表
```
+---------+------------+------+-----+---------+----------------+
| Field   | Type       | Null | Key | Default | Extra          |
+---------+------------+------+-----+---------+----------------+
| id      | int(11)    | NO   | PRI | NULL    | auto_increment |
| user_id | int(11)    | NO   |     | NULL    |                |
| content | char(255)  | YES  |     | NULL    |                |
| status  | tinyint(1) | YES  |     | NULL    |                |
+---------+------------+------+-----+---------+----------------+
```

```sql
CREATE DATABASE todolist;

USE todolist;

CREATE TABLE user(
    id INT NOT NULL AUTO_INCREMENT,
    user_name CHAR(50) NOT NULL,
    password CHAR(32),
    PRIMARY KEY (id)
);

CREATE TABLE list(
    id INT NOT NULL AUTO_INCREMENT,
    user_id INT(11) NOT NULL,
    content CHAR(255),
    status TINYINT(1),
    PRIMARY KEY (id)
);
```

### Sequelize

安装依赖：
```
$ yarn global add sequelize-auto && yarn add sequelize mysql
```

进入```server```的目录，执行如下语句
```
$ sequelize-auto -o "./schema" -d todolist -h 127.0.0.1 -u root -p 3306 -x XXXXX -e mysql
```
**(-x 参数后面是数据库密码)**

**如果遇到 ```Error: Please install mysql package manually```错误，则执行：**
```
$ npm install mysql -g
```

然后就会在```schema```文件夹下自动生成两个文件：
```js
// user.js
/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('user', {
    id: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    user_name: {
      type: DataTypes.CHAR(50),
      allowNull: false
    },
    password: {
      type: DataTypes.CHAR(32),
      allowNull: true
    }
  }, {
    tableName: 'user'
  });
};
```
```js
// list.js
/* jshint indent: 2 */

module.exports = function(sequelize, DataTypes) {
  return sequelize.define('list', {
    id: {
      type: DataTypes.INTEGER(11),
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },
    user_id: {
      type: DataTypes.INTEGER(11),
      allowNull: false
    },
    content: {
      type: DataTypes.CHAR(255),
      allowNull: true
    },
    status: {
      type: DataTypes.INTEGER(1),
      allowNull: true
    }
  }, {
    tableName: 'list'
  });
};
```

在```server```目录下的```config```目录下新建一个```db.js```，用于初始化```Sequelize```和数据库的连接:
```js
const Sequelize = require('sequelize')

const Todolist = new Sequelize('mysql://root:password@localhost/todolist', {
    define: {
        timestamps: false // 取消Sequelzie自动给数据表加入时间戳（createdAt以及updatedAt）
    }
})

module.exports = {
    Todolist
}
```

接着到```models```文件夹里将数据库和表结构文件连接起来:
```js
// models/user.js
const db = require('../config/db'),
    userModel = '../schema/user' // 引入user的表结构
const TodolistDB = db.Todolist // 引入数据库

const User = TodolistDB.import(userModel) // 用sequelize的import方法引入表结构，实例化了User

const getUserById = function* (id) {
    const userInfo = yield User.findOne({
        where: {
            id: id
        }
    })

    return userInfo
}

module.exports = {
    getUserById
}
```
接着在```controllers```写一个```user```的```controller```
```js
// controllers/user.js
const user = require('../models/user')

const getUserInfo = function* () {
    const id = this.params.id // 获取url里传过来的参数里的id
    const result = yield user.getUserById(id)
    this.body = result
}

module.exports = {
    auth: (router) => {
        router.get('/user/:id', getUserInfo) // 定义url的参数是id
    }
}
```
在```routes```文件夹下写一个```auth.js```的文件
```js
// routes/auth.js
const user = require('../controllers/user')
const router = require('koa-router')()

user.auth(router) // 用user的auth方法引入router

module.exports = router
```

回到根目录的```app.js```，改写如下：
```js
const app = require('koa')(),
    router = require('koa-router')(),
    json = require('koa-json'),
    logger = require('koa-logger'),
    auth = require('./server/routes/auth')

app.use(require('koa-bodyparser')())
app.use(json())
app.use(logger())

app.use(function *(next) {
    let start = new Date()
    yield next
    let ms = new Date - start
    console.log('%s %s - %s', this.method, this.url, ms)
})

app.on('error', function (err, ctx) {
    console.log('server error: ', err)
})

router.use('/auth', auth.routes()) // 挂载到koa-router上，同时会让所有的auth的请求路径前面加上'/auth'的请求路径
app.use(router.routes()) // 将路由规则挂载到Koa上

app.listen(8000, () => {
    console.log('koa is listening in 8000')
})

module.exports = app
```

### 登录系统的实现

**使用```JSON-WEB-TOKEN```实现```无状态```的请求(而不是基于```session```和```cookie```的存储式的有状态验证)**

安装```Koa```的```JSON-WEB-TOKEN```库
```
$ yarn add koa-jwt
```

需要在```models```里的```user.js```加一个方法，通过用户名查找用户：
```js
// models/user.js
......

const getUserByName = function* (name) {
    const userInfo = yield User.findOne({
        where: {
            user_name: name
        }
    })

    return userInfo
}

module.exports = {
    getUserById,
    getUserByName
}
```
然后写一下```controllers```里的```user.js```：
```js
// controllers/user.js
const user = require('../models/user')
const jwt = require('koa-jwt')

const getUserInfo = function* () {
    const id = this.params.id // 获取url里传过来的参数里的id
    const result = yield user.getUserById(id)
    this.body = result
}

const postUserAuth = function* () {
    const data = this.request.body // post过来的数据存在request.body里
    const userInfo = yield user.getUserByName(data.name)

    if (userInfo != null) { // 如果用户存在
        if (userInfo.password != data.password) { // 如果密码不正确
            this.body = {
                success: false,
                info: '密码错误！'
            }
        } else { // 如果密码正确
            const userTaken = {
                name: userInfo.user_name,
                id: userInfo.id
            }
            const secret = 'vue-koa-demo'
            const token = jwt.sign(userTaken, secret)
            this.body = {
                success: true,
                token: token
            }
        }
    } else { // 如果用户不存在
        this.body = {
            success: false,
            info: '用户不存在！'
        }
    }
}

module.exports = {
    auth: (router) => {
        router.get('/user/:id', getUserInfo) // 定义url的参数是id
        router.post('/user', postUserAuth)
    }
}
```

### 引入Axios

安装```axios```
```
$ yarn add axios
```

然后在```src/main.js```里面引入```axios```：
```js
......
import Axios from 'axios'

Vue.prototype.$http = Axios // 类似于vue-resource的调用方法，之后可以在实例里直接用this.$http.get()等
......
```
修改```Login.vue```：
```js
// Login.vue
......
<script>
export default {
  ......
  methods: {
    loginTodo () {
      let obj = {
        name: this.account,
        password: this.password
      }
      this.$http.post('/auth/user', obj)
        .then((res) => {
          if (res.data.success) {
            sessionStorage.setItem('demo-token', res.data.token)
            this.$message({
              type: 'success',
              message: '登录成功！'
            })
            this.$router.push('/todolist')
          } else {
            this.$message.error(res.data.info)
            sessionStorage.setItem('demo-token', null)
          }
        }, (err) => {
          if (err) {
            this.$message.error('请求错误！')
            sessionStorage.setItem('demo-token', null)
          }
        })
    }
  }
}
</script>
```

### 密码md5加密

安装：
```
$ yarn add md5
```
然后修改```Login.vue```中的```loginTodo```方法：
```js
......
<script>
import md5 from 'md5'

export default {
  ......
  methods: {
    loginTodo () {
      let obj = {
        name: this.account,
        password: md5(this.password) // md5加密
      }
      ......
    }
  }
}
</script>
```

### 解决跨域问题

因为界面跑在```8080```端口，但是```Koa```提供的```API```跑在```8000```端口，所以如果直接通过```/auth/user```这个```url```去```post```是请求不到的。就算写成```localhost:8000/auth/user```也会因为跨域问题导致请求失败。

> 1. 如果是跨域，服务端只要在请求头上加上```CORS```，客户端即可跨域发送请求
> 2. 变成同域，即可解决跨域请求问题

打开根目录下的```config/index.js```，找到```dev```下的```proxyTable```，利用这个```proxyTable```能够将外部的请求通过```webpack```转发给本地，也就能够将跨域请求变成同域请求了

将```proxyTable```改写如下:
```js
......
module.exports = {
  ......
  dev: {
    ......,
    proxyTable: {
      '/auth': {
        target: 'http://localhost:8000',
        changeOrigin: true
      },
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true
      }
    },
    ......
  }
}
```

### 跳转拦截

虽然现在能够成功登录系统了，但是还是存在一个问题：在地址栏手动将地址改为```localhost:8080/todolist```还是能够成功跳转到登录后的界面啊。于是这就需要一个跳转拦截，当没有登录的时候，不管地址栏输入什么地址，最终都重新定向回登录页。

这个时候，从后端传回来的```token```就派上大用处。有```token```就说明身份是经过验证的，否则就是非法的。```vue-router```提供了页面跳转的钩子，可以在```router```跳转前进行验证，如果```token```存在就跳转，如果不存在就返回登录页。

打开```src/main.js```，修改如下:
```js
// src/main.js
...
const router = new VueRouter({...})

router.beforeEach((to, from, next) => {
  const token = sessionStorage.getItem('demo-token')
  if (to.path === '/') { // 如果是跳转到登录页的
    if (token !== 'null' && token !== null) { // 如果有token就转向todolist不返回登录页
      next('/todolist')
    } else {
      next() // 否则跳转回登录页
    }
  } else {
    if (token !== 'null' && token !== null) {
      next() // 如果有token就正常转向
    } else {
      next('/') // 否则跳转回登录页
    }
  }
})

new Vue({...}).$mount('#app')
```

> **注意：一定要确保要调用 ```next()``` 方法，否则钩子就不会被 resolved**。如果纯粹调用```next(path)```这样的方法最终还是会回到```.beforeEach()```这个钩子里面来，如果没有写对条件就有可能出现死循环，栈溢出的情况。

### 解析token

注意到在签发```token```的时候，写过这样几句话：
```
// server/controllers/user.js
...
const userToken = {
  name: userInfo.user_name,
  id: userInfo.id
}
const secret = 'vue-koa-demo'; // 指定密钥，这是之后用来判断token合法性的标志
const token = jwt.sign(userInfo,secret); // 签发token
...
```

将```用户名```和```id```打包进```JWT```的主体部分，同时解密的密钥是```vue-koa-demo```。所以可以通过这个信息，来进行登录后的用户名显示，以及用来区别这个用户是谁，这个用户有哪些```Todolist```

接下来在```Todolist```页面进行```token```解析，从而让用户名显示为登录用户名

```js
<script>
import jwt from 'jsonwebtoken' // 安装koa-jwt的时候会自动下载这个依赖

export default {
  created () {
    const userInfo = this.getUserInfo()
    if (!userInfo !== null) {
      this.id = userInfo.id
      this.name = userInfo.name
    } else {
      this.id = ''
      this.name = ''
    }
  },
  data () {
    return {
      name: '',
      todos: '',
      activeName: 'first',
      list: [],
      count: 0,
      id: '' // 新增用户id属性，用于区别用户
    }
  },
  computed: {...},
  methods: {
    addTodos () {...},
    finished (index) {...},
    remove (index) {...},
    restore (index) {...},
    getUserInfo () { // 获取用户信息
      const token = sessionStorage.getItem('demo-token')
      if (token !== null && token !== 'null') {
        let decode = jwt.verify(token, 'vue-koa-demo') // 解析token
        return decode // decode解析出来实际上就是{name: XXX,id: XXX}
      } else {
        return null
      }
    }
  }
}
</script>
```


## Todolist 增删改查的实现

### Token的发送

用```JSON-WEB-TOKEN```之后，这个系统的验证就完全依靠```token```了。如果```token```正确就下发资源，如果资源不正确，就返回错误信息。

因为用了```koa-jwt```，所以只需要在每条请求头上加上```Authorization```属性，值是```Bearer {token值}```，然后让```Koa```在接收请求之前验证一下```token```即可。但是如果每发一条请求就要手动写一句这个，太累了。于是可以做到全局```Header```设定。

打开```src/main.js```，在路由跳转的钩子里加上这句：
```js
...
router.beforeEach((to, from, next) => {
  const token = sessionStorage.getItem('demo-token')
  if (to.path === '/') { // 如果是跳转到登录页的
    if (token !== 'null' && token !== null) { // 如果有token就转向todolist不返回登录页
      next('/todolist')
    } else {
      next() // 否则跳转回登录页
    }
  } else {
    if (token !== 'null' && token !== null) {
      Vue.prototype.$http.default.headers.common['Authorization'] = 'Bearer ' + token // 全局设定header的token验证，注意Bearer后有个空格
      next() // 如果有token就正常转向
    } else {
      next('/') // 否则跳转回登录页
    }
  }
})
...
```
这样就完成了token的客户端发送设定

### Koa端对Token的验证

接着实现两个简单的```api```，这两个```api```请求的路径就不是```/auth/xxx```而是```/api/xxx```了。还需要实现，访问```/api/*```路径的请求都需要经过```koa-jwt```的验证，而```/auth/*```的请求不需要。

首先去```models```目录下新建一个```todolist.js```的文件：
```js
// server/models/todolist.js
const db = require('../config/db'),
    todoModel = '../schema/list'
const TodolistDB = db.Todolist

const Todolist = TodolistDB.import(todoModel)

// 获取某个用户的全部todolist
const getTodolistById = function* (id) {
    const todolist = yield Todolist.findAll({ // 查找全部的todolist
        where: {
            user_id: id
        },
        attributes: ['id', 'content', 'status'] // 只需返回这三个字段的结果即可
    })

    return todolist
}

// 给某个用户创建一条todolist
const createTodolist = function* (data) {
    yield Todolist.create({
        user_id: data.id,
        content: data.content,
        status: data.status
    })
    return true
}

module.exports = {
    getTodolistById,
    createTodolist
}
```

接着去```controllers```目录下新建一个```todolist.js```的文件：
```js
// server/controllers/todolist
const todolist = require('../models/todolist')

const getTodolist = function* () {
    const id = this.params.id // 获取url里传过来的参数里的id
    const result = yield todolist.getTodolistById(id)
    this.body = result
}

const createTodolist = function* () {
    const data = this.request.body // post请求，数据是在request.body里的
    const result = yield todolist.createTodolist(data)

    this.body = {
        success: true
    }
}

module.exports = (router) => {
    router.get('/todolist/:id', getTodolist),
    router.post('/todolist', createTodolist)
}
```

然后去```routes```文件夹里新建一个```api.js```文件：
```js
// server/routes/api.js
const todolist = require('../controllers/todolist')
const router = require('koa-router')()

todolist(router)

module.exports = router
```

最后，去根目录下的```app.js```，给```koa```加上新的路由规则：
```js
// app.js
'use strict'
const app = require('koa')(),
    router = require('koa-router')(),
    json = require('koa-json'),
    logger = require('koa-logger'),
    auth = require('./server/routes/auth'),
    api = require('./server/routes/api'),
    jwt = require('koa-jwt')
......
app.use(function *(next) {
    let start = new Date()
    yield next
    let ms = new Date - start
    console.log('%s %s - %s', this.method, this.url, ms)
})

// 如果JWT验证失败，返回验证失败的消息
app.use(function* (next) {
    try {
        yield next
    } catch (err) {
        if (this.status = 401) {
            this.body = {
                success: false,
                token: null,
                info: 'Protected resource, use Authorization header to get access'
            }
        } else {
            throw err
        }
    }
})

app.on('error', function (err, ctx) {
    console.log('server error: ', err)
})

router.use('/auth', auth.routes()) // 挂载到koa-router上，同时会让所有的auth的请求路径前面加上'/auth'的请求路径
router.use('/api', jwt({ secret: 'vue-koa-demo' }), api.routes) // 所有走/api/打头的请求都需要经过jwt中间件的验证。secret密钥必须跟当初签发的secret一致

app.use(router.routes()) // 将路由规则挂载到Koa上
......
module.exports = app
```
至此，后端的两个api已经构建完成。

**初始化配置相对复杂一些，涉及到```model```、```controllers```、```routes```和```app.js```。实际上第一次构建完成之后，后续要添加```api```，基本上只需要在```model```和```controllers```写好方法，定好接口即可，十分方便**


### 前端对接接口

后端接口已经开放，接下来要把前端和后端进行对接。主要有两个对接接口：

1. 获取某个用户的所有```todolist```
2. 创建某个用户的一条```todolist```

接下来改写```Todolist.vue```里的方法：
```js
<script>
import jwt from 'jsonwebtoken' // 安装koa-jwt的时候会自动下载这个依赖

export default {
  created () {
    const userInfo = this.getUserInfo()
    if (!userInfo !== null) {
      this.id = userInfo.id
      this.name = userInfo.name
    } else {
      this.id = ''
      this.name = ''
    }
    this.getTodolist() // 新增：在组件创建时获取todolist
  },
  data () {...},
  computed: {...},
  methods: {
    addTodos () {
      if (this.todos === '') {
        return
      }
      let obj = {
        status: false,
        content: this.todos,
        id: this.id
      }
      this.$http.post('/api/todolist', obj) // 新增创建请求
        .then((res) => {
          if (res.status === 200) { // 当返回的状态为200成功时
            this.$message({
              type: 'success',
              message: '创建成功！'
            })
            this.getTodolist() // 获得最新的todolist
          } else {
            this.$message.error('创建失败！') // 当返回不是200说明处理出问题
          }
        }, (err) => {
          this.$message.error('创建失败！') // 当没有返回值说明服务端错误或者请求没发送出去
          console.log(err)
        })
      this.todos = '' // 将当前todos清空
    },
    finished (index) {...},
    remove (index) {...},
    restore (index) {...},
    getUserInfo () {...},
    getTodolist () {
      this.$http.get('/api/todolist/' + this.id) // 向后端发送获取todolist的请求
        .then((res) => {
          if (res.status === 200) {
            this.list = res.data // 将获取的信息塞入实例里的list
          } else {
            this.$message.error('获取列表失败！')
          }
        }, (err) => {
          this.$message.error('获取列表失败！')
          console.log(err)
        })
    }
  }
}
</script>
```

### Todolist的改、删

```js
// server/models/todolist.js
......
const removeTodolist = function* (id, user_id){
    yield Todolist.destroy({
        where: {
            id,
            user_id
        }
    })
    return true
}

const updateTodolist = function* (id, user_id, status){
    yield Todolist.update(
        {
            status
        },
        {
            where: {
                id,
                user_id
            }
        }
    )
  return true
}

module.exports = {
    getTodolistById,
    createTodolist,
    removeTodolist,
    updateTodolist
}
```

```js
// server/controllers/todolist.js
......
const removeTodolist = function* (){
    const id = this.params.id
    const user_id = this.params.userId
    const result = yield todolist.removeTodolist(id, user_id)

    this.body = {
        success: true
    }
}

const updateTodolist = function* (){
    const id = this.params.id
    const user_id = this.params.userId
    let status = this.params.status
    status = (status == '0') ? 1 : 0 // 状态反转（更新）

    const result = yield todolist.updateTodolist(id, user_id, status)

    this.body = {
        success: true
    }
}

module.exports = (router) => {
    router.get('/todolist/:id', getTodolist),
    router.post('/todolist', createTodolist),
    router.delete('/todolist/:userId/:id', removeTodolist),
    router.put('/todolist/:userId/:id/:status', updateTodolist)
}
```

```html
<!-- src/components/TodoList.vue -->
......
<!-- 把完成和还原的方法替换成了update -->
<!--<el-button size="small" type="primary" @click="finished(index)">完成</el-button>-->
<el-button size="small" type="primary" @click="update(index)">完成</el-button>
......
<!--<el-button size="small" type="primary" @click="restore(index)">还原</el-button>-->
<el-button size="small" type="primary" @click="update(index)">还原</el-button>
......
<script>
  ......
  methods: {
    ......
    update (index) {
      this.$http.put('/api/todolist/' + this.id + '/' + this.list[index].id + '/' + this.list[index].status)
        .then((res) => {
          if (res.status === 200) {
            this.$message({
              type: 'success',
              message: '任务状态更新成功！'
            })
            this.getTodolist()
          } else {
            this.$message.error('任务状态更新失败！')
          }
        }, (err) => {
          this.$message.error('任务状态更新失败！')
          console.log(err)
        })
    },
    remove (index) {
      this.$http.delete('/api/todolist/' + this.id + '/' + this.list[index].id)
        .then((res) => {
          if (res.status === 200) {
            this.$message({
              type: 'success',
              message: '任务删除成功！'
            })
            this.getTodolist()
          } else {
            this.$message.error('任务删除失败！')
          }
        }, (err) => {
          this.$message.error('任务删除失败！')
          console.log(err)
        })
    },
    ......
  }
</script>
```


## 项目部署

很多教程到类似于我上面的部分就结束了。但是实际上做一个项目最想要的就是部署给大家用不是么？

在部署这块有些坑，需要让大家也一起知道一下。这个项目是个全栈项目（虽然是个很简单的。。。），所以就涉及到前后端通信的问题，也就会涉及到是同域请求还是跨域请求。

也说过，要解决这个问题有两种方便的解决办法，第一种，服务端加上```cors```，客户端就可以随意的跨域请求。但是这样会有个问题，因为以同域的形式开发，请求的地址也是写的相对地址：```/api/*```、```auth/*```这样的路径，访问的路径的自然是同域。如果要在服务端加上```cors```，还需要将所有请求地址改成```localhost:8000/api/*```，```localhost:8000/auth/*```，这样的话，如果服务端的端口号一变，还需要重新修改前端所有的请求地址。这样很不方便也很不科学。

因此，要将请求变为同域才是最好的解决办法——不管服务端端口号怎么变，只要是同域都可以请求到。

于是要把```Vue```和```Koa```结合起来变成一个完整的项目（之前实际上都是在开发模式下，```webpack```进行请求的代理转发，所以看起来像是同域请求，而```Vue```和```Koa```并没有完全结合起来），就得在生产模式下，将```Vue```的静态文件交给```Koa```“托管”，所有访问前端的请求全部走```Koa```端，包括静态文件资源的请求，也走```Koa```端，把```Koa```作为一个```Vue```项目的静态资源服务器，这样就可以让```Vue```里的请求走的都是同域了。（相当于，之前开发模式是```webpack```开启了一个服务器托管了```Vue```的资源和请求，现在生产模式下改成```Koa```托管```Vue```的资源和请求）

要在开发和生产模式改变不同的托管服务器，其实也很简单，只需要在生产模式下，用```Koa```的静态资源服务中间件托管构建好的Vue文件即可。

### Webpack打包

部署之前要用```Webpack```将前端项目打包输出一下。但是如果直接用```npm run build```，会发现打包出来的文件太大了。
竟然有几MB的map文件。这肯定是不能接受的。于是要修改一下webpack的输出的设置，取消输出map文件。

**找到根目录下的```config/index.js```：把```productionSourceMap: true```这句话改成```productionSourceMap: false```。然后再执行一遍```npm run build```。**

### Koa serve静态资源

```
$ yarn add koa-static
```
打开```app.js```，引入两个新依赖：
```js
// app.js
......
const path =require('path'),
    serve = require('koa-static')
......
// 静态文件serve在koa-router的其他规则之上
app.use(serve(path.resolve('dist'))); // 将webpack打包好的项目目录作为Koa静态文件服务的目录

router.use('/auth', auth.routes()) // 挂载到koa-router上，同时会让所有的auth的请求路径前面加上'/auth'的请求路径
router.use('/api', jwt({ secret: 'vue-koa-demo' }), api.routes()) // 所有走/api/打头的请求都需要经过jwt中间件的验证。secret密钥必须跟当初签发的secret一致
.....
```

然后重新运行一遍```node app.js```，看到输出```Koa is listening in 8000```后，可以打开浏览器```localhost:8000```就可以进入首页。

至此已经基本上接近尾声，不过还存在一个问题：如果登录进去之后，在```todolist```页面一刷新，就会出现：

为什么会出现这种情况？简单来说是因为使用了前端路由，用了```HTML5``` 的```History```模式，如果没有做其他任何配置的话，刷新页面，那么浏览器将会去服务端访问这个页面地址，因为服务端并没有配置这个地址的路由，所以自然就返回```404 Not Found```了。

详细可以参考```vue-router```的[这篇文档](https://router.vuejs.org/zh-cn/essentials/history-mode.html)

该怎么解决？其实也很简单，多加一个中间件：```koa-history-api-fallback```即可.
```
$ yarn add koa-history-api-fallback
```
```js
// app.js
......
const historyApiFallback = require('koa-history-api-fallback')

app.use(require('koa-bodyparser')())
app.use(json())
app.use(logger())
app.use(historyApiFallback()); // 在这个地方加入。一定要加在静态文件的serve之前，否则会失效。
......
```
这个时候，再重新启动一下```koa```，登录之后再刷新页面，就不会再出现```404 Not Found```了。


## API Test

本来写到上面基本本文已经算是结束了。但是由于我在开发的过程中遇到了一些问题，所以还需要做一些微调。

知道```koa```的```use```方法是有顺序只差的。
```js
const app = require('koa');
app.use(A);
app.use(B);
const app = require('koa');
app.use(B);
app.use(A);
```
这二者是有区别的，谁先被```use```，谁的规则就放到前面先执行。

因此如果将静态文件的```serve```以及```historyApiFallback```放在了```api```的请求之前，那么用```postman```测试api的时候总会先返回完整的页面：

因此正确的做法，应该是将它们放到写的api的规则之后：
```js
// app.js
......
router.use('/auth', auth.routes()) // 挂载到koa-router上，同时会让所有的auth的请求路径前面加上'/auth'的请求路径
router.use('/api', jwt({ secret: 'vue-koa-demo' }), api.routes()) // 所有走/api/打头的请求都需要经过jwt中间件的验证。secret密钥必须跟当初签发的secret一致

app.use(router.routes()) // 将路由规则挂载到Koa上

// 将这两个中间件挂载在api的路由之后
app.use(historyApiFallback()); // 在这个地方加入。一定要加在静态文件的serve之前，否则会失效。
app.use(serve(path.resolve('dist'))); // 将webpack打包好的项目目录作为Koa静态文件服务的目录
......
```
这样就能正常返回数据了

### Nginx配置

真正部署到服务器的时候，肯定不会让大家输入域名```:8000```这样的方式让大家访问。所以需要用```Nginx```监听```80```端口，把访问指定域名的请求引导转发给```Koa```服务端。

大致的```nginx.conf```如下：
```
http {

  # ....
  upstream koa.server{
    server 127.0.0.1:8000;
  }

  server {
    listen   80;
    server_name xxx.xxx.com;

    location / {
      proxy_pass http://koa.server;
      proxy_redirect off;
    }

    #....
  }
  #....
}
```

项目最后的目录如下：
```
.
├── README.md
├── app.js
├── build
│   ├── build.js
│   ├── check-versions.js
│   ├── dev-client.js
│   ├── dev-server.js
│   ├── utils.js
│   ├── webpack.base.conf.js
│   ├── webpack.dev.conf.js
│   └── webpack.prod.conf.js
├── config
│   ├── dev.env.js
│   ├── index.js
│   ├── prod.env.js
│   └── test.env.js
├── dist
│   ├── index.html
│   └── static
│       ├── css
│       │   └── app.41a08ddf6233846184a005c74588fbac.css
│       ├── fonts
│       │   ├── element-icons.a61be9c.eot
│       │   └── element-icons.b02bdc1.ttf
│       ├── img
│       │   └── element-icons.09162bc.svg
│       └── js
│           ├── app.b3b4ea546c59b19fa980.js
│           ├── manifest.f6264be8d7357cb671c3.js
│           └── vendor.041cdf78fad32d6ddba1.js
├── index.html
├── package.json
├── server
│   ├── config
│   │   └── db.js
│   ├── controllers
│   │   ├── todolist.js
│   │   └── user.js
│   ├── models
│   │   ├── todolist.js
│   │   └── user.js
│   ├── routes
│   │   ├── api.js
│   │   └── auth.js
│   └── schema
│       ├── list.js
│       └── user.js
├── src
│   ├── App.vue
│   ├── assets
│   │   └── logo.png
│   ├── components
│   │   ├── Hello.vue
│   │   ├── Login.vue
│   │   └── todoList.vue
│   └── main.js
├── static
├── table.sql
├── test
│   ├── e2e
│   │   ├── custom-assertions
│   │   │   └── elementCount.js
│   │   ├── nightwatch.conf.js
│   │   ├── runner.js
│   │   └── specs
│   │       └── test.js
│   └── unit
│       ├── index.js
│       ├── karma.conf.js
│       └── specs
│           └── Hello.spec.js
└── yarn.lock

24 directories, 48 files
```

原文链接：[https://github.com/Molunerfinn/vue-koa-demo/blob/master/Vue%2BKoa.md](https://github.com/Molunerfinn/vue-koa-demo/blob/master/Vue%2BKoa.md)