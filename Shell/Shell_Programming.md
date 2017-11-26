# Shell Programming


## 运行Shell脚本有两种方法

- 作为可执行程序

    ```bash
    $ sudo chmod +x ./script.sh  #使脚本具有执行权限
    $ ./script.sh  #执行脚本
    ```

- 作为解释器参数

    这种运行方式是，直接运行解释器，其参数就是shell脚本的文件名，如：

    ```bash
    $ /bin/sh script.sh
    $ /bin/php script.php
    ```


## 变量

**注意，变量名和等号之间不能有空格**

- 首个字符必须为字母（a-z，A-Z）
- 中间不能有空格，可以使用下划线（_）
- 不能使用标点符号
- 不能使用bash里的关键字（可用help命令查看保留关键字）

**推荐给所有变量加上花括号，这是个好的编程习惯**

```bash
#!/bin/bash

variable="value" # 定义变量时，变量名不加美元符号（$）
echo $variable # 使用一个定义过的变量，只要在变量名前面加美元符号（$）
echo ${variable}

# 变量名外面的花括号是可选的，加花括号是为了帮助解释器识别变量的边界
for skill in Ada Coffe Action Java
do
    echo "I am good at ${skill}Script"
done
```


### 只读变量

使用 `readonly` 命令可以将变量定义为只读变量，只读变量的值不能被改变

```bash
#!/bin/bash

variable="value"
readonly variable
variable="newValue"
```

```bash
# output
line 5: variable: readonly variable
```


### 删除变量

使用 `unset` 命令可以删除变量：

```bash
unset variable_name
```


### 特殊变量列表

变量 | 含义
-----|-----------------------
$0   | 当前脚本的文件名
$n   | 传递给脚本或函数的参数；n 是一个数字，表示第几个参数。例如，第一个参数是$1，第二个参数是$2
$#   | 传递给脚本或函数的参数个数
$*   | 传递给脚本或函数的所有参数
$@   | 传递给脚本或函数的所有参数；被双引号(" ")包含时，与 $* 稍有不同
$?   | 上个命令的退出状态，或函数的返回
$$   | 当前Shell进程ID；对于 Shell 脚本，就是这些脚本所在的进程ID


### 转义字符

`echo -e` 表示对转义字符进行替换


## 命令替换

命令替换是指Shell可以先执行命令，将输出结果暂时保存，在适当的地方输出

```bash
`command`
```

```bash
#!/bin/bash

DATE=`date`
echo "Now, it's ${DATE}"

USERS=`who | wc -l`
echo "Logged in user are $USERS"

UP=`date ; uptime`
echo "Uptime is $UP"
```

```bash
$ ./script.sh
Now, it's 2017年 6月25日 星期日 11时30分03秒 CST
Logged in user are        3
Uptime is 2017年 6月25日 星期日 11时30分03秒 CST
11:30  up 8 days,  1:40, 3 users, load averages: 4.52 4.02 3.50
```


## 运算符

原生bash不支持简单的数学运算，但是可以通过其他命令来实现

`expr` 是一款表达式计算工具，使用它能完成表达式的求值操作

```bash
$ echo `expr 1 + 1`
2
```

**特别注意乘法运算使用`\*`**

```
$ echo `expr 2 \* 3`
6
```

**关系运算符列表**

变量  | 含义
------|-----------------------
-eq   | 检测两个数是否相等，相等返回 true
-ne   | 检测两个数是否相等，不相等返回 true
-gt   | 检测左边的数是否大于右边的，如果是，则返回 true
-lt   | 检测左边的数是否小于右边的，如果是，则返回 true
-ge   | 检测左边的数是否大于等于右边的，如果是，则返回 true
-le   | 检测左边的数是否小于等于右边的，如果是，则返回 true

**布尔运算符列表**

运算符	| 说明
--------|--------------------
!	    | 非运算，表达式为 true 则返回 false，否则返回 true
-o	    | 或运算，有一个表达式为 true 则返回 true
-a	    | 与运算，两个表达式都为 true 才返回 true

**字符串运算符列表**

运算符	| 说明
--------|----------------
=	    | 检测两个字符串是否相等，相等返回 true
!=	    | 检测两个字符串是否相等，不相等返回 true
-z	    | 检测字符串长度是否为0，为0返回 true
-n	    | 检测字符串长度是否为0，不为0返回 true
str	    | 检测字符串是否为空，不为空返回 true

**文件测试运算符列表**

操作符	| 说明
--------|------------
-b file	| 检测文件是否是块设备文件，如果是，则返回 true
-c file	| 检测文件是否是字符设备文件，如果是，则返回 true
-d file	| 检测文件是否是目录，如果是，则返回 true
-f file	| 检测文件是否是普通文件（既不是目录，也不是设备文件），如果是，则返回 true
-g file	| 检测文件是否设置了 SGID 位，如果是，则返回 true
-k file	| 检测文件是否设置了粘着位(Sticky Bit)，如果是，则返回 true
-p file	| 检测文件是否是具名管道，如果是，则返回 true
-u file	| 检测文件是否设置了 SUID 位，如果是，则返回 true
-r file	| 检测文件是否可读，如果是，则返回 true
-w file	| 检测文件是否可写，如果是，则返回 true
-x file	| 检测文件是否可执行，如果是，则返回 true
-s file	| 检测文件是否为空（文件大小是否大于0），不为空返回 true
-e file	| 检测文件（包括目录）是否存在，如果是，则返回 true


## 字符串

- 单引号
    - 单引号里的任何字符都会原样输出，单引号字符串中的变量是无效的；
    - 单引号字串中不能出现单引号（对单引号使用转义符后也不行）
- 双引号
    - 双引号里可以有变量
    - 双引号里可以出现转义字符


### 拼接字符串

```bash
read name
echo "hello, "${name}"!"
echo "hello, ${name}!"
```


### 获取字符串长度

```bash
str="abcdefg"
echo ${#str}
```


### 子串

```bash
str="abcdefghijklmn"
echo ${str:3:4} # output: defg
```