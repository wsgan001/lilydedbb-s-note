# python engineer


## python常识

- python可执行文件
```python
#!/usr/bin/env python3
```
文件开头的这句是作用是可以在macOS和Linux上自动运行（windows上不行，Windows系统会忽略这个注释），就像执行一个二进制命令文件一样，```#!```后面的路径是python解释器所在的位置

- python文件编码
```python
#-*- coding:utf-8 -*-
```
python文件默认不是utf-8编码，所以中文字符会引起乱码和错误（无论在代码中还是注释中），如果需要使用中文字符，就需要指定编码格式为```utf-8```

- 占位符

占位符 | 代表
---|---
%d | 整数
%f | 浮点数
%s | 字符串
%x | 十六进制整数
如：

```python
r = (85 - 72) / 72
print('%.2f' % r)
```
- 编码

```
>>> b'\xe4\xb8\xad\xe6\x96\x87'.decode('utf-8')
'中文'
>>> '中文'.encode('utf-8')
b'\xe4\xb8\xad\xe6\x96\x87'
```


## list
list的常用方法：
> append()
> insert(index, item)
> pop([index])
> len(list)


## tuple
> tuple注意事项：
> * **++tuple一旦初始化就不能修改++**
> * **++只有1个元素的tuple定义时必须加一个逗号```,```++**


## dict
++dict全称dictionary，在其他语言中也称为map，使用键-值（key-value）存储，具有极快的查找速度++

```python
>>> d = {'Michael': 95, 'Bob': 75, 'Tracy': 85}
>>> d['Michael']
95
```
如果key不存在，dict就会报错：
```python
>>> d['Thomas']
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
KeyError: 'Thomas'
```
要避免key不存在的错误，有两种办法，一是通过in判断key是否存在：
```python
>>> 'Thomas' in d
False
```
二是通过dict提供的get方法，如果key不存在，可以返回None，或者自己指定的value：
```python
>>> d.get('Thomas')
>>> d.get('Thomas', -1)
-1
```
和list比较，dict有以下几个特点：
1. 查找和插入的速度极快，不会随着key的增加而变慢；
2. 需要占用大量的内存，内存浪费多。

而list相反：
查找和插入的时间随着元素的增加而增加；
1. 占用空间小，浪费内存很少。
2. 所以，dict是用空间来换取时间的一种方法

要保证hash的正确性，作为key的对象就不能变。在Python中，字符串、整数等都是不可变的，因此，可以放心地作为key。而list是可变的，就不能作为key：
```python
>>> key = [1, 2, 3]
>>> d[key] = 'a list'
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: unhashable type: 'list'
```


## set

++set和dict类似，也是一组key的集合，但不存储value。由于key不能重复，所以，在set中，没有重复的key++

**==一个很容易理解错的地方就是：set不是一个去掉重复元素的list，而是一个没有value值的dict，所以其中的每一个元素，都要是hashable的==**

通过```add(key)```方法可以添加元素到set中，可以重复添加，但不会有效果：
```python
>>> s = set([1, 1, 2, 2, 3, 3])
>>> s
{1, 2, 3}
>>> s.add(4)
>>> s
{1, 2, 3, 4}
>>> s.add(4)
>>> s
{1, 2, 3, 4}
```

通过remove(key)方法可以删除元素：
```python
>>> s.remove(4)
>>> s
{1, 2, 3}
```
set可以看成数学意义上的无序和无重复元素的集合，因此，两个set可以做数学意义上的交集、并集等操作：
```python
>>> s1 = set([1, 2, 3])
>>> s2 = set([2, 3, 4])
>>> s1 & s2
{2, 3}
>>> s1 | s2
{1, 2, 3, 4}
```
**++set和dict的唯一区别仅在于没有存储对应的value，但是，set的原理和dict一样，所以，同样不可以放入可变对象，因为无法判断两个可变对象是否相等，也就无法保证set内部“不会有重复元素”。试试把list放入set，看看是否会报错。++**


## 关于函数
**some小知识：**
> * 如果没有return语句，函数执行完毕后也会返回结果，只是结果为None。
> * return None可以简写为return。
> * 函数可以返回多个值，但是这时返回的是一个tuple，在语法上，返回一个tuple可以省略括号，而多个变量可以同时接收一个tuple，按位置赋给对应的值，所以，Python的函数返回多值其实就是返回一个tuple，但写起来更方便

#### 可变参数
```python
def calc(*numbers):
    sum = 0
    for n in numbers:
        sum = sum + n * n
    return sum
```
定义可变参数和定义一个list或tuple参数相比，仅仅在参数前面加了一个```*```号。在函数内部，参数numbers接收到的是一个tuple，因此，函数代码完全不变。但是，调用该函数时，可以传入任意个参数，包括0个参数：
```python
>>> calc(1, 2)
5
>>> calc()
0
```
如果对于一个签名是可变参数的函数，想传入一个已有的list或者tuple时，在list或tuple前面加一个```*```号，把list或tuple的元素变成可变参数传进去：
```python
>>> nums = [1, 2, 3]
>>> calc(*nums)
14
```

#### 关键字参数
关键字参数允许传入0个或任意个含参数名的参数，这些关键字参数在函数内部自动组装为一个dict
```python
def person(name, age, **kw):
    print('name:', name, 'age:', age, 'other:', kw)
>>> person('Michael', 30)
name: Michael age: 30 other: {}
>>> person('Bob', 35, city='Beijing')
name: Bob age: 35 other: {'city': 'Beijing'}
>>> person('Adam', 45, gender='M', job='Engineer')
name: Adam age: 45 other: {'gender': 'M', 'job': 'Engineer'}
>>> extra = {'city': 'Beijing', 'job': 'Engineer'}
>>> person('Jack', 24, **extra)
name: Jack age: 24 other: {'city': 'Beijing', 'job': 'Engineer'}
```

---

**==对于任意函数，都可以通过类似```func(*args, **kw)```的形式调用它，无论它的参数是如何定义的

来看个例子：
```python
def foo(*args, **kwargs):
    print 'args = ', args
    print 'kwargs = ', kwargs
    print '---------------------------------------'

if __name__ == '__main__':
    foo(1,2,3,4)
    foo(a=1,b=2,c=3)
    foo(1,2,3,4, a=1,b=2,c=3)
    foo('a', 1, None, a=1, b='2', c=3)
```
输出结果如下：
```python
args =  (1, 2, 3, 4)
kwargs =  {}
---------------------------------------
args =  ()
kwargs =  {'a': 1, 'c': 3, 'b': 2}
---------------------------------------
args =  (1, 2, 3, 4)
kwargs =  {'a': 1, 'c': 3, 'b': 2}
---------------------------------------
args =  ('a', 1, None)
kwargs =  {'a': 1, 'c': 3, 'b': '2'}
```

递归函数经典：
请编写move(n, a, b, c)函数，它接收参数n，表示3个柱子A、B、C中第1个柱子A的盘子数量，然后打印出把所有盘子从A借助B移动到C的方法
```python
move(3, 'A', 'B', 'C')
# 期待输出:
# A --> C
# A --> B
# C --> B
# A --> C
# B --> A
# B --> C
# A --> C
```

```python
# 利用递归函数移动汉诺塔:
# 从a借助b移动到c
def move(n, a, b, c):
    if n == 1:
        print('move', a, '-->', c)
        return
    # 将已经移动好的n-1层视为一个整体，从a借助c移动到b
    move(n-1, a, c, b)
    # 将第n个，即最大的一个，从a移动到c
    print('move', a, '-->', c)
    # 将已经移动好的n-1层视为一个整体，从b借助a移动到c
    move(n-1, b, a, c)
```


## 切片 (Slice)

```python
[start:end:step]
# 从索引start开始，到索引end，但不包括end，步长为step
```
> * start不写默认为0，end不写默认为最后的索引加1(即list的长度)
> * start, end支持负数索引
> * step可以为负数，意为倒着每隔step取一个
> * 只写[:]就可以原样复制一个list：
```python
>>> L = list(range(100))
>>> L[:]
[0, 1, 2, 3, ..., 99]
```


## 迭代【Iterbale】& 迭代器【Iterator】

### 迭代【Iterbale】
在Python中，迭代是通过```for ... in```来完成的。

list的迭代很容易理解，即bian li遍历每一个元素；但是对于dict，默认情况下，dict迭代的是key，如：

```python
>>> d = {'a': 1, 'b': 2, 'c': 3}
>>> for key in d:
...     print(key)
...
a
c
b
```
如果要迭代value，可以用```for value in d.values()```，如果要同时迭代key和value，可以用```for k, v in d.items()```
判断一个对象是否为Iterable【注意这里是```Iterable```，要和迭代器```Iterator```区分开】
```python
>>> from collections import Iterable
>>> isinstance('abc', Iterable) # str是否可迭代
True
>>> isinstance([1,2,3], Iterable) # list是否可迭代
True
>>> isinstance(123, Iterable) # 整数是否可迭代
False
```
对于list，迭代的时候遍历的是每一个元素，但是无法获取对应的下标，如果要对list实现类似Java那样的下标循环，Python内置的```enumerate```函数可以把一个list变成索引-元素对，这样就可以在for循环中同时迭代索引和元素本身：
```python
>>> for i, value in enumerate(['A', 'B', 'C']):
...     print(i, value)
...
0 A
1 B
2 C
```

### 迭代器【Iterator】
可以被next()函数调用并不断返回下一个值的对象称为迭代器：Iterator
```python
>>> from collections import Iterator
>>> isinstance((x for x in range(10)), Iterator)
True
>>> isinstance([], Iterator)
False
>>> isinstance({}, Iterator)
False
>>> isinstance('abc', Iterator)
False
```
**==生成器都是Iterator对象，但list、dict、str虽然是Iterable，却不是Iterator==**
集合数据类型如list、dict、str等是Iterable但不是Iterator，不过可以通过iter()函数获得一个Iterator对象。

Python的for循环本质上就是通过不断调用next()函数实现的，例如：
```python
for x in [1, 2, 3, 4, 5]:
    pass
```
实际上完全等价于：
```python
# 首先获得Iterator对象:
it = iter([1, 2, 3, 4, 5])
# 循环:
while True:
    try:
        # 获得下一个值:
        x = next(it)
    except StopIteration:
        # 遇到StopIteration就退出循环
        break
```


## 列表生成式【List Comprehensions】
列表生成式相当于对于一个Iterable对象，遍历每一个元素，然后对每一个元素执行同样的操作，还可以有多个迭代叠加
```python
>>> [x * x for x in range(1, 11)]
[1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
```
for循环后面还可以加上if判断，这样就可以筛选出仅偶数的平方：
```python
>>> [x * x for x in range(1, 11) if x % 2 == 0]
[4, 16, 36, 64, 100]
```
还可以使用两层循环，可以生成全排列：
```python
>>> [m + n for m in 'ABC' for n in 'XYZ']
['AX', 'AY', 'AZ', 'BX', 'BY', 'BZ', 'CX', 'CY', 'CZ']
```
对于dict，for...in...可以迭代key和value，同样的，列表生成式也可以：
```python
>>> d = {'x': 'A', 'y': 'B', 'z': 'C' }
>>> [k + '=' + v for k, v in d.items()]
['y=B', 'x=A', 'z=C']
```


## 生成器
生成器和列表生成式很类似，不同在于：
> 列表生成式会返回一个和原Iterable对象同样长的对象，但是生成器则是保存着这样的运算规则，用```next()```调用的时候才会生成下一个元素，节省了内存空间
创建generator的方法：
1. 只要把一个列表生成式的[]改成()，就创建了一个generator：
```python
>>> L = [x * x for x in range(10)]
>>> L
[0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
>>> g = (x * x for x in range(10))
>>> g
<generator object <genexpr> at 0x1022ef630>
>>> next(g)
0
>>> next(g)
1
>>> next(g)
4
>>> next(g)
9
>>> next(g)
16
>>> next(g)
25
>>> next(g)
36
>>> next(g)
49
>>> next(g)
64
>>> next(g)
81
>>> next(g)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
StopIteration
```
【即】generator保存的是算法，每次调用next(g)，就计算出g的下一个元素的值，直到计算到最后一个元素，没有更多的元素时，抛出StopIteration的错误。
2. 如果一个函数定义中包含yield关键字，那么这个函数就不再是一个普通函数，而是一个generator：
```python
def fib(max):
    n, a, b = 0, 0, 1
    while n < max:
        yield b
        a, b = b, a + b
        n = n + 1
    return 'done'
>>> f = fib(6)
>>> f
<generator object fib at 0x104feaaa0>
```


## 高阶函数
#### map()
map()函数接收两个参数，一个是函数，一个是**Iterable**，map将传入的函数依次作用到序列的每个元素，并把结果作为新的**Iterator**返回
```python
>>> def f(x):
...     return x * x
...
>>> r = map(f, [1, 2, 3, 4, 5, 6, 7, 8, 9])
>>> r
<map object at 0x10197ed30>
>>> next(r)
1
>>> next(r)
4
>>> next(r)
9
>>> next(r)
16
>>> next(r)
25
>>> list(r)
[1, 4, 9, 16, 25, 36, 49, 64, 81]
```
map的第二个参数不一定非要是list，只要是Iterable就可以，所以对于一个dict的每个value也可以这样用：
```python
>>> dict = {'1':1,'2':2,'3':3,'4':4,'5':5}
>>> dict
{'4': 4, '5': 5, '3': 3, '2': 2, '1': 1}
>>> r = map(f, dict.values())
>>> list(r)
[16, 25, 9, 4, 1]
```

#### reduce()
reduce的用法：reduce把一个函数作用在一个序列[x1, x2, x3, ...]上，这个函数必须接收两个参数，reduce把结果继续和序列的下一个元素做累积计算，其效果就是：
```
reduce(f, [x1, x2, x3, x4]) = f(f(f(x1, x2), x3), x4)
```
```python
>>> from functools import reduce
>>> def add(x, y):
...     return x + y
...
>>> reduce(add, [1, 3, 5, 7, 9])
25
```
```python
>>> from functools import reduce
>>> def fn(x, y):
...     return x * 10 + y
...
>>> def char2num(s):
...     return {'0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9}[s]
...
>>> reduce(fn, map(char2num, '13579'))
13579
```

#### filter()
map()类似，filter()也接收一个函数和一个序列。和map()不同的是，filter()把传入的函数依次作用于每个元素，然后根据返回值是True还是False决定保留还是丢弃该元素
```python
def is_odd(n):
    return n % 2 == 1

list(filter(is_odd, [1, 2, 4, 5, 6, 9, 10, 15]))
# 结果: [1, 5, 9, 15]
```
【一个好例子】用filter求素数
```python
def _odd_iter():
    n = 1
    while True:
        n = n + 2
        yield n

def _not_divisible(n):
    return lambda x: x % n > 0

def primes():
    yield 2
    it = _odd_iter() # 初始序列
    while True:
        n = next(it) # 返回序列的第一个数
        yield n
        it = filter(_not_divisible(n), it) # 构造新序列

# 打印1000以内的素数:
for n in primes():
    if n < 1000:
        print(n)
    else:
        break
```

#### sorted()
此外，sorted()函数也是一个高阶函数，它还可以接收一个key函数来实现自定义的排序，例如按绝对值大小排序：
```python
>>> sorted([36, 5, -12, 9, -21], key=abs)
[5, 9, -12, -21, 36]
```
给sorted传入key函数，可实现忽略大小写的排序：
```python
>>> sorted(['bob', 'about', 'Zoo', 'Credit'], key=str.lower)
['about', 'bob', 'Credit', 'Zoo']
```
进行反向排序，不必改动key函数，可以传入第三个参数reverse=True：
```python
>>> sorted(['bob', 'about', 'Zoo', 'Credit'], key=str.lower, reverse=True)
['Zoo', 'Credit', 'bob', 'about']
```

#### 闭包
闭包的一个经典问题就是对于内部函数使用循环变量作为参数，参数的实际值与期望值不符的情况
```python
def count():
    fs = []
    for i in range(1, 4):
        def f():
             return i*i
        fs.append(f)
    return fs

f1, f2, f3 = count()
# 可能认为调用f1()，f2()和f3()结果应该是1，4，9，但实际结果是：
>>> f1()
9
>>> f2()
9
>>> f3()
9
# 全部都是9！原因就在于返回的函数引用了变量i，但它并非立刻执行。等到3个函数都返回时，它们所引用的变量i已经变成了3，因此最终结果为9
```
==**返回闭包时牢记的一点就是：返回函数不要引用任何循环变量，或者后续会发生变化的变量**==
```python
def count():
    def f(j):
        def g():
            return j*j
        return g
    fs = []
    for i in range(1, 4):
        fs.append(f(i)) # f(i)立刻被执行，因此i的当前值被传入f()
    return fs

>>> f1, f2, f3 = count()
>>> f1()
1
>>> f2()
4
>>> f3()
9
```

#### lambda【匿名函数】
匿名函数
```python
lambda x: x * x
```
实际上就是
```python
def f(x):
    return x * x
```
上边```闭包```一节中，最后的例子用lambda表示就是
```python
def count():
    def f(j):
        return lambda: j * j
    fs = []
    for i in range(1, 4):
        fs.append(f(i)) # f(i)立刻被执行，因此i的当前值被传入f()
    return fs

f1, f2, f3 = count()
f1()
f2()
f3()
```

#### 装饰器【decorator】

decorator就是一个返回函数的高阶函数。所以，要定义一个能打印日志的decorator，可以定义如下：
```python
def log(func):
    def wrapper(*args, **kw):
        print('call %s():' % func.__name__)
        return func(*args, **kw)
    return wrapper
```
观察上面的log，因为它是一个decorator，所以接受一个函数作为参数，并返回一个函数。要借助Python的@语法，把decorator置于函数的定义处：
```python
@log
def now():
    print('2015-3-25')
```
调用now()函数，不仅会运行now()函数本身，还会在运行now()函数前打印一行日志：
```python
>>> now()
call now():
2015-3-25
```
把@log放到now()函数的定义处，相当于执行了语句：
```python
now = log(now)
```
由于log()是一个decorator，返回一个函数，所以，原来的now()函数仍然存在，只是现在同名的now变量指向了新的函数，于是调用now()将执行新函数，即在log()函数中返回的wrapper()函数。

wrapper()函数的参数定义是(*args, **kw)，因此，wrapper()函数可以接受任意参数的调用。在wrapper()函数内，首先打印日志，再紧接着调用原始函数

如果decorator本身需要传入参数，那就需要编写一个返回decorator的高阶函数，写出来会更复杂。比如，要自定义log的文本：
```python
def log(text):
    def decorator(func):
        def wrapper(*args, **kw):
            print('%s %s():' % (text, func.__name__))
            return func(*args, **kw)
        return wrapper
    return decorator
```
这个3层嵌套的decorator用法如下：
```python
@log('execute')
def now():
    print('2015-3-25')
```
执行结果如下：
```python
>>> now()
execute now():
2015-3-25
```
和两层嵌套的decorator相比，3层嵌套的效果是这样的：
```python
>>> now = log('execute')(now)
```

以上两种decorator的定义都没有问题，但还差最后一步。因为函数也是对象，它有__name__等属性，但你去看经过decorator装饰之后的函数，它们的__name__已经从原来的'now'变成了'wrapper'：
```python
>>> now.__name__
'wrapper'
```
因为返回的那个wrapper()函数名字就是'wrapper'，所以，需要把原始函数的__name__等属性复制到wrapper()函数中，否则，有些依赖函数签名的代码执行就会出错。

不需要编写```wrapper.__name__ = func.__name__```这样的代码，Python内置的functools.wraps就是干这个事的，所以，一个完整的decorator的写法如下：
```python
import functools

def log(func):
    @functools.wraps(func)
    def wrapper(*args, **kw):
        print('call %s():' % func.__name__)
        return func(*args, **kw)
    return wrapper
```

#### 偏函数【functools.partial】

创建一个偏函数：```functools.partial```，可以直接使用下面的代码创建一个新的函数int2：

```python
>>> import functools
>>> int2 = functools.partial(int, base=2)
>>> int2('1000000')
64
>>> int2('1010101')
85
```
上面的```int2()```相当于：
```python
kw = { 'base': 2 }
int('10010', **kw)
```
当传入：
```python
max2 = functools.partial(max, 10)
```
实际上会把10作为*args的一部分自动加到左边，也就是：
```python
max2(5, 6, 7)
```
相当于：
```python
args = (10, 5, 6, 7)
max(*args)
```
结果为10


## 面向对象

#### 访问限制【伪private实现】
如果要让内部属性不被外部访问，可以把属性的名称前加上两个下划线```__```，在Python中，实例的变量名如果以```__```开头，就变成了一个私有变量（```private```），只有内部可以访问，外部不能访问
```python
class Student(object):

    def __init__(self, name, score):
        self.__name = name
        self.__score = score

    def print_score(self):
        print('%s: %s' % (self.__name, self.__score))

    def get_name(self):
        return self.__name

    def get_score(self):
        return self.__score

    def set_score(self, score):
        if 0 <= score <= 100:
            self.__score = score
        else:
            raise ValueError('bad score')
```
改完后，对于外部代码来说，没什么变动，但是已经无法从外部访问```实例变量.__name```和```实例变量.__score```了：
```python
>>> bart = Student('dbb', 100)
>>> bart.__name
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AttributeError: 'Student' object has no attribute '__name'
```
之所以说python中的访问限制时一个伪的private类型实现，是因为即使是变量以```__```开头，外部也是可以通过某种办法访问的。不能直接访问```__name```是因为Python解释器对外把```__name```变量改成了```_Student__name```，所以，仍然可以通过```_Student__```name来访问```__name```变量。同样的道理在外部设置```__name```属性也是可以的，但实际上这个```__name```变量和class内部的```__name```变量不是一个变量！内部的```__name```变量已经被Python解释器自动改成了```_Student__name```，而外部代码给bart新增了一个```__name```变量。
```python
>>> bart = Student('dbb', 100)
>>> bart.get_name()
'dbb', 100'
>>> bart.__name = 'DBB' # 设置__name变量！
>>> bart.__name
'DBB'
>>> bart.get_name() # get_name()内部返回self.__name
'dbb'
```
**==总的来说就是，Python本身没有任何机制阻止你干坏事，一切全靠自觉==**

#### 类属性
把属性直接定义在```Class```内部，而不是放在```__init__()```内，这样定义的就是类属性【定义了一个类属性后，这个属性虽然归类所有，但类的所有实例都可以访问到】，相当于其他语言中的```static```类型属性

【一般情况下不要把```实例属性```和```类属性```定义同样的名字】

如果```实例属性```和```类属性```定义了同样的名字，那么直接用类名访问的时候访问的就是```类属性```，如果用一个实例访问，则先查找```实例属性```中有无此属性，如果没有才查看```类属性```。
如：
```python
>>> class Student(object):
...     name = 'Student'
...
>>> s = Student() # 创建实例s
>>> print(s.name) # 打印name属性，因为实例并没有name属性，所以会继续查找class的name属性
Student
>>> print(Student.name) # 打印类的name属性
Student
>>> s.name = 'Michael' # 给实例绑定name属性
>>> print(s.name) # 由于实例属性优先级比类属性高，因此，它会屏蔽掉类的name属性
Michael
>>> print(Student.name) # 但是类属性并未消失，用Student.name仍然可以访问
Student
>>> del s.name # 如果删除实例的name属性
>>> print(s.name) # 再次调用s.name，由于实例的name属性没有找到，类的name属性就显示出来了
Student
```

#### 动态语言面向对象的灵活性
正常情况下，当定义了一个class，创建了一个class的实例后，可以给该实例绑定任何属性和方法，这就是动态语言的灵活性。先定义class：
```python
class Student(object):
    pass
```
然后，尝试给实例绑定一个属性：
```python
>>> s = Student()
>>> s.name = 'Michael' # 动态给实例绑定一个属性
>>> print(s.name)
Michael
```
还可以尝试给实例绑定一个方法：
```python
>>> def set_age(self, age): # 定义一个函数作为实例方法
...     self.age = age
...
>>> from types import MethodType
>>> s.set_age = MethodType(set_age, s) # 给实例绑定一个方法
>>> s.set_age(25) # 调用实例方法
>>> s.age # 测试结果
25
```
但是，给一个实例绑定的方法，对另一个实例是不起作用的：
```python
>>> s2 = Student() # 创建新的实例
>>> s2.set_age(25) # 尝试调用方法
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AttributeError: 'Student' object has no attribute 'set_age'
```
为了给所有实例都绑定方法，可以给class绑定方法：
```python
>>> def set_score(self, score):
...     self.score = score
...
>>> Student.set_score = set_score
```
给class绑定方法后，所有实例均可调用：
```python
>>> s.set_score(100)
>>> s.score
100
>>> s2.set_score(99)
>>> s2.score
99
```

#### __slots__
定义一个特殊的```__slots__```变量，来限制该class实例能添加的属性：
```python
class Student(object):
    __slots__ = ('name', 'age') # 用tuple定义允许绑定的属性名称
```
然后：
```python
>>> s = Student() # 创建新的实例
>>> s.name = 'Michael' # 绑定属性'name'
>>> s.age = 25 # 绑定属性'age'
>>> s.score = 99 # 绑定属性'score'
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AttributeError: 'Student' object has no attribute 'score'
```
由于'score'没有被放到```__slots__```中，所以不能绑定score属性，试图绑定score将得到AttributeError的错误。

使用```__slots__```要注意，```__slots__```定义的属性仅对当前类实例起作用，对继承的子类是不起作用的

除非在子类中也定义```__slots__```，这样，子类实例允许定义的属性就是自身的```__slots__```加上父类的```__slots__```。

#### @property
python中，```@property```装饰器负责把一个方法变成属性调用

同时，```@property```本身又创建了另一个装饰器```@score.setter```，负责把一个setter方法变成属性赋值

【注：如果不声明```@score.setter```，那么该属性就是一个只读属性，不可修改。即，只定义```getter```方法，不定义```setter```方法】
```python
>>> class Student(object):
...     def __init__(self, age):
...             self._age = age
...     @property
...     def age(self):
...             return self._age
...
>>> s1 = Student(21)
>>> s1
<__main__.Student object at 0x102253860>
>>> s1.age
21
>>> s1.age = 22
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AttributeError: can't set attribute
```

```python
class Student(object):

    def __init__(self, birth):
        self._birth = birth

    @property
    def birth(self):
        return self._birth

    @birth.setter
    def birth(self, value):
        self._birth = value

    @property
    def age(self):
        return 2015 - self._birth
```
上面的birth是可读写属性，而age就是一个只读属性，因为age可以根据birth和当前时间计算出来

#### 多重继承
python允许多重继承，只需要在子类声明的时候，传入要继承的所有父类的名字作为参数即可，对于一个存在于多个父类的同名方法，且在子类中没有被覆盖，则按照从左到右的顺序在父类中寻找，第一个找到的为准
```python
class subclass(superclass1, superclass2, ...):
    pass
```

#### ```__str__``` & ```__repr__```
打印一个对象的实例，如果不写```__str__()```，打印出来的就是一个调试信息
```python
>>> class Student(object):
...     def __init__(self, name):
...         self.name = name
...
>>> a = Student('dbb')
>>> print(a)
<__main__.Student object at 0x102253828>
```
使用```__str__()```可以定制```print()```函数输出的信息
```python
>>> class Student(object):
...     def __init__(self, name):
...         self.name = name
...     def __str__(self):
...         return 'Student object (name: %s)' % self.name
...
>>> a = Student('dbb')
>>> print(a)
Student object (name: dbb)
```
使用```__repr__()```可以定制在交互环境下直接调用实例变量显示的信息
```python
>>> class Student(object):
...     def __init__(self, name):
...         self.name = name
...     def __str__(self):
...         return 'Student object (name: %s)' % self.name
...     __repr__ = __str__
...
>>> a = Student('dbb')
>>> a
Student object (name: dbb)
```
两者的区别是```__str__()```返回用户看到的字符串，而```__repr__()```返回程序开发者看到的字符串，也就是说，```__repr__()```是为调试服务的

#### ```__iter__``` & ```__next__```
如果一个类想被用于```for...in```循环，类似list或tuple那样，就必须实现一个```__iter__()```方法，该方法返回一个迭代对象，然后，Python的for循环就会不断调用该迭代对象的```__next__()```方法拿到循环的下一个值，直到遇到```StopIteration```错误时退出循环
```python
class Fib(object):
    def __init__(self):
        self.a, self.b = 0, 1 # 初始化两个计数器a，b
    def __iter__(self):
        return self # 实例本身就是迭代对象，故返回自己
    def __next__(self):
        self.a, self.b = self.b, self.a + self.b # 计算下一个值
        if self.a > 100000: # 退出循环的条件
            raise StopIteration();
        return self.a # 返回下一个值

for n in Fib():
    print(n)

1
1
2
3
5
...
46368
75025
```

#### ```__getitem__```
Fib实例虽然能作用于for循环，看起来和list有点像，但是，把它当成list来使用还是不行，比如，取第5个元素：
```python
>>> Fib()[5]
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: 'Fib' object does not support indexing
```
要表现得像list那样按照下标取出元素，需要实现```__getitem__()```方法：
```python
class Fib(object):
    def __getitem__(self, n):
        a, b = 1, 1
        for x in range(n):
            a, b = b, a + b
        return a
```
现在，就可以按下标访问数列的任意一项了：
```python
>>> f = Fib()
>>> f[0]
1
>>> f[1]
1
>>> f[2]
2
>>> f[3]
3
>>> f[10]
89
>>> f[100]
573147844013817084101
```

#### ```__getattr__```
正常情况下，当调用类的方法或属性时，如果不存在，就会报错。比如定义Student类：
```python
class Student(object):

    def __init__(self):
        self.name = 'Michael'
```
调用name属性，没问题，但是，调用不存在的score属性，就有问题了：
```python
>>> s = Student()
>>> print(s.name)
Michael
>>> print(s.score)
Traceback (most recent call last):
  ...
AttributeError: 'Student' object has no attribute 'score'
```
错误信息很清楚地说明，没有找到score这个attribute。

要避免这个错误，除了可以加上一个score属性外，Python还有另一个机制，那就是写一个```__getattr__()```方法，动态返回一个属性。修改如下：
```python
class Student(object):

    def __init__(self):
        self.name = 'Michael'

    def __getattr__(self, attr):
        if attr=='score':
            return 99
```
当调用不存在的属性时，比如score，Python解释器会试图调用```__getattr__(self, 'score')```来尝试获得属性，这样，就有机会返回score的值：
```python
>>> s = Student()
>>> s.name
'Michael'
>>> s.score
99
```
返回函数也是完全可以的：
```python
class Student(object):

    def __getattr__(self, attr):
        if attr=='age':
            return lambda: 25
```
只是调用方式要变为：
```python
>>> s.age()
25
```
注意，只有在没有找到属性的情况下，才调用```__getattr__```，已有的属性，比如name，不会在```__getattr__```中查找

###### 【应用】REST API

利用完全动态的```__getattr__```，可以写出一个链式调用：
```python
class Chain(object):

    def __init__(self, path=''):
        self._path = path

    def __getattr__(self, path):
        return Chain('%s/%s' % (self._path, path))

    def __str__(self):
        return self._path

    __repr__ = __str__
```
```python
>>> Chain().status.user.timeline.list
'/status/user/timeline/list'
```

#### ```__call__```
任何类，只需要定义一个```__call__```方法，就可以直接对实例进行调用
```python
class Student(object):
    def __init__(self, name):
        self.name = name

    def __call__(self):
        print('My name is %s.' % self.name)

>>> s = Student('Michael')
>>> s() # self参数不要传入
My name is Michael.
```
能被调用的对象就是一个```Callable```对象，比如函数和上面定义的带有```__call__()```的类实例：
```python
>>> callable(Student())
True
>>> callable(max)
True
>>> callable([1, 2, 3])
False
>>> callable(None)
False
>>> callable('str')
False
```

#### 枚举类【Enum】
```python
>>> from enum import Enum
>>> Month = Enum('Month', ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'))
>>> for name, member in Month.__members__.items():
...     print(name, '=>', member, ',', member.value)
...
Jan => Month.Jan , 1
Feb => Month.Feb , 2
Mar => Month.Mar , 3
Apr => Month.Apr , 4
May => Month.May , 5
Jun => Month.Jun , 6
Jul => Month.Jul , 7
Aug => Month.Aug , 8
Sep => Month.Sep , 9
Oct => Month.Oct , 10
Nov => Month.Nov , 11
Dec => Month.Dec , 12
```
如果需要更精确地控制枚举类型，可以从Enum派生出自定义类：
```python
from enum import Enum, unique

@unique
class Weekday(Enum):
    Sun = 0 # Sun的value被设定为0
    Mon = 1
    Tue = 2
    Wed = 3
    Thu = 4
    Fri = 5
    Sat = 6
```
```python
>>> Weekday.__members__.keys()
odict_keys(['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'])
>>> Weekday.__members__.values()
odict_values([<Weekday.Sun: 0>, <Weekday.Mon: 1>, <Weekday.Tue: 2>, <Weekday.Wed: 3>, <Weekday.Thu: 4>, <Weekday.Fri: 5>, <Weekday.Sat: 6>])
>>> Weekday.__members__.items()
odict_items([('Sun', <Weekday.Sun: 0>), ('Mon', <Weekday.Mon: 1>), ('Tue', <Weekday.Tue: 2>), ('Wed', <Weekday.Wed: 3>), ('Thu', <Weekday.Thu: 4>), ('Fri', <Weekday.Fri: 5>), ('Sat', <Weekday.Sat: 6>)])
>>> day1 = Weekday.Mon
>>> print(day1)
Weekday.Mon
>>> print(Weekday.Tue)
Weekday.Tue
>>> print(Weekday['Tue'])
Weekday.Tue
>>> print(Weekday.Tue.value)
2
>>> print(day1 == Weekday.Mon)
True
>>> print(day1 == Weekday.Tue)
False
>>> print(Weekday(1))
Weekday.Mon
>>> print(day1 == Weekday(1))
True
>>> Weekday(7)
Traceback (most recent call last):
  ...
ValueError: 7 is not a valid Weekday
>>> for name, member in Weekday.__members__.items():
...     print(name, '=>', member)
...
Sun => Weekday.Sun
Mon => Weekday.Mon
Tue => Weekday.Tue
Wed => Weekday.Wed
Thu => Weekday.Thu
Fri => Weekday.Fri
Sat => Weekday.Sat
```


## 断言
```python
def foo(s):
    n = int(s)
    assert n != 0, 'n is zero!'
    return 10 / n

def main():
    foo('0')
```
assert的意思是，表达式n != 0应该是True，否则，根据程序运行的逻辑，后面的代码肯定会出错。

如果断言失败，assert语句本身就会抛出```AssertionError```：
```python
$ python3 err.py
Traceback (most recent call last):
  ...
AssertionError: n is zero!
```
程序中如果到处充斥着```assert```，和print()相比也好不到哪去。不过，启动Python解释器时可以用-O参数来关闭```assert```：
```python
$ python3 -O err.py
Traceback (most recent call last):
  ...
ZeroDivisionError: division by zero
```


## 获取对象信息
#### type()
type()函数返回对应的Class类型
```python
>>> type(123)
<class 'int'>
>>> type('str')
<class 'str'>
>>> type(None)
<type(None) 'NoneType'>
>>> type(abs)
<class 'builtin_function_or_method'>
>>> type(a)
<class '__main__.Animal'>
```
如果要判断一个对象是否是函数，可以使用types模块中定义的常量
```python
>>> import types
>>> def fn():
...     pass
...
>>> type(fn)==types.FunctionType
True
>>> type(abs)==types.BuiltinFunctionType
True
>>> type(lambda x: x)==types.LambdaType
True
>>> type((x for x in range(10)))==types.GeneratorType
True
```

#### isinstance()
对于class的继承关系来说，使用```type()```就很不方便。要判断class的类型，可以使用```isinstance()```函数，当然```isinstance()```也可以判断普通的变量类型。

#### dir()
如果要获得一个对象的所有属性和方法，可以使用dir()函数，它返回一个包含字符串的list
```python
>>> dir(1)
['__abs__', '__add__', '__and__', '__bool__', '__ceil__', '__class__', '__delattr__', '__dir__', '__divmod__', '__doc__', '__eq__', '__float__', '__floor__', '__floordiv__', '__format__', '__ge__', '__getattribute__', '__getnewargs__', '__gt__', '__hash__', '__index__', '__init__', '__int__', '__invert__', '__le__', '__lshift__', '__lt__', '__mod__', '__mul__', '__ne__', '__neg__', '__new__', '__or__', '__pos__', '__pow__', '__radd__', '__rand__', '__rdivmod__', '__reduce__', '__reduce_ex__', '__repr__', '__rfloordiv__', '__rlshift__', '__rmod__', '__rmul__', '__ror__', '__round__', '__rpow__', '__rrshift__', '__rshift__', '__rsub__', '__rtruediv__', '__rxor__', '__setattr__', '__sizeof__', '__str__', '__sub__', '__subclasshook__', '__truediv__', '__trunc__', '__xor__', 'bit_length', 'conjugate', 'denominator', 'from_bytes', 'imag', 'numerator', 'real', 'to_bytes']
>>> dir('a')
['__add__', '__class__', '__contains__', '__delattr__', '__dir__', '__doc__', '__eq__', '__format__', '__ge__', '__getattribute__', '__getitem__', '__getnewargs__', '__gt__', '__hash__', '__init__', '__iter__', '__le__', '__len__', '__lt__', '__mod__', '__mul__', '__ne__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__rmod__', '__rmul__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', 'capitalize', 'casefold', 'center', 'count', 'encode', 'endswith', 'expandtabs', 'find', 'format', 'format_map', 'index', 'isalnum', 'isalpha', 'isdecimal', 'isdigit', 'isidentifier', 'islower', 'isnumeric', 'isprintable', 'isspace', 'istitle', 'isupper', 'join', 'ljust', 'lower', 'lstrip', 'maketrans', 'partition', 'replace', 'rfind', 'rindex', 'rjust', 'rpartition', 'rsplit', 'rstrip', 'split', 'splitlines', 'startswith', 'strip', 'swapcase', 'title', 'translate', 'upper', 'zfill']
```


## 文件读写

### 读文件
由于文件读写时都有可能产生IOError，一旦出错，后面的f.close()就不会调用。所以，为了保证无论是否出错都能正确地关闭文件，可以使用try ... finally来实现：
```python
try:
    f = open('/path/to/file', 'r')
    print(f.read())
finally:
    if f:
        f.close()
```
但是每次都这么写实在太繁琐，所以，Python引入了with语句来自动调用close()方法：
```python
with open('/path/to/file', 'r') as f:
    print(f.read())
```
++**读取文本文件，并且是UTF-8编码的文本文件。要读取二进制文件，比如图片、视频等等，用```'rb'```模式打开文件即可**++

要读取非UTF-8编码的文本文件，需要给open()函数传入encoding参数，例如，读取GBK编码的文件：
```python
>>> f = open('/Users/michael/gbk.txt', 'r', encoding='gbk')
>>> f.read()
```

#### ```read()``` & ```readline()``` & ```readlines()```
调用```read()```会一次性读取文件的全部内容，如果文件有很大，内存就受不了了，所以，要保险起见，可以反复调用read(size)方法，每次最多读取size个字节的内容。另外，调用```readline()```可以每次读取一行内容，调用```readlines()```一次读取所有内容并按行返回list

### 写文件
调用```write()```来写入文件，但是务必要调用```f.close()```来关闭文件。当写文件时，操作系统往往不会立刻把数据写入磁盘，而是放到内存缓存起来，空闲的时候再慢慢写入。只有调用```close()```方法时，操作系统才保证把没有写入的数据全部写入磁盘。忘记调用```close()```的后果是数据可能只写了一部分到磁盘，剩下的丢失了。所以，还是用```with```语句来得保险：
```python
with open('/Users/michael/test.txt', 'w') as f:
    f.write('Hello, world!')
```

#### StringIO
很多时候，数据读写不一定是文件，也可以在内存中读写。```StringIO```顾名思义就是在内存中读写str。要把str写入```StringIO```，需要先创建一个```StringIO```，然后，像文件一样写入即可：
```python
>>> from io import StringIO
>>> f = StringIO()
>>> f.write('hello')
5
>>> f.write(' ')
1
>>> f.write('world!')
6
>>> print(f.getvalue())
hello world!
```
getvalue()方法用于获得写入后的str。要读取StringIO，可以用一个str初始化StringIO，然后，像读文件一样读取：
```python
>>> from io import StringIO
>>> f = StringIO('Hello!\nHi!\nGoodbye!')
>>> while True:
...     s = f.readline()
...     if s == '':
...         break
...     print(s.strip())
...
Hello!
Hi!
Goodbye!
```
#### BytesIO

StringIO操作的只能是str，如果要操作二进制数据，就需要使用BytesIO。

BytesIO实现了在内存中读写bytes，创建一个BytesIO，然后写入一些bytes：
```python
>>> from io import BytesIO
>>> f = BytesIO()
>>> f.write('中文'.encode('utf-8'))
6
>>> print(f.getvalue())
b'\xe4\xb8\xad\xe6\x96\x87'
```
请注意，写入的不是str，而是经过UTF-8编码的bytes。和StringIO类似，可以用一个bytes初始化BytesIO，然后，像读文件一样读取：
```python
>>> from io import BytesIO
>>> f = BytesIO(b'\xe4\xb8\xad\xe6\x96\x87')
>>> f.read()
b'\xe4\xb8\xad\xe6\x96\x87'
```


## os
```python
>>> import os
>>> os.name # 如果是posix，说明系统是Linux、Unix或Mac OS X，如果是nt，就是Windows系统
'posix'
>>> os.uname()
posix.uname_result(sysname='Darwin', nodename='MacBook-Pro.local', release='16.1.0', version='Darwin Kernel Version 16.1.0: Thu Oct 13 21:26:57 PDT 2016; root:xnu-3789.21.3~60/RELEASE_X86_64', machine='x86_64')
>>> os.environ # 在操作系统中定义的环境变量，全部保存在os.environ这个变量中
environ({'LOGNAME': 'dbb', '__PYVENV_LAUNCHER__': '/Library/Frameworks/Python.framework/Versions/3.5/bin/python3', 'USER': 'dbb', 'PWD': '/Users/dbb', 'XPC_SERVICE_NAME': '0', 'SHLVL': '1', 'TMPDIR': '/var/folders/jz/1hj9hz6s4y1dwqj0l7m4dbh40000gn/T/', 'NVM_DIR': '/Users/dbb/.nvm', 'TERM_PROGRAM': 'Apple_Terminal', '__CF_USER_TEXT_ENCODING': '0x1F5:0x19:0x34', 'TERM': 'xterm-256color', 'ANDROID_HOME': '/usr/local/opt/android-sdk', 'NVM_IOJS_ORG_VERSION_LISTING': 'https://iojs.org/dist/index.tab', 'NVM_IOJS_ORG_MIRROR': 'https://iojs.org/dist', 'PATH': '/Library/Frameworks/Python.framework/Versions/3.5/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/apache-tomcat-9.0.0.M10/bin:/usr/local/mysql/bin:/Users/dbb/bin:/usr/local/opt/android-sdk/tools', 'XPC_FLAGS': '0x0', 'NVM_NODEJS_ORG_MIRROR': 'https://nodejs.org/dist', 'Apple_PubSub_Socket_Render': '/private/tmp/com.apple.launchd.dTQj8uDczx/Render', 'NVM_RC_VERSION': '', '_': '/Library/Frameworks/Python.framework/Versions/3.5/bin/python3', 'SHELL': '/bin/bash', 'TERM_PROGRAM_VERSION': '387', 'SSH_AUTH_SOCK': '/private/tmp/com.apple.launchd.mkuY61bPwa/Listeners', 'TERM_SESSION_ID': '8D45568F-56F3-4F76-A62E-B06A2C98C6CB', 'LANG': 'zh_CN.UTF-8', 'HOME': '/Users/dbb'})
>>> os.environ.get('PATH') # 要获取某个环境变量的值，可以调用os.environ.get('key')
'/Library/Frameworks/Python.framework/Versions/3.5/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/apache-tomcat-9.0.0.M10/bin:/usr/local/mysql/bin:/Users/dbb/bin:/usr/local/opt/android-sdk/tools'
>>> os.path.abspath('.') # 查看当前目录的绝对路径:
'/Users/dbb'
>>> os.path.join('/Users/dbb', 'desktop')
'/Users/dbb/desktop'
>>> os.mkdir('test') # 然后创建一个目录
>>> os.rmdir('test') # 删掉一个目录
>>> os.path.split('/Users/dbb/Desktop/test.txt') # 把一个路径拆分为两部分，后一部分总是最后级别的目录或文件名
('/Users/dbb/Desktop', 'test.txt') # os.path.splitext()可以直接让你得到文件扩展名
>>> os.path.splitext('/Users/dbb/Desktop/test.txt')
('/Users/dbb/Desktop/test', '.txt')
>>> os.rename('/Users/dbb/Desktop/test.txt', '/Users/dbb/Desktop/temp.txt') # 对文件重命名
>>> os.remove('/Users/dbb/Desktop/temp.txt') # 删掉文件
>>> [x for x in os.listdir('.') if os.path.isdir(x)] # 列出当前目录下的所有目录
['.android', '.atom', '.bash_sessions', '.certs', '.config', '.deps', '.eclipse', '.gradle', '.httpie', '.idlerc', '.ipython', '.lldb', '.local', '.m2', '.matplotlib', '.node-gyp', '.npm', '.nvm', '.oracle_jre_usage', '.p2', '.pylint.d', '.qd', '.spyder-py3', '.spyder2', '.ssh', '.subversion', '.tooling', '.Trash', '.vagrant.d', '.vim', '.vscode', 'android-ndk-r13', 'Applications', 'bin', 'Desktop', 'doc', 'Documents', 'Downloads', 'eclipse', 'Library', 'Movies', 'Music', 'mv', 'Pictures', 'Public', 'sudo', 'WebstormProjects']
>>> [x for x in os.listdir('.') if os.path.isfile(x) and os.path.splitext(x)[1]=='.py'] # 要列出所有的.py文件
```


## 序列化【pickle】

把一个对象序列化并写入文件：
```python
>>> import pickle
>>> d = dict(name='dbb', age=21, score=100)
>>> pickle.dumps(d)
b'\x80\x03}q\x00(X\x05\x00\x00\x00scoreq\x01KdX\x04\x00\x00\x00nameq\x02X\x03\x00\x00\x00dbbq\x03X\x03\x00\x00\x00ageq\x04K\x15u.'
```
其中```pickle.dumps()```方法把任意对象序列化成一个bytes，然后，就可以把这个bytes写入文件。或者用另一个方法```pickle.dump()```直接把对象序列化后写入一个```file-like Object```：
```python
>>> f = open('dump.txt', 'wb')
>>> pickle.dump(d, f)
>>> f.close()
```
把对象从磁盘读到内存时，可以先把内容读到一个```bytes```，然后用```pickle.loads()```方法反序列化出对象，也可以直接用```pickle.load()```方法从一个```file-like Object```中直接反序列化出对象。打开另一个Python命令行来反序列化刚才保存的对象
```python
>>> f = open('dump.txt', 'rb')
>>> d = pickle.load(f)
>>> f.close()
>>> d
```


## JSON
Python内置的```json```模块提供了非常完善的Python对象到JSON格式的转换。
```python
>>> import json
>>> d = dict(name='dbb', age=21, score=100)
>>> json.dumps(d)
'{"score": 100, "name": "dbb", "age": 21}'
```
```python
>>> json_d = '{"score": 100, "name": "dbb", "age": 21}'
>>> json.loads(json_d)
{'score': 100, 'name': 'dbb', 'age': 21}
```

### 把一个实例转化为JSON
```python
import json

class Student(object):

    def __init__(self, name, age, score):
        self.name = name
        self.age = age
        self.score = score

# 需要为Student专门写一个转换函数，再把函数传进去即可
def student2dict(std):
    return {
        'name': std.name,
        'age': std.age,
        'score': std.score
    }

>>> json.dumps(s, default=student2dict)
'{"age": 21, "score": 100, "name": "dbb"}'
```
```python
# 也可以不写student2dict方法，用class实例的__dict__属性
>>> json.dumps(s, default=lambda obj: obj.__dict__)
'{"age": 21, "name": "dbb", "score": 100}'
```
如果需要反序列化，童颜要写一个辅助函数
```python
def dict2student(d):
    return Student(d['name'], d['age'], d['score'])
>>> json.loads(json_str, object_hook=dict2student)
<__main__.Student object at 0x10188e5f8>
```
同样也可以用匿名函数的方法
```python
>>> json.loads(json_str, object_hook=lambda d: Student(d['name'], d['age'], d['score']))
<__main__.Student object at 0x10188e5f8>
```


## 进程与线程
### 多进程
Unix/Linux操作系统提供了一个```fork()```系统调用，它非常特殊。普通的函数调用，调用一次，返回一次，但是```fork()```调用一次，返回两次，因为操作系统自动把当前进程（称为父进程）复制了一份（称为子进程），然后，分别在父进程和子进程内返回。

子进程永远返回0，而父进程返回子进程的ID。这样做的理由是，一个父进程可以fork出很多子进程，所以，父进程要记下每个子进程的ID，而子进程只需要调用```getppid()```就可以拿到父进程的ID。

Python的```os```模块封装了常见的系统调用，其中就包括```fork```，可以在Python程序中轻松创建子进程：
```python
import os

print('Process (%s) start...' % os.getpid())
# Only works on Unix/Linux/Mac:
pid = os.fork()
if pid == 0:
    print('I am child process (%s) and my parent is %s.' % (os.getpid(), os.getppid()))
else:
    print('I (%s) just created a child process (%s).' % (os.getpid(), pid))
```
运行结果如下：
```
Process (13276) start...
I (13276) just created a child process (13277).
I am child process (13277) and my parent is 13276.
```

#### multiprocessing
multiprocessing模块就是跨平台版本的多进程模块

multiprocessing模块提供了一个```Process```类来代表一个进程对象（创建一个```Process```实例，用```start()```方法启动，```join()```方法可以等待子进程结束后再继续往下运行，通常用于进程间的同步），下面的例子演示了启动一个子进程并等待其结束：
```python
from multiprocessing import Process
import os

# 子进程要执行的代码
def run_proc(name):
    print('Run child process %s (%s)...' % (name, os.getpid()))

if __name__=='__main__':
    print('Parent process %s.' % os.getpid())
    p = Process(target=run_proc, args=('test',))
    print('Child process will start.')
    p.start()
    p.join()
    print('Child process end.')
```
执行结果如下：
```
Parent process 13196.
Process will start.
Run child process test (13311)...
Process end.
```

#### Pool

如果要启动大量的子进程，可以用进程池的方式批量创建子进程
```python
from multiprocessing import Pool
import os, time, random

def long_time_task(name):
    print('Run task %s (%s)...' % (name, os.getpid()))
    start = time.time()
    time.sleep(random.random() * 10)
    end = time.time()
    print('Task %s runs %0.2f seconds.' % (name, (end - start)))

if __name__=='__main__':
    print('Parent process %s.' % os.getpid())
    p = Pool(4)
    for i in range(5):
        p.apply_async(long_time_task, args=(i,))
    print('Waiting for all subprocesses done...')
    p.close()
    p.join()
    print('All subprocesses done.')
```
执行结果如下：
```
Parent process 13342.
Waiting for all subprocesses done...
Run task 0 (13343)...
Run task 1 (13344)...
Run task 2 (13345)...
Run task 3 (13346)...
Task 0 runs 1.73 seconds.
Run task 4 (13343)...
Task 3 runs 2.64 seconds.
Task 4 runs 5.48 seconds.
Task 2 runs 7.63 seconds.
Task 1 runs 7.89 seconds.
All subprocesses done.
```

#### 子进程

很多时候，子进程并不是自身，而是一个外部进程。创建了子进程后，还需要控制子进程的输入和输出。```subprocess```模块可以非常方便地启动一个子进程，然后控制其输入和输出。

下面的例子演示了如何在Python代码中运行命令```nslookup www.python.org```，这和命令行直接运行的效果是一样的：

```python
import subprocess

print('$ nslookup www.python.org')
r = subprocess.call(['nslookup', 'www.python.org'])
print('Exit code:', r)
```
运行结果如下：
```
$ nslookup www.python.org
Server:		202.114.0.131
Address:	202.114.0.131#53

Non-authoritative answer:
www.python.org	canonical name = python.map.fastly.net.
Name:	python.map.fastly.net
Address: 151.101.24.223

Exit code: 0
```
如果子进程还需要输入，则可以通过```communicate()```方法输入：
```python
import subprocess

print('$ nslookup')
p = subprocess.Popen(['nslookup'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
output, err = p.communicate(b'set q=mx\npython.org\nexit\n')
print(output.decode('utf-8'))
print('Exit code:', p.returncode)
```
上面的代码相当于在命令行执行命令```nslookup```，然后手动输入：
```
set q=mx
python.org
exit
```
运行结果如下：
```
$ nslookup
Server:		202.114.0.131
Address:	202.114.0.131#53

Non-authoritative answer:
python.org	mail exchanger = 50 mail.python.org.

Authoritative answers can be found from:
python.org	nameserver = ns1.p11.dynect.net.
python.org	nameserver = ns2.p11.dynect.net.
python.org	nameserver = ns3.p11.dynect.net.
python.org	nameserver = ns4.p11.dynect.net.
mail.python.org	internet address = 188.166.95.178
ns1.p11.dynect.net	internet address = 208.78.70.11
ns2.p11.dynect.net	internet address = 204.13.250.11
ns3.p11.dynect.net	internet address = 208.78.71.11
ns4.p11.dynect.net	internet address = 204.13.251.11
mail.python.org	has AAAA address 2a03:b0c0:2:d0::71:1


Exit code: 0
```

Python的```multiprocessing```模块包装了底层的机制，提供了```Queue```、```Pipes```等多种方式来交换数据。

这里以```Queue```为例，在父进程中创建两个子进程，一个往```Queue```里写数据，一个从```Queue```里读数据：
```python
from multiprocessing import Process, Queue
import os, time, random

# 写数据进程执行的代码:
def write(q):
    print('Process to write: %s' % os.getpid())
    for value in ['A', 'B', 'C']:
        print('Put %s to queue...' % value)
        q.put(value)
        time.sleep(random.random())

# 读数据进程执行的代码:
def read(q):
    print('Process to read: %s' % os.getpid())
    while True:
        value = q.get(True)
        print('Get %s from queue.' % value)

if __name__=='__main__':
    # 父进程创建Queue，并传给各个子进程：
    q = Queue()
    pw = Process(target=write, args=(q,))
    pr = Process(target=read, args=(q,))
    # 启动子进程pw，写入:
    pw.start()
    # 启动子进程pr，读取:
    pr.start()
    # 等待pw结束:
    pw.join()
    # pr进程里是死循环，无法等待其结束，只能强行终止:
    pr.terminate()
```
运行结果如下：
```
Process to write: 13441
Put A to queue...
Process to read: 13442
Get A from queue.
Put B to queue...
Get B from queue.
Put C to queue...
Get C from queue.
```

### 多线程
Python的标准库提供了两个模块：```_thread```和```threading```，```_thread```是低级模块，```threading```是高级模块，对```_thread```进行了封装。绝大多数情况下，只需要使用```threading```这个高级模块。

启动一个线程就是把一个函数传入并创建```Thread```实例，然后调用```start()```开始执行
```python
import time, threading

# 新线程执行的代码:
def loop():
    print('thread %s is running...' % threading.current_thread().name)
    n = 0
    while n < 5:
        n = n + 1
        print('thread %s >>> %s' % (threading.current_thread().name, n))
        time.sleep(1)
    print('thread %s ended.' % threading.current_thread().name)

print('thread %s is running...' % threading.current_thread().name)
t = threading.Thread(target=loop, name='LoopThread')
t.start()
t.join()
print('thread %s ended.' % threading.current_thread().name)
```
执行结果如下：
```
thread MainThread is running...
thread LoopThread is running...
thread LoopThread >>> 1
thread LoopThread >>> 2
thread LoopThread >>> 3
thread LoopThread >>> 4
thread LoopThread >>> 5
thread LoopThread ended.
thread MainThread ended.
```

由于任何进程默认就会启动一个线程，把该线程称为主线程，主线程又可以启动新的线程，Python的```threading```模块有个```current_thread()```函数，它永远返回当前线程的实例。主线程实例的名字叫```MainThread```，子线程的名字在创建时指定，用```LoopThread```命名子线程。名字仅仅在打印时用来显示，完全没有其他意义，如果不起名字Python就自动给线程命名为```Thread-1```，```Thread-2```……

#### Lock
```python
import time, threading

# 假定这是你的银行存款:
balance = 0

def change_it(n):
    # 先存后取，结果应该为0:
    global balance
    balance = balance + n
    balance = balance - n

def run_thread(n):
    for i in range(100000):
        # 先要获取锁:
        lock.acquire()
        try:
            # 放心地改吧:
            change_it(n)
        finally:
            # 改完了一定要释放锁:
            lock.release()
```
当多个线程同时执行```lock.acquire()```时，只有一个线程能成功地获取锁，然后继续执行代码，其他线程就继续等待直到获得锁为止。

获得锁的线程用完后一定要释放锁，否则那些苦苦等待锁的线程将永远等待下去，成为死线程。所以用```try...finally```来确保锁一定会被释放

用pythony启动与CPU核心数量相同的N个线程，在4核CPU上可以监控到CPU占用率仅有102%，也就是仅使用了一核。

但是用C、C++或Java来改写相同的死循环，直接可以把全部核心跑满，4核就跑到400%，8核就跑到800%，为什么Python不行呢？

因为Python的线程虽然是真正的线程，但解释器执行代码时，有一个```GIL```锁：```Global Interpreter Lock```，任何Python线程执行前，必须先获得```GIL```锁，然后，每执行100条字节码，解释器就自动释放```GIL```锁，让别的线程有机会执行。这个```GIL```全局锁实际上把所有线程的执行代码都给上了锁，所以，多线程在Python中只能交替执行，即使100个线程跑在100核CPU上，也只能用到1个核。

Python虽然不能利用多线程实现多核任务，但可以通过多进程实现多核任务。多个Python进程有各自独立的```GIL```锁，互不影响。

#### ThreadLocal
ThreadLocal可以解决线程中局部变量需要层层传递的问题，如：
```python
import threading

# 创建全局ThreadLocal对象:
local_school = threading.local()

def process_student():
    # 获取当前线程关联的student:
    std = local_school.student
    print('Hello, %s (in %s)' % (std, threading.current_thread().name))

def process_thread(name):
    # 绑定ThreadLocal的student:
    local_school.student = name
    process_student()

t1 = threading.Thread(target= process_thread, args=('Alice',), name='Thread-A')
t2 = threading.Thread(target= process_thread, args=('Bob',), name='Thread-B')
t1.start()
t2.start()
t1.join()
t2.join()
```
执行结果：
```
Hello, Alice (in Thread-A)
Hello, Bob (in Thread-B)
```
全局变量```local_school```就是一个```ThreadLocal```对象，每个```Thread```对它都可以读写```student```属性，但互不影响。你可以把```local_school```看成全局变量，但每个属性如```local_school.student```都是线程的局部变量，可以任意读写而互不干扰，也不用管理锁的问题，```ThreadLocal```内部会处理。

可以理解为全局变量```local_school```是一个```dict```，不但可以用```local_school.student```，还可以绑定其他变量，如```local_school.teacher```等等。

ThreadLocal最常用的地方就是为每个线程绑定一个数据库连接，HTTP请求，用户身份信息等，这样一个线程的所有调用到的处理函数都可以非常方便地访问这些资源


## TCP & UDP

### TCP
客户端tcp链接访问[Sina](https://www.sina.com.cn/)
```python
import socket

# 创建一个socket
# 创建Socket时，AF_INET指定使用IPv4协议，如果要用更先进的IPv6，就指定为AF_INET6。SOCK_STREAM指定使用面向流的TCP协议
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# 建立连接
s.connect(('www.sina.com.cn', 80))
# 发送数据
s.send(b'GET / HTTP/1.1\r\nHost: www.sina.com.cn\r\nConnection: close\r\n\r\n')

# 接收数据
buffer = []
while True:
    # 每次最多接收1k字节:
    d = s.recv(1024)
    if d:
        buffer.append(d)
    else:
        break
data = b''.join(buffer)

# 关闭连接
s.close()

header, html = data.split(b'\r\n\r\n', 1)
print(header.decode('utf-8'))
# 把接收的数据写入文件:
with open('sina.html', 'wb') as f:
    f.write(html)
```
创建```Socket```时，```AF_INET```指定使用```IPv4```协议，如果要用更先进的```IPv6```，就指定为```AF_INET6```。```SOCK_STREAM```指定使用面向流的```TCP```协议，这样，一个```Socket```对象就创建成功，但是还没有建立连接

服务器端tcp示例：
```python
# tcp_server.py
import socket
import threading
import time

# 创建一个基于IPv4和TCP协议的Socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# 监听端口
s.bind(('127.0.0.1', 9999))
# 调用listen()方法开始监听端口，传入的参数指定等待连接的最大数量
s.listen(5)
print('Waiting for connection...')

# 处理来自客户端的请求
def tcplink(sock, addr):
    print('Accept new connection from %s:%s...' % addr)
    sock.send(b'Welcome')
    while True:
        data = sock.recv(1024)
        time.sleep(1)
        if not data or data.decode('utf-8') == 'exit':
            break
        sock.send(('Hello, %s' % data.decode('utf-8')).encode('utf-8'))
    sock.close()
    print('Connection from %s:%s closed.' % addr)

# 通过一个永久循环来接受来自客户端的连接，accept()会等待并返回一个客户端的连接
while True:
    # 接受一个新连接
    sock, addr = s.accept()
    # 创建新线程来处理TCP连接
    # 每个连接都必须创建新线程（或进程）来处理，否则，单线程在处理连接的过程中，无法接受其他客户端的连接
    t = threading.Thread(target=tcplink, args=(sock, addr))
    t.start()
```
客户端tcp测试：
```python
# tcp_client.py
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# 建立连接:
s.connect(('127.0.0.1', 9999))
# 接收欢迎消息:
print(s.recv(1024).decode('utf-8'))
for data in [b'dbb', b'lily']:
    # 发送数据:
    s.send(data)
    print(s.recv(1024).decode('utf-8'))
s.send(b'exit')
s.close()
```
测试结果：
```
MacBook-Pro:python_summary dbb$ python3 tcp_server.py
Waiting for connection...
Accept new connection from 127.0.0.1:61858...
Connection from 127.0.0.1:61858 closed.
```
```
MacBook-Pro:python_summary dbb$ python3 tcp_client.py
Welcome
Hello, dbb
Hello, lily
```


### UDP

```python
# udp_server.py
import socket
import threading

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
# 绑定端口:
s.bind(('127.0.0.1', 9999))
# 绑定端口和TCP一样，但是不需要调用listen()方法，而是直接接收来自任何客户端的数据
print('Bind UDP on 9999...')

# 处理来自客户端的请求
def udplink(sock ,data, addr):
    print('Received from %s:%s.' % addr)
    sock.sendto(b'Hello, %s!' % data, addr)

# 接收来自客户端的连接
while True:
    # recvfrom()方法返回数据和客户端的地址与端口，这样，服务器收到数据后，直接调用sendto()就可以把数据用UDP发给客户端
    data, addr = s.recvfrom(1024)
    t = threading.Thread(target=udplink, args=(s, data, addr))
    t.start()
```

```python
# udp_client.py
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
for data in [b'dbb', b'lily']:
    # 发送数据:
    s.sendto(data, ('127.0.0.1', 9999))
    # 接收数据:
    # 从服务器接收数据仍然调用recv()方法
    print(s.recv(1024).decode('utf-8'))
s.close()
```

测试结果：
```
MacBook-Pro:python_summary dbb$ python3 udp_server.py
Bind UDP on 9999...
Received from 127.0.0.1:51226.
Received from 127.0.0.1:51226.
```
```
MacBook-Pro:python_summary dbb$ python3 udp_client.py
Hello, dbb!
Hello, lily!
```


## 电子邮件【SMTP & POP3】
```python
from email import encoders
from email.header import Header
from email.mime.text import MIMEText, MIMEMultipart
from email.utils import parseaddr, formataddr

import smtplib

# 函数_format_addr()用来格式化一个邮件地址
def _format_addr(s):
    name, addr = parseaddr(s)
    return formataddr((Header(name, 'utf-8').encode(), addr))

# 输入Email地址和口令:
from_addr = input('From: ')
password = input('Password: ')
# 输入收件人地址:
to_addr = input('To: ')
# SMTP服务器地址:
smtp_server = 'smtp.gmail.com'
smtp_port = 587

msg = MIMEMultipart()
msg['From'] = _format_addr('Python爱好者 <%s>' % from_addr)
msg['To'] = _format_addr('管理员 <%s>' % to_addr)
msg['Subject'] = Header('来自SMTP的问候……', 'utf-8').encode()

# 邮件正文是MIMEText:
msg.attach(MIMEText('send with file...', 'plain', 'utf-8'))

# 添加附件就是加上一个MIMEBase，从本地读取一个图片:
with open('/Users/dbb/Downloads/test.png', 'rb') as f:
    # 设置附件的MIME和文件名，这里是png类型:
    mime = MIMEBase('image', 'png', filename='test.png')
    # 加上必要的头信息:
    mime.add_header('Content-Disposition', 'attachment', filename='test.png')
    mime.add_header('Content-ID', '<0>')
    mime.add_header('X-Attachment-Id', '0')
    # 把附件的内容读进来:
    mime.set_payload(f.read())
    # 用Base64编码:
    encoders.encode_base64(mime)
    # 添加到MIMEMultipart:
    msg.attach(mime)

# server = smtplib.SMTP(smtp_server, 25) # SMTP协议默认端口是25
server = smtplib.SMTP(smtp_server, smtp_port) # Gmail的SMTP端口是587
server.starttls() # 只需要在创建SMTP对象后，立刻调用starttls()方法，就创建了安全连接
server.set_debuglevel(1) # 用set_debuglevel(1)就可以打印出和SMTP服务器交互的所有信息
server.login(from_addr, password) # login()方法用来登录SMTP服务器
# sendmail()方法就是发邮件，由于可以一次发给多个人，所以传入一个list，邮件正文是一个str，as_string()把MIMEText对象变成str
server.sendmail(from_addr, [to_addr], msg.as_string())
server.quit()
```


## 连接数据库

### SQLite
```python
>>> import sqlite3
# 数据库文件是test.db
# 如果文件不存在，会自动在当前目录创建:
>>> conn = sqlite3.connect('test.db')
# 创建一个Cursor
>>> cursor = conn.cursor()
# 执行一条SQL语句
>>> cursor.execute('create table user (id varchar(20) primary key, name varchar(20))')
<sqlite3.Cursor object at 0x1018959d0>
>>> cursor.execute('insert into user (id, name) values (\'1\', \'dbb\')')
<sqlite3.Cursor object at 0x1018959d0>
# 通过rowcount获得插入的行数
>>> cursor.rowcount
1
>>> cursor.execute('insert into user (id, name) values (\'2\', \'lily\')')
<sqlite3.Cursor object at 0x1018959d0>
>>> cursor.rowcount
1
>>> cursor.close()
>>> conn.commit()
>>> conn.close()
```

```python
>>> conn = sqlite3.connect('test.db')
>>> cursor = conn.cursor()
# 执行查询语句
>>> cursor.execute('select * from user where id=?', ('1',))
<sqlite3.Cursor object at 0x101895810>
# 获得查询结果集
>>> values = cursor.fetchall()
>>> values
[('1', 'dbb')]
>>> cursor.close()
>>> conn.close()
```

使用```Cursor```对象执行```insert```，```update```，```delete```语句时，执行结果由```rowcount```返回影响的行数，就可以拿到执行结果。

使用```Cursor```对象执行```select```语句时，通过```featchall()```可以拿到结果集。结果集是一个```list```，每个元素都是一个```tuple```，对应一行记录。

如果SQL语句带有参数，那么需要把参数按照位置传递给```execute()```方法，有几个?占位符就必须对应几个参数，例如：
```python
cursor.execute('select * from user where name=? and pwd=?', ('abc', 'password'))
```

### MySQL

```
$ pip install mysql-connector
```

```python
import mysql.connector

conn = mysql.connector.connect(user='root', password='DAbaoBAO71362031', database='test')
cursor = conn.cursor()

cursor.execute('create table user (id varchar(20) primary key, name varchar(20))')
# 插入一行记录，注意MySQL的占位符是%s
cursor.execute('insert into user (id, name) values (%s, %s)', ['1', 'dbb'])
print(cursor.rowcount)
conn.commit()
cursor.close()

cursor = conn.cursor()
cursor.execute('select * from user where id = %s', ('1',))
values = cursor.fetchall()
print(values)

cursor.close()
conn.close()
```

### SQLAlchemy【ORM: Object-Relational Mapping】

```
$ pip install sqlalchemy
```

```python
from sqlalchemy import Column, String, create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

# 创建对象的基类
Base = declarative_base()

# 定义User对象
class User(Base):
    # 表的名字
    __tablename__ = 'user'

    # 表的结构
    id = Column(String(20), primary_key=True)
    name = Column(String(20))

# 初始化数据库连接
# '数据库类型+数据库驱动名称://用户名:口令@机器地址:端口号/数据库名'
engine = create_engine('mysql+mysqlconnector://root:DAbaoBAO71362031@localhost:3306/test')
DBSession = sessionmaker(bind=engine)

# 创建session对象
session = DBSession()
# 创建新User对象
new_user = User(id='1', name='dbb')
# 添加到session
session.add(new_user)
# 提交即保存到数据库
session.commit()
# 关闭session
session.close()

# 创建Session:
session = DBSession()
# 创建Query查询，filter是where条件，最后调用one()返回唯一行，如果调用all()则返回所有行:
user = session.query(User).filter(User.id=='1').one()
# 打印类型和对象的name属性:
print('type:', type(user))
print('id:', user.id)
print('name:', user.name)
# 关闭Session:
session.close()
```
由于关系数据库的多个表还可以用外键实现一对多、多对多等关联，相应地，ORM框架也可以提供两个对象之间的一对多、多对多等功能。

例如，如果一个User拥有多个Book，就可以定义一对多关系如下
```python
class User(Base):
    __tablename__ = 'user'

    id = Column(String(20), primary_key=True)
    name = Column(String(20))
    # 一对多:
    books = relationship('Book')

class Book(Base):
    __tablename__ = 'book'

    id = Column(String(20), primary_key=True)
    name = Column(String(20))
    # “多”的一方的book表是通过外键关联到user表的:
    user_id = Column(String(20), ForeignKey('user.id'))
```


## WSGI【Web Server Gateway Interface】

```python
# demo_http.py
from wsgiref.simple_server import make_server
from hello import app

httpd = make_server('', 8000, app)
print('Serving HTTP on port 8000...')

httpd.serve_forever()
```

```python
# hello.py
def app(environ, start_response):
    start_response('200 OK', [('Content-Type', 'text/html')])
    body = '<h1>Hello, %s </h1>' % (environ['PATH_INFO'][1:] or 'web')
    return [body.encode('utf-8')]
```
上面的```app()```函数就是符合```WSGI```标准的一个HTTP处理函数，它接收两个参数：

- ```environ```：一个包含所有HTTP请求信息的dict对象；

- ```start_response```：一个发送HTTP响应的函数

在```app()```函数中，调用：
```
start_response('200 OK', [('Content-Type', 'text/html')])
```
就发送了HTTP响应的Header，注意```Header```只能发送一次，也就是只能调用一次```start_response()```函数。```start_response()```函数接收两个参数，一个是HTTP响应码，一个是一组list表示的HTTP ```Header```，每个```Header```用一个包含两个str的tuple表示。

通常情况下，都应该把```Content-Type```头发送给浏览器。其他很多常用的```HTTP Header```也应该发送。

然后，函数的返回值body变量b将作为HTTP响应的Body发送给浏览器。

有了```WSGI```，关心的就是如何从```environ```这个dict对象拿到HTTP请求信息，然后构造HTML，通过```start_response()```发送```Header```，最后返回Body

==WSGI仅是一个标准，上面的app()函数遵循了这个标准，然后要实现app()函数的功能需要一个符合WSGI标准的WSGI服务器，符合WSGI标准的WSGI服务器有很多，这里供测试的Python内置模块wsgiref，是用纯Python编写的WSGI服务器的参考实现。所谓“参考实现”是指该实现完全符合WSGI标准，但是不考虑任何运行效率，仅供开发和测试使用==


## 异步IO

### 协程【coroutine】

Python对协程的支持是通过```generator```实现的
```python
def consumer():
    r = ''
    while True:
        n = yield r
        if not n:
            return
        print('[CONSUMER] Consuming %s...' % n)
        r = '200 OK'

def produce(c):
    c.send(None)
    n = 0
    while n < 5:
        n = n + 1
        print('[PRODUCER] Producing %s...' % n)
        r = c.send(n)
        print('[PRODUCER] Consumer return: %s' % r)
    c.close()

c = consumer()
produce(c)
```
注意到```consumer```函数是一个```generator```，把一个```consumer```传入```produce```后：

1. 首先调用```c.send(None)```启动生成器；
2. 然后，一旦生产了东西，通过```c.send(n)```切换到```consumer```执行；
3. ```consumer```通过```yield```拿到消息，处理，又通过```yield```把结果传回；
4. ```produce```拿到```consumer```处理的结果，继续生产下一条消息；
5. ```produce```决定不生产了，通过```c.close()```关闭```consumer```，整个过程结束
运行结果
```
[PRODUCER] Producing 1...
[CONSUMER] Consuming 1...
[PRODUCER] Consumer return: 200 OK
[PRODUCER] Producing 2...
[CONSUMER] Consuming 2...
[PRODUCER] Consumer return: 200 OK
[PRODUCER] Producing 3...
[CONSUMER] Consuming 3...
[PRODUCER] Consumer return: 200 OK
[PRODUCER] Producing 4...
[CONSUMER] Consuming 4...
[PRODUCER] Consumer return: 200 OK
[PRODUCER] Producing 5...
[CONSUMER] Consuming 5...
[PRODUCER] Consumer return: 200 OK
```

### asyncio
用asyncio的异步网络连接来获取sina、sohu和163的网站首页
```python
import asyncio

@asyncio.coroutine
def wget(host):
    print('wget %s...' % host)
    connect = asyncio.open_connection(host, 80)
    reader, writer = yield from connect
    header = 'GET / HTTP/1.0\r\nHost: %s\r\n\r\n' % host
    writer.write(header.encode('utf-8'))
    yield from writer.drain()
    while True:
        line = yield from reader.readline()
        if line == b'\r\n':
            break
        print('%s header > %s' % (host, line.decode('utf-8').rstrip()))
    writer.close()

loop = asyncio.get_event_loop()
tasks = [wget(host) for host in ['www.sina.com.cn', 'www.sohu.com', 'www.163.com']]
loop.run_until_complete(asyncio.wait(tasks))
loop.close()
```
```
wget www.sina.com.cn...
wget www.163.com...
wget www.sohu.com...
www.163.com header > HTTP/1.0 302 Moved Temporarily
www.163.com header > Server: Cdn Cache Server V2.0
www.163.com header > Date: Sun, 04 Dec 2016 14:31:37 GMT
www.163.com header > Content-Length: 0
www.163.com header > Location: http://www.163.com/special/0077jt/error_isp.html
www.163.com header > Connection: close
www.sohu.com header > HTTP/1.1 200 OK
www.sohu.com header > Content-Type: text/html
www.sohu.com header > Content-Length: 92426
www.sohu.com header > Connection: close
www.sohu.com header > Date: Sun, 04 Dec 2016 14:29:51 GMT
www.sohu.com header > Server: SWS
www.sohu.com header > Vary: Accept-Encoding
www.sohu.com header > Cache-Control: no-transform, max-age=120
www.sohu.com header > Expires: Sun, 04 Dec 2016 14:31:51 GMT
www.sohu.com header > Last-Modified: Sun, 04 Dec 2016 14:19:13 GMT
www.sohu.com header > Content-Encoding: gzip
www.sohu.com header > X-RS: 10511343.19686393.11189627
www.sohu.com header > FSS-Cache: HIT from 8162289.14912507.8916056
www.sohu.com header > FSS-Proxy: Powered by 2788255.4164521.3541940
www.sina.com.cn header > HTTP/1.1 200 OK
www.sina.com.cn header > Server: nginx
www.sina.com.cn header > Date: Sun, 04 Dec 2016 14:31:37 GMT
www.sina.com.cn header > Content-Type: text/html
www.sina.com.cn header > Last-Modified: Sun, 04 Dec 2016 14:30:57 GMT
www.sina.com.cn header > Vary: Accept-Encoding
www.sina.com.cn header > Expires: Sun, 04 Dec 2016 14:32:37 GMT
www.sina.com.cn header > Cache-Control: max-age=60
www.sina.com.cn header > X-Powered-By: shci_v1.03
www.sina.com.cn header > X-Cache: MISS from cernet194-227.sina.com.cn
www.sina.com.cn header > Connection: close
```
在```loop.run_until_complete(asyncio.wait(tasks))```中传入包含异步操作的tasks。```yield from```语法可以方便地调用另一个```generator```。由于```yield from```之后必须是一个```coroutine```，所以线程不会等待之后的IO操作，而是直接中断并执行下一个消息循环，从而做到每个task异步并发执行，然后等待```yield from```语句后的IO操作执行完毕之后，在继续执行之后的逻辑

### async/await
注意，```async```和```await```是针对```coroutine```的新语法，要使用新的语法，只需要做两步简单的替换：
1. 把```@asyncio.coroutine```替换为```async```
2. 把```yield from```替换为```await```

所以上面的代码完全等价于：
```python
import asyncio

async def wget(host):
    print('wget %s...' % host)
    connect = asyncio.open_connection(host, 80)
    reader, writer = await connect
    header = 'GET / HTTP/1.0\r\nHost: %s\r\n\r\n' % host
    writer.write(header.encode('utf-8'))
    await writer.drain()
    while True:
        line = await reader.readline()
        if line == b'\r\n':
            break
        print('%s header > %s' % (host, line.decode('utf-8').rstrip()))
    writer.close()

loop = asyncio.get_event_loop()
tasks = [wget(host) for host in ['www.sina.com.cn', 'www.sohu.com', 'www.163.com']]
loop.run_until_complete(asyncio.wait(tasks))
loop.close()
```

### aiohttp
模块```asyncio```可以实现单线程并发IO操作。如果仅用在客户端，发挥的威力不大。如果把```asyncio```用在服务器端，例如Web服务器，由于HTTP连接就是IO操作，因此可以用单线程```+coroutine```实现多用户的高并发支持
```python
import asyncio

from aiohttp import web

async def index(request):
    await asyncio.sleep(0.5)
    return web.Response(body=b'<h1>Index</h1>')

async def hello(request):
    await asyncio.sleep(0.5)
    text = '<h1>hello, %s!</h1>' % request.match_info['name']
    return web.Response(body=text.encode('utf-8'))

async def init(loop):
    app = web.Application(loop=loop)
    app.router.add_route('GET', '/', index)
    app.router.add_route('GET', '/hello/{name}', hello)
    srv = await loop.create_server(app.make_handler(), '127.0.0.1', 8000)
    print('Server started at http://127.0.0.1:8000...')
    return srv

loop = asyncio.get_event_loop()
loop.run_until_complete(init(loop))
loop.run_forever()
```
==注意```aiohttp```的初始化函数```init()```也是一个```coroutine```，```loop.create_server()```则利用```asyncio```创建```TCP```服务==


## 一些零碎知识点
-
```python
if __name__=='__main__':
    pass
```
当在命令行运行hello模块文件时，Python解释器把一个特殊变量```__name__```置为```__main__```，而如果在其他地方导入该hello模块时，if判断将失败，因此，这种if测试可以让一个模块通过命令行运行时执行一些额外的代码，最常见的就是运行测试

-


