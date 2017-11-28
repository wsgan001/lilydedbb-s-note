# Pyenv

- `$ pyenv versions`: List all Python versions available to pyenv

```
$ pyenv versions
  system
  2.7.14
  3.6.3
* anaconda3-5.0.1 (set by /Users/dbb/.pyenv/version)
```

- `$ pyenv global`: Set or show the global Python version
- `$ pyenv local`: Set or show the local Python version


### pyenv installer

```
$ curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
```

Uninstall:

pyenv is installed within `$PYENV_ROOT` (default: `~/.pyenv`). To uninstall, just remove it:

```
$ rm -fr ~/.pyenv
```

and remove these three lines from `.bashrc`:

```
export PATH="~/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```

### 国内源配置

- sohu 源：[http://mirrors.sohu.com/python/](http://mirrors.sohu.com/python/)
- 清华源：[https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/](https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/)

下载需要的版本放到~/.pyenv/cache文件夹下面
然后执行 pyenv install 版本号 安装对应的python版本
傻瓜式脚本如下，其中v表示要下载的版本号

```
v=3.5.2 | wget http://mirrors.sohu.com/python/$v/Python-$v.tar.xz -P ~/.pyenv/cache/ ; pyenv install $v
```

