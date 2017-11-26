# TensorFlow 笔记

## 计算图 (Computional Graph)

TensorFlow 的两个重要概念 —— Tensor（张量）、Flow（流）

TensorFlow 通过 `计算图 (computional graph)` 的形式表述计算的编程系统。**TensorFlow 中每一个计算都是计算图上的一个节点，节点之间边描述了计算之间的依赖关系。**

### `tf.get_default_graph()`

TensorFlow 程序中，系统自动维护一个默认的计算图，通过 `tf.get_default_graph()` 可以获取当前默认的计算图；可以通过 `<tensor_name>.Graph()` 获得某 tensor 节点所在的计算图。如：

```python
import tensorflow as tf

a = tf.constant([1.0, 2.0], name="a")
b = tf.constant([2.0, 3.0], name="b")
result = a + b

# 通过 a.graph 可以获取tensor所属的计算图，因为没有特意指定，所以即为默认的计算图
print(a.graph is tf.get_default_graph()) # True
```

### `tf.Graph()`

可以通过 `tf.Graph()` 创建新的计算图。**不同计算图中的 tensor 和计算不会冲突和共享**。创建新的计算图之后，可以通过 `tf.Graph.as_default()` 将其设置为当前计算图：

```python
g1 = tf.Graph()
with g1.as_default():
    # tensor and compution in computional graph g1
```

当有多个计算图时，运行 `Session` 时需要指定具体哪个计算图 `tf.Session(graph=g1)`，不然当作默认图处理

如：

```python
import tensorflow as tf

g1 = tf.Graph()
with g1.as_default():
    # 计算图中定义变量 v，并初始化为 0
    v = tf.get_variable("v", initializer=tf.zeros_initializer(shape=[1]))

g2 = tf.Graph()
with g2.as_default():
    # 计算图中定义变量 v，并初始化为 1
    v = tf.get_variable("v", initializer=tf.ones_initializer(shape=[1]))

with tf.Session(graph=g1) as sess:
    tf.initialize_all_variables().run()
    with tf.variable_scope("", reuse=True):
        print(sess.run(tf.get_variable("v"))) # [ 0.]

with tf.Session(graph=g2) as sess:
    tf.initialize_all_variables().run()
    with tf.variable_scope("", reuse=True):
        print(sess.run(tf.get_variable("v"))) # [ 1.]
```

### `tf.Graph.device`

TensorFlow 中不同的计算图不仅可以隔绝 tensor 和计算，还可以通过 `tf.Graph.device` 指定运行计算的设备，如下面的代码将计算运行在 GPU 上：

```python
import tensorflow as tf

g = tf.Graph()
a = tf.constant([1.0, 2.0], name="a")
b = tf.constant([2.0, 3.0], name="b")
with g.device('/gpu:0'):
    result = a + b
```

### `Collection`

可以通过集合 (Collection) 管理不同类别的资源：
- `tf.add_to_collection` 函数可以将资源加入一个或者多个集合中：
- `tf.get_collection` 获取一个集合里面的所有资源

TensorFlow 自动维护了一些最常用的集合：

- `tf.GraphKeys.VARIABLES` 所有变量
- `tf.GraphKeys.TRAINABLE_VARIABLES` 可训练的变量（常用在神经网络中）
- `tf.GraphKeys.SUMMARIES` 日志生成相关的 tensor
- `tf.GraphKeys.QUEUE_RUNNERS` 处理输入的 QueueRunner
- `tf.GraphKeys.MOVING_AVERAGE_VARIABLES` 所有计算了滑动平均值的变量


## 张量 (Tensor)

> 零阶张量表示标量 (scalar)，即一个数；一阶张量为向量 (vector)，即一个一维数组；n 阶张量可以理解为一个 n 维数组

**tensor 中并没有保存真正的数字，而是保存的如何得到这些数字的过程**

如，下面的代码不会得到加法的结果，而是对结果的一个引用：

```python
import tensorflow as tf

a = tf.constant([1.0, 2.0], name="a")
b = tf.constant([2.0, 3.0], name="b")
result = a + b
print(result) # Tensor("add:0", shape=(2,), dtype=float32)
```

通过 tensor 中保存的引用可以看出，主要存储了三个属性：

- `name` **TensorFlow中的计算都可以通过计算图的模型建立，而计算图的每一个节点代表了一个计算，计算的结果保存在 tensor 中，所以 tensor 和计算图上节点所代表的计算是对应的。** 这样 tensor 的命名可以表示为 `node:src_output` （上面结果中的 “add:0” 代表这是计算节点 “add” 的第一个输出）
- `shape` 即维度
- `type` 每个张量会有一个唯一的类型，运算时类型不匹配会报错，TensorFlow 支持14种类型：实数（`tf.float32`, `tf.float64`）、整数（`tf.int8`, `tf.int16`, `tf.int32`, `tf.int64`, `tf.uint8`）、布尔型（`tf.bool`）和复数（`tf.complex64`, `tf.complex128`）


## 会话 (Session)

**会话拥有并管理 TensorFlow 程序运行时的所有资源，当所有计算完成之后需要关闭会话来帮助系统回收资源，否则就可能出现资源泄漏的问题**

```python
sess = tf.Session()
# ...
sess.run(...)
# ...
sess.close()
```

也可以通过 python 的上下文管理器使用会话：

```python
with tf.Session() as sess:
    sess.run(...)
```

**TensorFlow 会生成默认的计算图，但是不会生成默认的会话，需要手动指定**

### `tf.Tensor.eval()`

默认会话被指定后，可以通过 `tf.Tensor.eval()` 函数计算一个 tensor 的取值:

```python
a = tf.constant([1.0, 2.0], name="a")
b = tf.constant([2.0, 3.0], name="b")
result = a + b
sess = tf.Session()
with sess.as_default():
    print(result.eval()) # [ 3.  5.]
```

下面的代码也具有相同的功能：

```python
sess = tf.Session()
print(sess.run(result)) # [ 3.  5.]
# 未指定默认会话的时候，使用 tf.Tensor.eval() 函数的时候就要指定会话
print(result.eval(session=sess)) # [ 3.  5.]
```

### `tf.InteractiveSession()`

**`tf.InteractiveSession()` 会自动将生成的会话注册为默认会话**，省去指定默认会话的麻烦

```python
sess = tf.InteractiveSession()
print(result.eval()) # [ 3.  5.]
sess.close()
```


## 初始化

### 生成函数

TensorFlow 随机数生成函数：

- `tf.random_normal` 正态分布
- `tf.truncated_normal` 正态分布（如果随机出来的值偏离平均值超过2个标准差，那么这个数会被重新随机）
- `tf.random_uniform` 平均分布
- `tf.random_gamma` Gamma 分布

TensorFlow 常数数生成函数：

- `tf.zeros` 产生全部为 0 的数组
- `tf.ones` 产生全部为 1 的数组
- `tf.fill` 产生一个全部为给定数字的数组
- `tf.constant` 产生一个给定值的常量

如：

```python
zeros = tf.zeros([2, 3], tf.int32)
# [[0 0 0]
#  [0 0 0]]
ones = tf.ones([2, 3], tf.int32)
# [[1 1 1]
#  [1 1 1]]
arr = tf.fill([2, 3], 2)
# [[2 2 2]
#  [2 2 2]]
constant = tf.constant([1, 2, 3]) # [1 2 3]
```

### 通过生成函数来初始化

```python
weight1 = tf.Variable(tf.random_normal([2, 3], stddev=2)) # 标准差为 2 的正态分布
bias = tf.Variable(tf.ones([3]))
```

### 通过其他变量的值来初始化

```python
weight1 = tf.Variable(tf.random_normal([2, 3], stddev=2)) # 标准差为 2 的正态分布
weight2 = tf.Variable(weight1.initialized_value())
weight3 = tf.Variable(weight2.initialized_value() * 2)
```

### `tf.Variable` & `tf.get_variable`

下面两个定义是等价的：

```python
v = tf.get_variable("v", shape=[1], initializer=tf.constant_initializer(1.0))
v = tf.Variable(tf.constant(0.1, shape=[1]), name="v")
```

其中常数初始化函数 `tf.constant_initializer` 和常数生成函数 `tf.constant` 功能上就是一致的。

变量初始化函数：

- `tf.constant_initializer`
- `tf.random_normal_initializer`
- `tf.truncated_normal_initializer`
- `tf.random_uniform_initializer`
- `tf.uniform_unit_scaling_initializer`
- `tf.zeros_initializer`
- `tf.ones_initializer`

`tf.Variable` & `tf.get_variable` 的区别：

`tf.Variable` 变量名称是一个可选函数，而 `tf.get_variable` 变量名称是一个必填的参数，`tf.get_variable` 会根据这个名字去创建或者获取变量

如果需要通过 `tf.get_variable` 获取一个已经创建的变量，需要通过 `tf.variable_scope` 函数来生成一个上下文管理器

`tf.variable_scope` 使用参数 `reuse=True` 生成上下文管理器时，这个上下文管理器内的所有 `tf.get_variable` 会直接获取已经创建的变量，如果变量不存在，会报错；如果使用参数 `reuse=None` 或 `reuse=False` 这个上下文管理器内的所有 `tf.get_variable` 会创建新的变量，如果同名变量已经存在，则会报错

### `tf.initialize_all_variables()`

**虽然在变量定义的时候给出了变量初始化的方法，但这个方法并没有被真正执行，需要通过 `tf.Tensor.initializer` 给变量赋值；通过 `tf.initialize_all_variables()` 可以初始化所有变量**

```python
w1 = tf.Variable(tf.random_normal([2, 3], stddev=1, seed=1))
w2 = tf.Variable(tf.random_normal([3, 1], stddev=1, seed=1))

x = tf.constant([[0.7, 0.3]])

a = tf.matmul(x, w1)
y = tf.matmul(a, w2)

with tf.Session() as sess:
    sess.run(w1.initializer)
    sess.run(w2.initializer)
    print(sess.run(y))
```

上面 w1, w2 的初始化过程，可以用等同于下面两行：

```python
init = tf.initialize_all_variables()
sess.run(init)
```

或者更简单：

```python
tf.initialize_all_variables().run()
```

### `tf.placeholder`

`tf.placeholder` 相当于定义了一个位置，这个位置中的数据在程序运行的时候再指定

**`placeholder` 定义时，这个位置上的数据类型是需要指定的，和其他 tensor 一样，`placeholder` 的类型也是不可以改变的**

通过 `placeholder` 初始化的变量，需要在计算的时候通过 `feed_dict` 参数制定具体取值，`feed_dict` 是一个 `dict`，在 `feed_dict` 中需要给出每个用到的 `placeholder` 的取值

```python
import tensorflow as tf

w1 = tf.Variable(tf.random_normal([2, 3], stddev=1, seed=1))
w2 = tf.Variable(tf.random_normal([3, 1], stddev=1, seed=1))

# 使用 placeholder 定义时，维度可以不指定，但是指定可以降低出错的概率
x = tf.placeholder(tf.float32, shape=(1, 2), name="input")

a = tf.matmul(x, w1)
y = tf.matmul(a, w2)

with tf.Session() as sess:
    tf.initialize_all_variables().run()
    print(sess.run(y, feed_dict={x: [[0.7, 0.9]]})) # 使用 placeholder 定义了 x，那么在 Session 运行的时候，需要通过 feed_dict 指定具体数值
```


## 优化算法

常用的优化算法：

- `tf.train.GradientDescentOptimizer`
- `tf.train.AdamOptimizer`
- `tf.train.MomentumOptimizer`


## 模型持久化

### `tf.train.Saver`

`tf.train.Saver` 可以用来保存 TensorFlow 的计算图

```python
import tensorflow as tf

v1 = tf.Variable(tf.constant(1.0, shape=[1]), name="v1")
v2 = tf.Variable(tf.constant(2.0, shape=[1]), name="v2")
result = v1 + v2

saver = tf.train.Saver()

with tf.Session() as sess:
    tf.initialize_all_variables().run()
    saver.save(sess, "./model.ckpt")
```

会生成三个文件：

- `model.ckpt` 保存了每一个变量的取值
- `model.ckpt.meta` 保存了计算图的结构
- `checkpoint` 保存了一个目录下所有的模型文件列表

恢复计算图：

```python
import tensorflow as tf

saver = tf.train.import_meta_graph('./model.ckpt')

with tf.Session() as sess:
    saver.restore(sess, './model.ckpt')
    print(sess.run(tf.get_default_graph().get_tensor_by_name("add:0")))
```
