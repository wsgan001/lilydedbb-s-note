# vue 官方demo


使用[element-ui](http://element.eleme.io/#/zh-CN)组件库构建
```
$ npm install element-ui -S
```
然后在```main.js```中全局引用：
```js
import ElementUI from 'element-ui'
Vue.use(ElementUI)
```


## 路由

使用前端路由：```vue-router```
```js
import VueRouter from 'vue-router'

import Markdown from './components/Markdown.vue'

Vue.use(VueRouter)

const router = new VueRouter({
  mode: 'history',
  base: __dirname,
  routes: [
    {
      path: '/markdown',
      components: Markdown
    }
  ]
})

new Vue({
  router: router,
  render: h => h(App)
}).$mount('#app')
```


## Markdown Editor

需要引入```marked```，```lodash```两个库：
```
$ npm install marked lodash -S
```
官方 [Markdown Editor Example](http://note.youdao.com/) 的源码，使用了计算属性，并给textarea绑定了input事件处理函数，来实时更新markdown内容：
```html
<template>
  <div id="editor">
    <textarea :value="input" @input="update"></textarea>
    <div v-html="compiledMarkdown"></div>
  </div>
</template>
<script>
  import _ from "lodash"
  import marked from "marked"

  export default {
    data () {
      return {
        input: '# hello',
      }
    },
    computed: {
      compiledMarkdown: function(){
        return marked(this.input, { sanitize:true })
      }
    },
    methods: {
      update: _.debounce(function (e) {
        this.input = e.target.value
      }, 300)
    }
  }
</script>
<style>
  #editor {
    margin: 0;
    height: 100%;
    font-family: 'Helvetica Neue', Arial, sans-serif;
    color: #333;
  }
  textarea, #editor div{
    display: inline-block;
    width: 49%;
    height: 100%;
    vertical-align: top;
    -webkit-box-sizing: border-box;
    -moz-box-sizing: border-box;
    box-sizing: border-box;
    padding: 0 20px;
  }
  #editor textarea {
    border: none;
    border-right: 1px solid #ccc;
    resize: none;
    outline: none;
    background-color: #f6f6f6;
    font-size: 14px;
    font-family: 'Monaco', courier, monospace;
    padding: 20px;
    height: 80vh;
  }
  code {
    color: #f66;
  }
</style>
```
但还可以更简单一点，使用```filters```：
```html
<template>
  <div id="editor">
    <textarea :value="input"></textarea>
    <div v-html="input | marked"></div>
  </div>
</template>
<script>
  import _ from "lodash"
  import marked from "marked"

  export default {
    data () {
      return {
        input: '# hello',
      }
    },
    filters: {
      marked: marked
    }
  }
</script>
<style>
  ......
</style>
```


## GitHub Commits

官方 [GitHub Commits Example](https://vuejs.org/v2/examples/commits.html) 源码：
```html
<template>
  <div id="demo">
    <h1>Latest Vue.js Commits</h1>
    <template v-for="branch in branches">
      <input type="radio" :id="branch" :value="branch" name="branch" v-model="currentBranch">
      <label :for="branch">{{ branch }}</label>
    </template>
    <p>vuejs/vue@{{ currentBranch }}</p>
    <ul>
      <li v-for="record in commits">
        <a :href="record.html_url" target="_blank" class="commit">{{ record.sha.slice(0, 7) }}</a>
        - <span class="message">{{ record.commit.message | truncate }}</span><br>
        by <span class="author"><a :href="record.author.html_url" target="_blank">{{ record.commit.author.name }}</a></span>
        at <span class="date">{{ record.commit.author.date | formatDate }}</span>
      </li>
    </ul>
  </div>
</template>
<script>
var apiUrl = 'https://api.github.com/repos/vuejs/vue/commits?per_page=3&sha='

export default {
  data: function() {
    return {
      branches: ['master', 'dev'],
      currentBranch: 'master',
      commits: null
    }
  },
  create: function () {
    this.fetchData()
  },
  watch: {
    currentBranch: 'fetchData'
  },
  filters: {
    truncate: function (v) {
      var newline = v.indexOf('\n')
      return newline > 0 ? v.slice(0, newline) : v
    },
    formatDate: function (v) {
      return v.replace(/T|Z/g, ' ')
    }
  },
  methods: {
    fetchData: function () {
      var xhr = new XMLHttpRequest()
      var self = this
      xhr.open('GET', apiUrl + self.currentBranch)
      xhr.onload = function () {
        self.commits = JSON.parse(xhr.responseText)
        console.log(self.commits[0])
      }
      xhr.send()
    }
  }
}
</script>
<style>
#demo {
  font-family: 'Helvetica', Arial, sans-self;
}
a {
  text-decoration: none;
  color: #f66;
}
li {
  line-height: 1.5rem;
  margin-bottom: 20px;
}
.author, .date {
  font-weight: bold;
}
</style>
```
其中：
* **```v-model``` 只是一个```语法糖```**，本demo中：
    ```html
    <input type="radio" :id="branch" :value="branch" name="branch" v-model="currentBranch">
    ```
    等效于：
    ```html
    <input type="radio" :id="branch" :value="branch" name="branch" v-on:click=" currentBranch = $event.target.value ">
    ```
* ```$watch``` 用于观察 ```Vue``` 实例上的数据变动。这里```radio```的```value```绑定到了```branches```的每一项上，又通过```v-model```绑定到了```currentBranch```上，所以选择不同的```radio```时，```currentBranch```会发生变化，触发```fetchData```方法
* ```create``` 为```Vue```生命周期中的钩子函数，```Vue```的生命周期如下图

![image](https://cn.vuejs.org/images/lifecycle.png)


## Firebase + Validation

```
$ npm install firebase --save
```
官方 [Firebase + Validation Example](https://vuejs.org/v2/examples/firebase.html) 源码：
```html
<template>
  <div id="app">
    <ul is="transition-group">
      <li v-for="user in users" class="user" :key="user['.key']">
        <span>{{ user.name }} - {{ user.email }}</span>
        <button v-on:click="removeUser(user)"></button>
      </li>
    </ul>
    <form id="form" v-on:submit.prevent="addUser">
      <input type="text" v-model="newUser.name" placeholder="Username">
      <input type="email" v-model="newUser.email" placeholder="email@email.com">
      <input type="submit" value="Add User">
    </form>
    <ul class="errors">
      <li v-show="!validation.name">Name cannot be empty</li>
      <li v-show="!validation.email">Please provide a valid email address</li>
    </ul>
  </div>
</template>
<script>
  import firebase from "firebase"
  var emailRE = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.][0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/

  // Setup Firebase
  var config = {
    apiKey: "AIzaSyAi_yuJciPXLFr_PYPeU3eTvtXf8jbJ8zw",
    authDomain: "vue-demo-537e6.firebaseapp.com",
    databaseURL: "https://vue-demo-537e6.firebaseio.com"
  }
  firebase.initializeApp(config)

  var usersRef = firebase.database().ref('users')
  export default{
    data(){
      return{
        users: [],
        newUser: {
          name: '',
          email: ''
        }
      }
    },
    firebase: {
      users: usersRef
    },
    computed: {
      validation: function () {
        return {
          name: !!this.newUser.name.trim(),
          email: emailRE.test(this.newUser.email)
        }
      },
      isValid: function () {
        var validation = this.validation
        return Object.keys(validation).every(function (key) {
          return validation[key]
        })
      }
    },
    methods: {
      addUser: function () {
        if (this.isValid) {
          usersRef.push(this.newUser)
          this.newUser.name = ''
          this.newUser.email = ''
        }
      },
      removeUser: function () {
        usersRef.child(user['.key']).remove()
      }
    }
  }
</script>
<style>
  body {
    font-family: Helvetica, Arial, sans-serif;
  }
  ul {
    padding: 0;
  }
  .user {
    height: 30px;
    line-height: 30px;
    padding: 10px;
    border-top: 1px solid #eee;
    overflow: hidden;
    transition: all .25s ease;
  }
  .user:last-child {
    border-bottom: 1px solid #eee;
  }
  .v-enter,.v-leave {
    height: 0;
    padding-top: 0;
    padding-bottom: 0;
    border-top-width: 0;
    border-bottom-width: 0;
  }
  .errors {
    color: #f00;
  }
</style>
```
其中：
* 修饰符（Modifiers）是以半角句号 . 指明的特殊后缀，用于指出一个指定应该以特殊方式绑定。本demo中```v-on:submit.prevent```，```.prevent``` 修饰符告诉 ```v-on``` 指令对于触发的事件调用 ```event.preventDefault()```
* ```v-show``` 的元素会始终渲染并保持在 ```DOM``` 中，**```v-show``` 是简单的切换元素的 ```CSS``` 属性 ```display```**；```v-if``` **是真实的条件渲染**，因为它会确保条件块在切换当中适当地销毁与重建条件块内的事件监听器和子组件
* 当 ```Vue.js``` 用 ```v-for``` 正在更新已渲染过的元素列表时，它默认用 “```就地复用```” 策略。如果数据项的顺序被改变，```Vue```将不是移动 ```DOM``` 元素来匹配数据项的顺序， 而是简单复用此处每个元素，并且确保它在特定索引下显示已被渲染过的每个元素。**建议尽可能使用 ```v-for``` 来提供 ```key``` ，除非迭代 ```DOM``` 内容足够简单，或者你是故意要依赖于默认行为来获得性能提升。**


## Grid Component

官方给出[Grid Component Example](https://vuejs.org/v2/examples/grid-component.html)的是在同一个文件中注册子组件，现在分为单文件组件：
```html
<!--./templates/GridTemplate.vue-->
<!--component template-->
<template id="grid-template">
  <table>
    <thead>
      <tr>
        <th v-for="key in columns"
            @click="sortBy(key)"
            :class="{ active: sortKey == key }">
          {{ key | capitalize }}
          <span class="arrow" :class="sortOrders[key] > 0 ? 'asc' : 'dsc'">
              </span>
        </th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="entry in filteredData">
        <td v-for="key in columns">
          {{entry[key]}}
        </td>
      </tr>
    </tbody>
  </table>
</template>
<script>
export default {
  template: '#grid-template',
  props: {
    data: Array,
    columns: Array,
    filterKey: String
  },
  data: function () {
    var sortOrders = {}
    this.columns.forEach(function(key){
      sortOrders[key] = 1
    })
    return {
      sortKey: '',
      sortOrders: sortOrders
    }
  },
  computed: {
    filteredData: function () {
      var sortKey = this.sortKey
      var filterKey = this.filterKey && this.filterKey.toLowerCase()
      var order = this.sortOrders[sortKey] || 1
      var data = this.data
      if (filterKey) {
        data = data.filter(function(row){
          return Object.keys(row).some(function(key){
            return String(row[key]).toLowerCase().indexOf(filterKey) > -1
          })
        })
      }
      if (sortKey) {
        data = data.slice().sort(function (a, b) {
          a = a[sortKey]
          b = b[sortKey]
          return (a === b ? 0 : a > b ? 1 : -1) * order
        })
      }
      return data
    }
  },
  filters: {
    capitalize: function (str) {
      return str.charAt(0).toUpperCase() + str.slice(1)
    }
  },
  methods: {
    sortBy: function (key) {
      this.sortKey = key
      this.sortOrders[key] = this.sortOrders[key] * -1
    }
  }
}
</script>
<style>
body {
  font-family: Helvetica Neue, Arial, sans-serif;
  font-size: 14px;
  color: #444;
}

table {
  border: 2px solid #42b983;
  border-radius: 3px;
  background-color: #fff;
}

th {
  background-color: #42b983;
  color: rgba(255,255,255,0.66);
  cursor: pointer;
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
}

td {
  background-color: #f9f9f9;
}

th, td {
  min-width: 120px;
  padding: 10px 20px;
}

th.active {
  color: #fff;
}

th.active .arrow {
  opacity: 1;
}

.arrow {
  display: inline-block;
  vertical-align: middle;
  width: 0;
  height: 0;
  margin-left: 5px;
  opacity: 0.66;
}

.arrow.asc {
  border-left: 4px solid transparent;
  border-right: 4px solid transparent;
  border-bottom: 4px solid #fff;
}

.arrow.dsc {
  border-left: 4px solid transparent;
  border-right: 4px solid transparent;
  border-top: 4px solid #fff;
}
</style>
```
```html
<!--Grid.vue-->
<template>
  <div id="demo">
    <form id="search">
      search <input name="query" v-model="searchQuery">
    </form>
    <demo-grid :data="gridData" :columns="gridColumns" :filter-key="searchQuery"></demo-grid>
  </div>
</template>
<script>
import demoGrid from './templates/GridTemplate.vue'

export default {
  components: {
    'demo-grid': demoGrid
  },
  data: function () {
    return {
      searchQuery: '',
      gridColumns: ['name', 'power'],
      gridData: [
        { name: 'Chuck Norris', power: Infinity },
        { name: 'Bruce Lee', power: 9000 },
        { name: 'Jackie Chan', power: 7000 },
        { name: 'Jet Li', power: 8000 }
      ]
    }
  }
}
</script>
<style>
</style>
```

* 在 ```Vue.js``` 中，父子组件的关系可以总结为

    > **props down, events up**

    父组件通过 props 向下传递数据给子组件，子组件通过 events 给父组件发送消息

    本demo中，子组件通过```props```向子组件传递数据并对数据类型做出验证：
    ```js
    props: {
      data: Array,
      columns: Array,
      filterKey: String
    }
    ```
    子组件绑定这些数据：
    ```html
    <demo-grid :data="gridData" :columns="gridColumns" :filter-key="searchQuery"></demo-grid>
    ```
* 子组件的局部注册，以本demo为例：
    ```html
    <!--父组件-->
    ...
    <demo-grid :data="gridData" :columns="gridColumns" :filter-key="searchQuery"></demo-grid>
    ...
    <script>
    import demoGrid from './GridTemplate.vue'

    export default {
      components: {
        'demo-grid': demoGrid
      },
      ...
    }
    </script>
    ```
    ```html
    <!--子组件-->
    <template id="grid-template">
    ...
    </template>
    <script>
    export default {
      template: '#grid-template',
      ...
    }
    </script>
    ```


## Tree View

官方的 [Tree View Example](https://vuejs.org/v2/examples/tree-view.html) 是一个递归调用组件的示例，源码：
```html
<!--./templates/TreeViewTemplate.vue-->
<template id="item-template">
  <li>
    <div :class="{ bold: isFolder }" @click="toggle" @dbclick="changeType">
      {{ model.name }}
      <span v-if="isFolder">[{{ open ? '-' : '+' }}]</span>
    </div>
    <ul v-show="open" v-if="isFolder">
      <item-template class="item" v-for="model in model.children" :model="model"></item-template>
      <li class="add" @click="addChild"></li>
    </ul>
  </li>
</template>
<script>
import Vue from 'vue'
export default {
  name: 'item-template',
  template: '#item-template',
  props: {
    model: Object
  },
  data: function () {
    return {
      open: false
    }
  },
  computed: {
    isFolder: function () {
      return this.model.children && this.model.children.length
    }
  },
  methods: {
    toggle: function () {
      if (this.isFolder) {
        this.open = !this.open
      }
    },
    changeType: function () {
      if (!this.isFolder) {
        Vue.set(this.model, 'children', [])
        this.addChild()
        this.open = True
      }
    },
    addChild: function () {
      this.model.children.push({
        name: 'new stuff'
      })
    }
  }
}
</script>
<style>
body {
  font-family: Menlo, Consolas, monospace;
  color: #444;
}
.item {
  cursor: pointer;
}
.bold {
  font-weight: bold;
}
ul {
  padding-left: 1em;
  line-height: 1.5em;
  list-style-type: dot;
}
</style>
```
```html
<!--TreeView.vue-->
<template>
  <div>
  <p>(You can double click on an item to turn it into a folder.)</p>
  <ul id="demo">
    <item-template class="item" :model="treeData"></item-template>
  </ul>
  </div>
</template>
<script>
import TreeViewTemplate from './templates/TreeViewTemplate.vue'

export default {
  components: {
    'item-template': TreeViewTemplate
  },
  data: function () {
    return {
      treeData: {
        name: 'My Tree',
        children: [
          { name: 'hello' },
          { name: 'wat' },
          {
            name: 'child folder',
            children: [
              {
                name: 'child folder',
                children: [
                  { name: 'hello' },
                  { name: 'wat' }
                ]
              },
              { name: 'hello' },
              { name: 'wat' },
              {
                name: 'child folder',
                children: [
                  { name: 'hello' },
                  { name: 'wat' }
                ]
              }
            ]
          }
        ]
      }
    }
  }
}
</script>
<style>
.item {
  cursor: pointer;
}
ul {
  padding-left: 1em;
  line-height: 1.5em;
  list-style-type: dot;
}
</style>
```

* 递归调用组件的时候注意给组件赋予 ```name``` 属性，

    > 组件在它的模板内可以递归地调用自己，不过，只有当它有 name 选项时才可以

    否则会报错误：
    ```
    [Vue warn]: Unknown custom element: <item-template> - did you register the component correctly?
    For recursive components, make sure to provide the "name" option.
    ```
    如本例：
    ```html
    <template id="item-template">
        ...
          <item-template class="item" v-for="model in model.children" :model="model"></item-template>
        ...
    </template>
    <script>
    import Vue from 'vue'
    export default {
      name: 'item-template',
      template: '#item-template',
      ...
    }
    </script>
    ```
    这样，组件就可以递归调用自身


## SVG Graph

官方 [SVG Graph Example](https://vuejs.org/v2/examples/svg.html) 源码：
```html
<!--SVGGraph.vue-->
<template>
  <div id="demo">
    <svg width="200" height="200">
      <polygraph :stats="stats"></polygraph>
    </svg>
    <div v-for="stat in stats">
      <label>{{ stat.label }}</label>
      <input type="range" v-model="stat.value" min="0" max="100">
      <span>{{ stat.value }}</span>
      <button @click="remove(stat)" class="remove">X</button>
    </div>
    <form id="add">
      <input type="newlabel" v-model="newLabel">
      <button @click="add">Add a Stat</button>
    </form>
    <pre id="raw">{{ stats }}</pre>
  </div>
</template>
<script>
import PolygraphTemplate from './templates/PolygraphTemplate.vue'

var stats = [
  { label: 'A', value: 100 },
  { label: 'B', value: 100 },
  { label: 'C', value: 100 },
  { label: 'D', value: 100 },
  { label: 'E', value: 100 },
  { label: 'F', value: 100 }
]

export default {
  data: function () {
    return {
      newLabel: '',
      stats: stats
    }
  },
  methods: {
    add: function (e) {
      e.preventDefault()
      if (!this.newLabel) return
      this.stats.push({
        label: this.newLabel,
        value: 100
      })
      this.newLabel = ''
    },
    remove: function (stat) {
      if (this.stats.length > 3) {
        this.stats.splice(this.stats.indexOf(stat), 1)
      } else {
        alert('Can\'t delete more!')
      }
    }
  },
  components: {
    'polygraph': PolygraphTemplate
  }
}
</script>
<style>
body {
    font-family: Helvetica Neue, Arial, sans-serif;
}
polygon {
    fill: #42b983;
    opacity: .75;
}
circle {
    fill: transparent;
    stroke: #999;
}
label {
    display: inline-block;
    margin-left: 10px;
    width: 20px;
}
#raw {
  position: absolute;
  top: 0;
  left: 600px;
}
</style>
```
```html
<!--./templates/PolygraphTemplate.vue-->
<template id="polygraph-template">
  <g>
    <polygon :points="points">
      <circle cx="100" cy="100" r="80"></circle>
      <axis-label v-for="(stat, index) in stats" :stat="stat" :index="index" :total="stats.length"></axis-label>
    </polygon>
  </g>
</template>
<script>
import AxisLabelTemplate from './AxisLabelTemplate.vue'

export default {
  template: '#polygraph-template',
  props: ['stats'],
  computed: {
    points: function () {
      var total = this.stats.length
      return this.stats.map(function(stat, i){
        var point = valueToPoint(stat.value, i, total)
        return point.x + ',' + point.y
      })
    }
  },
  components: {
    'axis-label': AxisLabelTemplate
  }
}

function valueToPoint (value, index, total) {
  var x     = 0
  var y     = -value * 0.8
  var angle = Math.PI * 2 / total * index
  var cos   = Math.cos(angle)
  var sin   = Math.sin(angle)
  var tx    = x * cos - y * sin + 100
  var ty    = x * sin + y * cos + 100
  return {
    x: tx,
    y: ty
  }
}
</script>
<style>
body {
  font-family: Helvetica Neue, Arial, sans-serif;
}
polygon {
  fill: #42b983;
  opacity: .75;
}
circle {
  fill: transparent;
  stroke: #999;
}
text {
  font-family: Helvetica Neue, Arial, sans-serif;
  font-size: 10px;
  fill: #666;
}
</style>
```
```html
<!--./templates/AxisLabelTemplate.vue-->
<template id="axis-label-template">
  <text :x="point.x" :y="point.y">{{ stat.label }}</text>
</template>
<script>
export default {
  template: '#axis-label-template',
  props: {
    stat: Object,
    index: Number,
    total: Number
  },
  computed: {
    point: function () {
      return valueToPoint(+this.stat.value + 10, this.index, this.total)
    }
  }
}

function valueToPoint (value, index, total) {
  var x     = 0
  var y     = -value * 0.8
  var angle = Math.PI * 2 / total * index
  var cos   = Math.cos(angle)
  var sin   = Math.sin(angle)
  var tx    = x * cos - y * sin + 100
  var ty    = x * sin + y * cos + 100
  return {
    x: tx,
    y: ty
  }
}
</script>
<style>
body {
  font-family: Helvetica Neue, Arial, sans-serif;
}
text {
  font-family: Helvetica Neue, Arial, sans-serif;
  font-size: 10px;
  fill: #666;
}
</style>
```


## Modal Component

官方 [Modal Component Example](https://vuejs.org/v2/examples/modal.html) 源码：
```html
<!--Modal.vue-->
<template>
  <div id="app">
    <button id="show-modal" @click="showModal = true">Show Modal</button>
    <modal v-if="showModal" @close="showModal = false">
      <h3 slot="header">custom header</h3>
    </modal>
  </div>
</template>
<script>
import ModalTemplate from './templates/ModalTemplate.vue'

export default {
  data: function () {
    return {
      showModal: false
    }
  },
  components: {
    'modal': ModalTemplate
  }
}
</script>
<style>
</style>
```
```html
<!--./templates/ModalTemplate.vue-->
<template id="modal-template">
  <transition name="modal">
    <div class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">

          <div class="modal-header">
            <slot name="header">
              default header
            </slot>
          </div>

          <div class="modal-body">
            <slot name="body">
              default body
            </slot>
          </div>

          <div class="modal-footer">
            <slot name="footer">
              default footer
              <button class="modal-default-button" @click="$emit('close')">
                OK
              </button>
            </slot>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>
<script>
export default {
  template: '#modal-template'
}
</script>
<style>
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, .5);
  display: table;
  transition: opacity .3s ease;
}
.modal-wrapper {
  display: table-cell;
  vertical-align: middle;
}
.modal-container {
  width: 300px;
  margin: 0px auto;
  padding: 20px 30px;
  background-color: #fff;
  border-radius: 2px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, .33);
  transition: all .3s ease;
  font-family: Helvetica, Arial, sans-serif;
}
.modal-header h3 {
  margin-top: 0;
  color: #42b983;
}
.modal-body {
  margin: 20px 0;
}
.modal-default-button {
  float: right;
}

/*
 * The following styles are auto-applied to elements with
 * transition="modal" when their visibility is toggled
 * by Vue.js.
 *
 * You can easily play with the modal transition by editing
 * these styles.
 */
.modal-enter {
  opacity: 0;
}

.modal-leave-active {
  opacity: 0;
}

.modal-enter .modal-container,
.modal-leave-active .modal-container {
  -webkit-transform: scale(1.1);
  transform: scale(1.1);
}
</style>
```
* 过渡的-CSS-类名
    * ```v-enter```: 定义进入过渡的开始状态。在元素被插入时生效，在下一个帧移除
    * ```v-enter-active```: 定义进入过渡的结束状态。在元素被插入时生效，在 ```transition/animation``` 完成之后移除
    * ```v-leave```: 定义离开过渡的开始状态。在离开过渡被触发时生效，在下一个帧移除
    * ```v-leave-active```: 定义离开过渡的结束状态。在离开过渡被触发时生效，在 ```transition/animation``` 完成之后移除。

    其中```v```是```transition```的```name```
![image](https://cn.vuejs.org/images/transition.png)

* ```<slot>``` 元素可以用一个特殊的属性 ```name``` 来配置如何分发内容。多个 ```slot``` 可以有不同的名字。具名 ```slot``` 将匹配内容片段中有对应 ```slot``` 特性的元素。

    仍然可以有一个匿名 ```slot``` ，它是默认 ```slot``` ，作为找不到匹配的内容片段的备用插槽。如果没有默认的 ```slot``` ，这些找不到匹配的内容片段将被抛弃。

    如本demo中：
    ```html
    <modal v-if="showModal" @close="showModal = false">
      <h3 slot="header">custom header</h3>
    </modal>
    ```
    ```h3```元素就只会分发到```template```中的：
    ```html
    <div class="modal-header">
      <slot name="header">
        default header
      </slot>
    </div>
    ```
    编译之后：
    ```html
    <div class="modal-header">
      <h3>custom header</h3>
    </div>
    ```


## Elastic Header

```
$ npm install dynamics.js --save
```
官方 [Elastic Header Example](https://vuejs.org/v2/examples/elastic-header.html) 源码：
```html
<!--./templates/HeaderViewTemplate.vue-->
<template id="header-view-template">
  <div class="draggable-header-view"
       @mousedown.prevent="startDrag" @touchstart.prevent="startDrag"
       @mousemove.prevent="onDrag" @touchmove.prevent="onDrag"
       @mouseup.prevent="stopDrag" @touchend.prevent="stopDrag" @mouseleave.prevent="stopDrag">
    <svg class="bg" width="320" height="560">
      <path :d="headerPath" fill="#3F51B5"></path>
    </svg>
    <div class="header">
      <slot name="header"></slot>
    </div>
    <div class="content" :style="contentPosition">
      <slot name="content"></slot>
    </div>
  </div>
</template>
<script>
import dynamics from 'dynamics.js'
export default {
  template: '#header-view-template',
  data: function () {
    return {
      dragging: false,
      c: { x: 160, y: 160 },
      start: { x: 0, y: 0 }
    }
  },
  computed: {
    headerPath: function () {
      return 'M0,0 L320,0 320,160' +
        'Q' + this.c.x + ',' + this.c.y +
        ' 0,160'
    },
    contentPosition: function () {
      var dy = this.c.y - 160
      var dampen = dy > 0 ? 2 : 4
      return {
        transform: 'translate3d(0, ' + dy / dampen + 'px, 0)'
      }
    }
  },
  methods: {
    startDrag: function (e) {
      e = e.changedTouches ? e.changedTouches[0] : e
      this.dragging = true
      this.start.x = e.pageX
      this.start.y = e.pageY
    },
    onDrag: function (e) {
      e = e.changedTouches ? e.changedTouches[0] : e
      if (this.dragging) {
        this.c.x = 160 + (e.pageX - this.start.x)
        var dy = e.pageY - this.start.y
        var dampen = dy > 0 ? 1.5 : 4
        this.c.y = 160 + dy / dampen
      }
    },
    stopDrag: function (e) {
      if (this.dragging) {
        this.dragging = false
        dynamics.animate(this.c, {
          x: 160,
          y: 160
        }, {
          type: dynamics.spring,
          duration: 700,
          friction: 280
        })
      }
    }
  }
}
</script>
<style>
.draggable-header-view {
  background-color: #fff;
  box-shadow: 0 4px 16px rgba(0,0,0,.15);
  width: 320px;
  height: 560px;
  overflow: hidden;
  margin: 30px auto;
  position: relative;
  font-family: 'Roboto', Helvetica, Arial, sans-serif;
  color: #fff;
  font-size: 14px;
  font-weight: 300;
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
}
.draggable-header-view .bg {
  position: absolute;
  top: 0;
  left: 0;
  z-index: 0;
}
.draggable-header-view .header, .draggable-header-view .content {
  position: relative;
  z-index: 1;
  padding: 30px;
  box-sizing: border-box;
}
.draggable-header-view .header {
  height: 160px;
}
.draggable-header-view .content {
  color: #333;
  line-height: 1.5em;
}
</style>
```
```html
<!--ElaticHeader.vue-->
<template>
  <draggable-header-view>
    <template slot="header">
      <h1>Elastic Draggable SVG Header</h1>
      <p>with <a href="http://vuejs.org">Vue.js</a> + <a href="http://dynamicsjs.com">dynamics.js</a></p>
    </template>
    <template slot="content">
      <p>Note this is just an effect demo - there are of course many additional details if you want to use this in production, e.g. handling responsive sizes, reload threshold and content scrolling. Those are out of scope for this quick little hack. However, the idea is that you can hide them as internal details of a Vue.js component and expose a simple Web-Component-like interface.</p>
    </template>
  </draggable-header-view>
</template>
<script>
import HeaderViewTemplate from './templates/HeaderViewTemplate.vue'
export default {
  components: {
    'draggable-header-view': HeaderViewTemplate
  }
}
</script>
<style>
h1 {
  font-weight: 300;
  font-size: 1.8em;
  margin-top: 0;
}
a {
  color: #fff;
}
</style>
```
本例应用外部动画库 [```dynamics.js```](http://dynamicsjs.com/) 来展现物理动画


## Wrapper Component

```
$ npm install jquery select2 --save
```
官网 [Wrapper Component Example](https://vuejs.org/v2/examples/select2.html) 源码：
```html
<!--Select2.vue-->
<template>
  <div>
    <p>Selected: {{ selected }}</p>
    <select2 :options="options" v-model="selected">
      <option disabled value="0">Select one</option>
    </select2>
  </div>
</template>
<script>
import WrapperTemplate from './templates/Select2Template.vue'
export default {
  components: {
    'select2': WrapperTemplate
  },
  data: function () {
    return {
      selected: 0,
      options: [
        { id: 1, text: 'Hello' },
        { id: 2, text: 'World' }
      ]
    }
  }
}
</script>
<style>
html, body {
  font: 13px/18px sans-serif;
}
select {
  min-width: 300px;
}
</style>
```
```html
<!--./templates/Select2Template.vue-->
<template id="select2-template">
  <select>
    <slot></slot>
  </select>
</template>
<script>
import $ from "jquery"
import select2 from 'select2'
export default {
  template: '#select2-template',
  props: ['options', 'value'],
  mounted: function () {
    var self = this
    console.log(this.$el)
    $(this.$el)
      .val(this.value)
      .select2({ data: this.options })
      .on('change', function () {
        self.$emit('input', this.value)
      })
  },
  watch: {
    value: function (value) {
      $(this.$el).val(value)
    },
    options: function (options) {
      $(this.$el).select2({ data: options })
    }
  },
  destroyed: function () {
    $(this.$el).off().select2('destroy')
  }
}
</script>
<style>
</style>
```
