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
