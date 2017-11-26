# Grunt 常用插件和配置

## [grunt-nodemon](https://github.com/ChrisWren/grunt-nodemon)

> Run ```nodemon``` as a grunt task for easy configuration and integration with the rest of your workflow

### Install
```
$ npm install grunt-nodemon --save-dev
```
Then add this line to your project's ```Gruntfile.js``` gruntfile:
```js
grunt.loadNpmTasks('grunt-nodemon');
```

### Usage with all available options set
```js
grunt.initConfig({
    nodemon: {
      dev: {
        script: 'index.js',
        options: {
          args: ['dev'],
          nodeArgs: ['--debug'],
          callback: function (nodemon) {
            nodemon.on('log', function (event) {
              console.log(event.colour);
            });
          },
          env: {
            PORT: '8181'
          },
          cwd: __dirname,
          ignore: ['node_modules/**'],
          ext: 'js,coffee',
          watch: ['server'],
          delay: 1000,
          legacyWatch: true
        }
      },
      exec: {
        options: {
          exec: 'less'
        }
      }
    }
});
```

### Advanced Usage

A common use case is to run ```nodemon``` with other tasks concurrently. It is also common to open a browser tab when starting a server, and reload that tab when the server code changes. These workflows can be achieved with the following config, which uses a custom ```options.callback``` function, and ```grunt-concurrent``` to run nodemon, ```node-inspector```, and ```watch``` in a single terminal tab:
```js
grunt.initConfig({
    concurrent: {
      dev: {
        tasks: ['nodemon', 'node-inspector', 'watch'],
        options: {
          logConcurrentOutput: true
        }
      }
    },
    nodemon: {
      dev: {
        script: 'index.js',
        options: {
          nodeArgs: ['--debug'],
          env: {
            PORT: '5455'
          },
          // omit this property if you aren't serving HTML files and
          // don't want to open a browser tab on start
          callback: function (nodemon) {
            nodemon.on('log', function (event) {
              console.log(event.colour);
            });

            // opens browser on initial server start
            nodemon.on('config:update', function () {
              // Delay before server listens on port
              setTimeout(function() {
                require('open')('http://localhost:5455');
              }, 1000);
            });

            // refreshes browser when server reboots
            nodemon.on('restart', function () {
              // Delay before server listens on port
              setTimeout(function() {
                require('fs').writeFileSync('.rebooted', 'rebooted');
              }, 1000);
            });
          }
        }
      }
    },
    watch: {
      server: {
        files: ['.rebooted'],
        options: {
          livereload: true
        }
      }
    }
});
```

------

## [grunt-concurrent](https://github.com/sindresorhus/grunt-concurrent)

> Run grunt tasks concurrently
> This task is also useful if you need to run ```multiple blocking tasks``` like ```nodemon``` and ```watch``` at once.

### Install
```
$ npm install --save-dev grunt-concurrent
```

### Usage

```js
require('load-grunt-tasks')(grunt); // npm install --save-dev load-grunt-tasks

grunt.initConfig({
    concurrent: {
        target1: ['coffee', 'sass'],
        target2: ['jshint', 'mocha']
    }
});

// tasks of target1 run concurrently, after they all finished, tasks of target2 run concurrently,
// instead of target1 and target2 run concurrently.
grunt.registerTask('default', ['concurrent:target1', 'concurrent:target2']);
```

------

## [grunt-contrib-watch](https://github.com/gruntjs/grunt-contrib-watch)

> Run predefined tasks whenever watched file patterns are added, changed or deleted

### Install

```
$ npm install grunt-contrib-watch --save-dev
```
Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:
```js
grunt.loadNpmTasks('grunt-contrib-watch');
```

### Watch task
> Run this task with the grunt watch command

Example:
```js
grunt.initConfig({
    watch: {
        options: {
            livereload: 1337
        },
        scripts: {
            files: [ 'public/js/*.js' ],
            options: {
                livereload: true
            }
        },
        html: {
            files: [ 'public/*.html', 'public/*.htm' ],
            options: {
                livereload: true
            }
        },
        css: {
            files: '**/*.sass',
            tasks: ['sass'],
            options: {
                livereload: true,
            },
        },
        configFiles: {
            files: [ 'Gruntfile.js' ],
            options: {
                reload: true
            }
        }
    }
})
```
- **tasks**

    This defines which tasks to run when a watched file event occurs.

- **options.reload**

    By default, if `Gruntfile.js` is being watched, then changes to it will trigger the watch task to restart, and reload the `Gruntfile.js` changes. When reload is set to true, changes to any of the watched files will trigger the watch task to restart. This is especially useful if your Gruntfile.js is dependent on other files.
    ```js
    watch: {
      configFiles: {
        files: [ 'Gruntfile.js', 'config/*.js' ],
        options: {
          reload: true
        }
      }
    }
    ```

- **options.livereload**

    Set to `true` or set `livereload: 1337` to a port number to enable live reloading. Default and recommended port is `35729`.

    If enabled a live reload server will be started with the watch task per target. Then after the indicated tasks have run, the live reload server will be triggered with the modified files.

    Passing an object to livereload allows listening on a specific port and hostname/IP or over https connections (by specifying key and cert paths).

    Example:
    ```js
    watch: {
      css: {
        files: '**/*.sass',
        tasks: ['sass'],
        options: {
          livereload: {
            host: 'localhost',
            port: 9000,
            key: grunt.file.read('path/to/ssl.key'),
            cert: grunt.file.read('path/to/ssl.crt')
            // you can pass in any other options you'd like to the https server, as listed here: http://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener
          }
        },
      },
    },
    ```



------

## 常用配置```Gruntfile.js```：
```js
/**
 * Created by dbb on 2017/2/4.
 */
module.exports = function (grunt) {

  grunt.initConfig({
    //监听文件改动
    // watch: {
    //
    // },
    nodemon: {
      dev: {
        options: {
          file: 'app.js',
          args: [],
          ignoredFiles: ['README.md', 'node_modules/**', '.DS_Store'],
          watchedExtensions: ['js'],
          watchedFolders: ['./'],
          debug: true,
          delayTime: 1,
          env: {
            PORT: 8000
          },
          cwd: __dirname
        }
      }
    },
    concurrent: {
      tasks: ['nodemon'],
      options: {
        logConcurrentOutput: true
      }
    }

  })

  //任何文件有改动，重新执行已经注册的任务
  // grunt.loadNpmTasks('grunt-contrib-watch')
  //监听app.js，app.js改动，会自动重启app.js
  grunt.loadNpmTasks('grunt-nodemon')
  grunt.loadNpmTasks('grunt-concurrent')

  //防止因为语法等一些错误，而中断grunt整个服务
  grunt.option('force', true)

  //注册默认任务为concurrent
  grunt.registerTask('default', ['concurrent'])
  grunt.registerTask('test', ['mochaTest'])
}
```