# 使用 grunt

## 安装grunt

下面这条命令将安装```Grunt```最新版本到项目目录中，并将其添加到```devDependencies```内：
```
$ npm install grunt --save-dev
```

## Gruntfile

```Gruntfile.js``` 或 ```Gruntfile.coffee``` 文件是有效的 ```JavaScript``` 或 ```CoffeeScript``` 文件，应当放在项目根目录中，和```package.json```文件在同一目录层级，并和项目源码一起加入源码管理器

```Gruntfile```由以下几部分构成：

* "wrapper" 函数
* 项目与任务配置
* 加载grunt插件和任务
* 自定义任务

## "wrapper" 函数

每一份 ```Gruntfile``` （和```grunt```插件）都遵循同样的格式所书写的```Grunt```代码必须放在此函数内：
```js
module.exports = function(grunt) {
  // Do grunt-related things in here
};
```

## 项目和任务配置

**以 ```grunt-contrib-watch``` 为例**

大部分的```Grunt```任务都依赖某些配置数据，这些数据被定义在一个```object```内，并传递给```grunt.initConfig``` 方法
```js
// Simple config to run jshint any time a file is added, changed or deleted
grunt.initConfig({
  watch: {
    files: ['**/*'],
    tasks: ['jshint'],
  },
});
```

```js
// Advanced config. Run specific tasks when specific files are added, changed or deleted.
grunt.initConfig({
  watch: {
    gruntfile: {
      files: 'Gruntfile.js',
      tasks: ['jshint:gruntfile'],
    },
    src: {
      files: ['lib/*.js', 'css/**/*.scss', '!lib/dontwatch.js'],
      tasks: ['default'],
    },
    test: {
      files: '<%= jshint.test.src %>',
      tasks: ['jshint:test', 'qunit'],
    },
  },
});
```

## 加载 Grunt 插件和任务

**以 ```grunt-contrib-watch``` 为例**

```js
grunt.loadNpmTasks('grunt-contrib-watch');
```
