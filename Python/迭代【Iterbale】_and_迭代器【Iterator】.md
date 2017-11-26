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