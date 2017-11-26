# MacOS 下安装 tensorflow

Install a python at user level using Homebrew:

```
$ brew install python
$ brew link python
# or
$ brew install python3
$ brew link python3
```

如果连接文件已存在，则：

```
$ brew link --overwrite python
# or
$ brew link --overwrite python3
```

Install or update pip using easy_install:

```
$ easy_install pip
$ pip install --upgrade pip
# or
$ easy_install pip3
$ pip3 install --upgrade pip3
```

Install TensorFlow:

```
$ sudo pip install tensorflow
$ sudo pip install tensorflow-gpu # Optional
# or
$ sudo pip3 install tensorflow
$ sudo pip3 install tensorflow-gpu # Optional
```