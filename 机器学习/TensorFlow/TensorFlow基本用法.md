# TensorFlow

**TensorFlow:**

- 使用 `图 (graph)` 来表示计算任务.
- 在被称之为 `会话 (Session)` 的 `上下文 (context)` 中执行图.
- 使用 `tensor` 表示数据.
- 通过 `变量 (Variable)` 维护状态.
- 使用 `feed` 和 `fetch` 可以为任意的操作(arbitrary operation) 赋值或者从其中获取数据


## Tensor和Session

TensorFlow里面的变量都以tensor的形式保存，可以调用session来获取tensor的取值

```python
import tensorflow as tf

node1 = tf.constant(3.0, tf.float32)
node2 = tf.constant(4.0) # also tf.float32 implicitly
print(node1, node2)
```

```
# output
Tensor("Const:0", shape=(), dtype=float32) Tensor("Const_1:0", shape=(), dtype=float32)
```

注意上面的程序并不是直接打印出 `3.0` 和 `4.0`，而是一个计算图的结点，如果想要取得这些结点中的值，就需要运行一个会话 (`Session`):

```python
sess = tf.Session()
print(sess.run([node1, node2]))
```

```
# output
[3.0, 4.0]
```

一个节点相加运算的例子：

```python
import tensorflow as tf
a = tf.constant([1.0, 2.0], name="a")
b = tf.constant([2.0, 3.0], name="b")
result = a + b # 等同于 result = tf.add(a, b)
print(result)

with tf.Session() as sess:
    print(sess.run(result))
```

```
# output
Tensor("add:0", shape=(2,), dtype=float32)
[ 3.  5.]
```

可以使用 `tf.placeholder` 去接受外部的输入：

```python
import tensorflow as tf

a = tf.placeholder(tf.float64)
b = tf.placeholder(tf.float64)
result = tf.add(a, b)

with tf.Session() as sess:
    print(sess.run(result, {a: 3, b: 4}))
```

```
# output
7.0
```

`tf.constant` 声明的变量初始化之后就不可改变了，如果需要可训练的数据，就需要使用 `tf.Variable()` 声明：

> To make the model trainable, we need to be able to modify the graph to get new outputs with the same input. **Variables** allow us to add trainable parameters to a graph.
>
> **Constants** are initialized when you call tf.constant, and their value can never change. By contrast, variables are not initialized when you call `tf.Variable`.

```python
W = tf.Variable([.3], tf.float32)
b = tf.Variable([-.3], tf.float32)
x = tf.placeholder(tf.float32)
linear_model = W * x + b
```

注意：`tf.Variable` 声明的变量，并不会在声明的时候被初始化，而是需要调用 `tf.global_variables_initializer()`（老版本的 `tensorflow` 需要调用 `tf.initialize_all_variables()` 方法） 方法，去初始化所有变量：

```python
init = tf.global_variables_initializer()
sess.run(init)
```

可以用 `tf.assign` 改变 `tf.Variable` 声明的变量：

> A variable is initialized to the value provided to `tf.Variable` but can be changed using operations like `tf.assign`


## tf.train API

一个经典的梯度下降(Gradient Descent)算法的例子：

```python
optimizer = tf.train.GradientDescentOptimizer(0.01)
train = optimizer.minimize(loss)
```

```python
sess.run(init) # reset values to incorrect defaults.
for i in range(1000):
  sess.run(train, {x:[1,2,3,4], y:[0,-1,-2,-3]})

print(sess.run([W, b]))
```

```
# output
[array([-0.9999969], dtype=float32), array([ 0.99999082],
 dtype=float32)]
```

一个简单线性回归程序(linear regression program)的例子：

```python
import numpy as np
import tensorflow as tf

# Model parameters
W = tf.Variable([.3], tf.float32)
b = tf.Variable([-.3], tf.float32)
# Model input and output
x = tf.placeholder(tf.float32)
linear_model = W * x + b
y = tf.placeholder(tf.float32)

# loss
loss = tf.reduce_sum(tf.square(linear_model - y)) # sum of the squares
# optimizer
optimizer = tf.train.GradientDescentOptimizer(0.01)
train = optimizer.minimize(loss)

# training data
x_train = [1, 2, 3, 4]
y_train = [0, -1, -2, -3]

# training loop
# init = tf.global_variables_initializer()
init = tf.initialize_all_variables()
sess = tf.Session()
sess.run(init) # reset values to wrong
for i in range(1000):
  sess.run(train, { x: x_train, y: y_train })

# evaluate training accuracy
cur_W, cur_b, cur_loss = sess.run([W, b, loss], { x: x_train, y: y_train })
print("W: %s b: %s loss: %s" % (cur_W, cur_b, cur_loss))
```

```
# output
W: [-0.9999969] b: [ 0.99999082] loss: 5.69997e-11
```

Another Simple Example:

```python
import tensorflow as tf
import numpy as np

# 使用 NumPy 生成假数据(phony data), 总共 100 个点.
x_data = np.float32(np.random.rand(2, 100)) # 随机输入
y_data = np.dot([0.100, 0.200], x_data) + 0.300

# 构造一个线性模型
#
b = tf.Variable(tf.zeros([1]))
W = tf.Variable(tf.random_uniform([1, 2], -1.0, 1.0))
y = tf.matmul(W, x_data) + b

# 最小化方差
loss = tf.reduce_mean(tf.square(y - y_data))
optimizer = tf.train.GradientDescentOptimizer(0.5)
train = optimizer.minimize(loss)

# 初始化变量
init = tf.initialize_all_variables()

# 启动图 (graph)
sess = tf.Session()
sess.run(init)

# 拟合平面
for step in range(0, 201):
    sess.run(train)
    if step % 20 == 0:
        print (step, sess.run(W), sess.run(b))
```

```
# output
0 [[-0.30208415  0.56242359]] [ 0.75679231]
20 [[-0.03383956  0.19812873]] [ 0.37465447]
40 [[ 0.06100797  0.18434684]] [ 0.3295207]
60 [[ 0.08691502  0.19136578]] [ 0.31164601]
80 [[ 0.09522276  0.19619071]] [ 0.30458987]
100 [[ 0.09818085  0.1984321 ]] [ 0.30180818]
120 [[ 0.09929388  0.19937134]] [ 0.30071217]
140 [[ 0.09972362  0.19975057]] [ 0.30028048]
160 [[ 0.09989143  0.19990145]] [ 0.30011049]
180 [[ 0.09995729  0.19996114]] [ 0.30004352]
200 [[ 0.09998319  0.1999847 ]] [ 0.30001712]
```


## tf.contrib.learn

> `tf.contrib.learn` is a high-level TensorFlow library that simplifies the mechanics of machine learning, including the following:
>
> - running training loops
> - running evaluation loops
> - managing data sets
> - managing feeding
>
> `tf.contrib.learn` defines many common models

Notice how much simpler the linear regression program becomes with `tf.contrib.learn`:
```python
import numpy as np
import tensorflow as tf

# Declare list of features. We only have one real-valued feature. There are many
# other types of columns that are more complicated and useful.
features = [tf.contrib.layers.real_valued_column("x", dimension=1)]
# An estimator is the front end to invoke training (fitting) and evaluation
# (inference). There are many predefined types like linear regression,
# logistic regression, linear classification, logistic classification, and
# many neural network classifiers and regressors. The following code
# provides an estimator that does linear regression.
estimator = tf.contrib.learn.LinearRegression(feature_columns=features)
# TensorFlow provides many helper methods to read and set up data sets.
# Here we use `numpy_input_fn`. We have to tell the function how many batches
# of data (num_epochs) we want and how big each batch should be.
x = np.array([1., 2., 3., 4.])
y = np.array([0., -1., -2., -3.])
input_fn = tf.contrib.learn.io.numpy_input_fn({"x": x}, y, batch_size=4, num_epochs=1000)
# We can invoke 1000 training steps by invoking the `fit` method and passing the
# training data set.
estimator.fit(input_fn=input_fn, steps=1000)
# Here we evaluate how well our model did. In a real example, we would want
# to use a separate validation and testing data set to avoid overfitting.
estimator.evaluate(input_fn=input_fn)
```


### 构建图

构建图的第一步, 是创建源 `op` (`source op`). 源 `op` 不需要任何输入, 例如 `常量 (Constant)`. 源 `op` 的输出被传递给其它 `op` 做运算.

Python 库中, `op` 构造器的返回值代表被构造出的 `op` 的输出, 这些返回值可以传递给其它 `op` 构造器作为输入.

TensorFlow Python 库有一个`默认图 (default graph)`, `op` 构造器可以为其增加节点

```python
import tensorflow as tf

# 创建两个个常量 op, 产生一个 1x2 和一个 2x1 矩阵. 这个 op 被作为一个节点加到默认图中
# 构造器的返回值代表该常量 op 的返回值
matrix1 = tf.constant([[3., 3.]])
matrix2 = tf.constant([[2.], [2.]])

# 创建一个矩阵乘法 matmul op , 把 'matrix1' 和 'matrix2' 作为输入
# 返回值 'product' 代表矩阵乘法的结果
product = tf.matmul(matrix1, matrix2)

# 启动默认图
session = tf.Session()
# 调用 sess 的 'run()' 方法来执行矩阵乘法 op, 传入 'product' 作为该方法的参数
# 函数调用 'run(product)' 触发了图中三个 op (两个常量 op 和一个矩阵乘法 op) 的执行
result = session.run(product)
# 返回值 'result' 是一个 numpy `ndarray` 对象
print(result)
# 任务完成, 关闭会话
session.close()
```