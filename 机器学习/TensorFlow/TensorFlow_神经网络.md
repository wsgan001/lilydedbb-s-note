# TensorFlow —— 神经网络

## 激活函数

- `tf.nn.relu`
- `tf.nn.sigmoid`
- `tf.nn.tanh`

## 多层网络解决异或运算

加入隐藏层，异或问题可以得到很好的解决，如下图一个拥有四个节点的隐藏层的神经网络训练训练1000次后的结果。

可以看出隐藏层的四个节点中，每个节点都有一个角是蓝色的，这四个隐藏层节点可以被认为代表了从输入特征中抽取的更高维度的特征。

**即，深层神经网络实际上有组合特征提取的的功能**

![image](../images/NN-perceptron-xor-1.png)


## 损失函数 (loss function)

### 交叉熵

**交叉熵刻画的是两个概率分之间的距离**，而神经网络的输出不一定是一个概率分布

讲神经网络的输出变为概率分布的常用方法为：`Softmax` 回归

这个新的输出可以理解为经过神经网络的推导，一个样例为不同类别的概率分别为多大

```python
cross_entropy = -tf.reduce_mean(y_ * tf.log(tf.clip_by_value(y, 1e-10, 1.0)))
```

(其中 `y_` 代表正确结果，`y` 代表预测结果)

`tf.clip_by_value` 函数可以将一个 tensor 中的数组限制在一个范围之内，可以避免一些运算错误（如 log0），如：

```python
v = tf.constant([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
print(tf.clip_by_value(v, 2.5, 4.5).eval())
# [[ 2.5  2.5  3. ]
#  [ 4.   4.5  4.5]]
```

`tf.matmul` 和 `*` 的区别：
- `tf.matmul` 为矩阵乘法
- `*` 是元素直接相乘

```python
v = tf.constant([[1.0, 2.0], [3.0, 4.0]])
u = tf.constant([[1.0, 2.0], [3.0, 4.0]])
print(tf.matmul(v, u).eval())
# [[  7.  10.]
#  [ 15.  22.]]
print((u * v).eval())
# [[  1.   4.]
#  [  9.  16.]]
```

### `tf.nn.softmax_cross_entropy_with_logits(y, y_)`

由于交叉熵经常与 `Softmax` 回归一起使用，故 TensorFlow 提供了 `tf.nn.softmax_cross_entropy_with_logits()` 方法

### 均方误差 (MSE: Mean Squared Error)

```python
mse = tf.reduce_mean(tf.square(y_ - y))
```

### 自定义损失函数

如：

```python
loss = tf.reduce_sum(tf.select(tf.greater(v1, v2), (v1 - v2) * a, (v2 - v1) * b))
```

`tf.greater` 和 `tf.select` 的使用如下：

```python
v = tf.constant([1.0, 2.0, 3.0, 4.0])
u = tf.constant([4.0, 3.0, 2.0, 1.0])
print(tf.greater(v, u).eval()) # [False False  True  True]
print(tf.select(tf.greater(v, u), v, u).eval()) # [ 4.  3.  3.  4.]
```


## 神经网络优化算法

```python
train_step = tf.train.AdamOptimizer(learn_rate).minimize(loss_function)
```

### 学习率的设置

学习率过大，可能导致震荡，无法收敛；学习率过小，则会减低优化的速度

指数衰减法：


```python
decay_learning_rate = tf.train.exponential_decay(learning_rate, global_step=global_step, decay_steps, decay_rate, staircase=True)
```

大致完成了下述运算：

```python
decay_learning_rate = learning_rate * decay_rate ^ (global_step / decay_steps)
```

- `learning_rate` 为初始设置的学习率
- `decay_rate` 为衰减系数
- `global_step` 为当前训练的步数
- `decay_steps` 为衰减速度

`tf.train.exponential_decay` 函数中 `staircase` 参数默认为 `False`，`staircase=True` 时，`global_step / decay_steps` 会被取整


## 过拟合问题 (overfitting)

### dropout

`tf.nn.dropout(tf.Variable, keep_prob)`

```python
# 使用 dropout 方法减轻过拟合
keep_prob = tf.placeholder(tf.float32)
h_fc1_drop = tf.nn.dropout(h_fc1, keep_prob)
```

### 正则化 (regularization)

下面给出了一个带L2正则化的损失函数定义：

```python
loss = tf.reduce_mean(tf.square(y_ - y)) +
    tf.contrib.layers.l2_regularizer(lambda)(w)
```

`lambda` 表示正则化的权重

下面拿给出了通过集合计算一个5层神经网络带L2正则化损失函数的计算方法：

```python
import tensorflow as tf

def get_weight(shape, _lambda):
    weights = tf.Variable(tf.random_normal(shape), dtype=tf.float32)
    # tf.add_to_collection 将 weights 的L2正则化损失项加入 'losses' 集合
    tf.add_to_collection('losses', tf.contrib.layers.l2_regularizer(_lambda)(weights))
    return weights

x = tf.placeholder(tf.float32, shape=(None, 2))
y_ = tf.placeholder(tf.float32, shape=(None, 1))
batch_size = 8

# 每一层隐含层的节点个数
layer_dimension = [2, 10, 10, 10, 1]
# 隐含层数
n_layers = len(layer_dimension)

cur_layer = x
in_dimension = layer_dimension[0]

for i in range(1, n_layers):
    out_dimension = layer_dimension[i]
    weight = get_weight([in_dimension, out_dimension], 0.001)
    bias = tf.Variable(tf.constant(0.1, shape=[out_dimension]))
    cur_layer = tf.nn.relu(tf.matmul(cur_layer, weight) + bias)
    in_dimension = out_dimension

mse_loss = tf.reduce_sum(tf.square(y_ - cur_layer))

# 将均方误差损失函数加入 'losses' 集合
tf.add_to_collection('losses', mse_loss)

# get_collection 返回一个列表，这个列表是所有这个集合中的元素
# 这些元素就是损失函数的不同部分，将它们加起来就可以得到最终的损失函数
loss = tf.add_n(tf.get_collection('losses'))
```

## 滑动平均模型

TensorFlow 提供了 `tf.train.ExponentialMovingAverage` 来实现滑动平均模型

```python
tf.train.ExponentialMovingAverage(decay, num_updates)
```

`tf.train.ExponentialMovingAverage` 会维护一个影子变量 `shadow_variable`，影子变量的初始值为相应变量的初始值，每次运行变量更新时，应自变量的值会更新为：

```
shadow_variable = decay * shadow_vaariable + (1 - decay) * variable
```

其中 `decay` 一般会设置为非常接近 1 的数（如 0.999 或 0.9999）

为了使得模型在训练前期可以更新的更快，`tf.train.ExponentialMovingAverage` 还提供了 `num_updates` 参数来动态设置 `decay` :

```
decay = min{ decay, (1 + num_updates) / (10 + num_updates) }
```

示例：

```python
import tensorflow as tf

v1 = tf.Variable(0, dtype=tf.float32)
# 这里 step 模拟神经网络中的训练次数，可用于动态控制衰减率
step = tf.Variable(0, trainable=True)

ema = tf.train.ExponentialMovingAverage(0.99, step)
# 这里需要给定一个列表，每次执行这个操作时，这个列表中的变量都会被更行
maintain_average_op = ema.apply([v1])

with tf.Session() as sess:
    tf.initialize_all_variables().run()
    print(sess.run([v1, ema.average(v1)])) # [0.0, 0.0]

    sess.run(tf.assign(v1, 5))
    sess.run(maintain_average_op)
    # decay = min{ 0.99, (1 + step) / (10 + step) = 0.1 } = 0.1
    # v1 = 0.1 * 0 + 0.9 * 5 = 4.5
    print(sess.run([v1, ema.average(v1)])) # [5.0, 4.5]

    sess.run(tf.assign(step, 10000))
    sess.run(tf.assign(v1, 10))
    sess.run(maintain_average_op)
    # decay = min{ 0.99, (1 + step) / (10 + step) = 0.999 } = 0.99
    # v1 = 0.99 * 4.5 + 0.01 * 10 = 4.5549998
    print(sess.run([v1, ema.average(v1)])) # [10.0, 4.5549998]

    sess.run(maintain_average_op)
    # decay = 0.99
    # v1 = 0.99 * 4.5549998 + 0.01 * 10 = 4.6094499
    print(sess.run([v1, ema.average(v1)])) # [10.0, 4.6094499]
```