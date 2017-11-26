# TensorFlow —— CNN


## 卷积层

### `tf.nn.conv2d`

```
tf.nn.conv2d(input, filter, strides, padding)
```

- `input` 为当前层的节点矩阵。注意这个矩阵是四维的，第一位代表输入batch，后面三个维度对应一个节点矩阵（如：`images[0,:,:,:]` 表示第一张图片，`images[0,:,:,:]` 表示第二张图片
- `filter` 为卷积层的权重
- `strides` 为步长，是一个长度为 4 的数组，但是第一个数和最后一个数都要求为 1，第二、三个参数为横向和竖向的步长
- `padding` 为边界处理方法，有 `SAME`、`VALID` 两种选择

如：

```python
filter_weight = tf.get_variable('weights', [5, 5, 3, 16],
                                initializer=tf.truncated_normal(stddev=0.1))
biases = tf.get_variable('biases', [16], initializer=tf.constant_initializer(0.1))
conv = tf.conv2d(input, filter_weight, strides=[1, 1, 1, 1], padding='SAME')
# 注意这里不能使用简单的加法，因为矩阵不同位置上的节点都需要加上同样的偏置项
bias = tf.nn.bias_add(conv, biases)
actived_conv = tf.nn.relu(bias)
```


## 池化层

池化层可以非常有效的减小矩阵的尺寸，从而减小最后全联接层中的参数，使用池化层既可以加快计算速度，也可以有效防止过拟合问题

### `tf.nn.max_pool`

```python
tf.nn.max_pool(value, ksize, strides, padding)
```
- `input` 为当前层的节点矩阵。注意这个矩阵是四维的，第一位代表输入batch，后面三个维度对应一个节点矩阵（如：`images[0,:,:,:]` 表示第一张图片，`images[0,:,:,:]` 表示第二张图片
- `ksize` 为过滤器的尺寸，是一个长度为 4 的数组，但是第一个数和最后一个数都要求为 1（常用的尺寸有 `[1, 2, 2, 1]` 或 `[1, 3, 3, 1]`
- `strides` 为步长，是一个长度为 4 的数组，但是第一个数和最后一个数也只能为 1
- `padding` 为边界处理方法，有 `SAME`、`VALID` 两种选择

如：

```python
pool = tf.nn.max_pool(actived_conv, ksize=[1, 3, 3, 1],
                      strides=[1, 2, 2, 1], padding='SAME')
```


---


(基于 MNIST 数据集)

首先倒入数据：

```python
import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data

mnist = input_data.read_data_sets('MNIST_DATA/', one_hot=True)
sess = tf.InteractiveSession()
```

然后创建初始化权重与偏置的函数：

```python
def weight_initialize(shape):
    initial = tf.truncated_normal(shape, stddev=0.1) # 截断的正态分布噪声，标准差为0.1
    return tf.Variable(initial)

def bias_initialize(shape):
    initial = tf.constant(0.1, shape=shape)
    return tf.Variable(initial)
```

然后创建2d卷积与池化函数：

```python
def conv2d(x, W):
    return tf.nn.conv2d(x, W, strides=[1, 1, 1, 1], padding='SAME') # 水平、竖直步长为1，边缘处理方式为 'SAME'

def max_pool_2x2(x):
    return tf.nn.max_pool(x, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME') # 2x2 降为 1x1，边缘处理方式为 'SAME'
```

接下来定义两个卷积层：

```python
# 第一个卷积层
W_conv1 = weight_initialize([5, 5, 1, 32]) # 5x5 的卷积核，1 个颜色通道，32 个不同的卷积核
b_conv1 = bias_initialize([32])
h_conv1 = tf.nn.relu(conv2d(x_image, W_conv1) + b_conv1) # 使用 ReLU 激活函数进行非线性处理
h_pool1 = max_pool_2x2(h_conv1) # 2x2 最大池化

# 第二个卷积层
W_conv2 = weight_initialize([5, 5, 32, 64])
b_conv2 = bias_initialize([64])
h_conv2 = tf.nn.relu(conv2d(h_pool1, W_conv2) + b_conv2)
h_pool2 = max_pool_2x2(h_conv2)
```

然后建立一个全联接层：

```python
W_fc1 = weight_initialize([7 * 7 * 64, 1024])
b_fc1 = bias_initialize([1024])
# 经过两次池化，图片已经从 28x28 变成了 7x7，第二层卷积核数量为64，所以输出尺寸为 7x7x64，然后这里将其转变为一维的
h_pool2_flat = tf.reshape(h_pool2, [-1, 7 * 7 * 64])
h_fc1 = tf.nn.relu(tf.matmul(h_pool2_flat, W_fc1) + b_fc1)
```

使用 dropout 方法减轻过拟合：

```python
keep_prob = tf.placeholder(tf.float32)
h_fc1_drop = tf.nn.dropout(h_fc1, keep_prob)
```

将 dropout 层输出连接一个 softmax 层：

```python
W_fc2 = weight_initialize([1024, 10])
b_fc2 = bias_initialize([10])
y_conv = tf.nn.softmax(tf.matmul(h_fc1_drop, W_fc2) + b_fc2)
```

最后就是训练：

```python
cross_entropy = tf.reduce_mean(-tf.reduce_sum(y_ * tf.log(y_conv), reduction_indices=[1]))
train_step = tf.train.AdamOptimizer(1e-4).minimize(cross_entropy)
correct_prediction = tf.equal(tf.argmax(y_conv, 1), tf.argmax(y_, 1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
tf.initialize_all_variables().run()
for i in range(20000):
    batch = mnist.train.next_batch(50)
    if i % 100 == 0:
        train_accuracy = accuracy.eval(feed_dict={x: batch[0], y_: batch[1], keep_prob: 1.0})
        print("step %d, training accuracy %g" % (i, train_accuracy))
    train_step.run(feed_dict={x: batch[0], y_: batch[1], keep_prob: 0.5})
```

源码（参考 [Deep MNIST for Experts](https://www.tensorflow.org/get_started/mnist/pros) 实现）：

```python
import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data

def weight_initialize(shape):
    initial = tf.truncated_normal(shape, stddev=0.1) # 截断的正态分布噪声，标准差为0.1
    return tf.Variable(initial)

def bias_initialize(shape):
    initial = tf.constant(0.1, shape=shape)
    return tf.Variable(initial)

def conv2d(x, W):
    return tf.nn.conv2d(x, W, strides=[1, 1, 1, 1], padding='SAME') # 水平、竖直步长为1，边缘处理方式为 'SAME'

def max_pool_2x2(x):
    return tf.nn.max_pool(x, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME') # 2x2 降为 1x1，边缘处理方式为 'SAME'

if __name__ == '__main__':

    mnist = input_data.read_data_sets('MNIST_DATA/', one_hot=True)

    sess = tf.InteractiveSession()
    x = tf.placeholder(tf.float32, [None, 784])
    y_ = tf.placeholder(tf.float32, [None, 10])
    x_image = tf.reshape(x, [-1, 28, 28, 1]) # -1 代表样本数量不固定，1x784 转为 24x24，1 个颜色通道（因为是黑白图像）

    # 第一个卷积层
    W_conv1 = weight_initialize([5, 5, 1, 32]) # 5x5 的卷积核，1 个颜色通道，32 个不同的卷积核
    b_conv1 = bias_initialize([32])
    h_conv1 = tf.nn.relu(conv2d(x_image, W_conv1) + b_conv1) # 使用 ReLU 激活函数进行非线性处理
    h_pool1 = max_pool_2x2(h_conv1) # 2x2 最大池化

    # 第二个卷积层
    W_conv2 = weight_initialize([5, 5, 32, 64])
    b_conv2 = bias_initialize([64])
    h_conv2 = tf.nn.relu(conv2d(h_pool1, W_conv2) + b_conv2)
    h_pool2 = max_pool_2x2(h_conv2)

    W_fc1 = weight_initialize([7 * 7 * 64, 1024])
    b_fc1 = bias_initialize([1024])
    # 经过两次池化，图片已经从 28x28 变成了 7x7，第二层卷积核数量为64，所以输出尺寸为 7x7x64，然后这里将其转变为一维的
    h_pool2_flat = tf.reshape(h_pool2, [-1, 7 * 7 * 64])
    h_fc1 = tf.nn.relu(tf.matmul(h_pool2_flat, W_fc1) + b_fc1)

    # 使用 dropout 方法减轻过拟合
    keep_prob = tf.placeholder(tf.float32)
    h_fc1_drop = tf.nn.dropout(h_fc1, keep_prob)

    # 将 dropout 层输出连接一个 softmax 层
    W_fc2 = weight_initialize([1024, 10])
    b_fc2 = bias_initialize([10])
    y_conv = tf.nn.softmax(tf.matmul(h_fc1_drop, W_fc2) + b_fc2)

    cross_entropy = tf.reduce_mean(-tf.reduce_sum(y_ * tf.log(y_conv), reduction_indices=[1]))
    train_step = tf.train.AdamOptimizer(1e-4).minimize(cross_entropy)
    correct_prediction = tf.equal(tf.argmax(y_conv, 1), tf.argmax(y_, 1))
    accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
    tf.initialize_all_variables().run()
    for i in range(20000):
        batch = mnist.train.next_batch(50)
        if i % 100 == 0:
            train_accuracy = accuracy.eval(feed_dict={x: batch[0], y_: batch[1], keep_prob: 1.0})
            print("step %d, training accuracy %g" % (i, train_accuracy))
        train_step.run(feed_dict={x: batch[0], y_: batch[1], keep_prob: 0.5})
```