# TensorFlow —— CNN (进阶)

（基于 CIFAR-10 数据集）

首先下载 CIFAR-10 数据集：

```
$ git clone https://github.com/tensorflow/models.git
```

引入必要的库，以及定义一些变量：

```python
import cifar10, cifar10_input
import tensorflow as tf
import numpy as np
import time

max_step = 3000 # 训练轮数
batch_size = 128
data_dir = '/Users/dbb/desktop/my-github/Demos_of_Python/Demos_tensorflow/models/tutorials/image/cifar10'
```

给 `weight` 加一个 `L2` 的 `loss`（相当于做了一个 `L2正则化` ）:
（一般，`L1 regularization` 会制造稀疏特征，大部分无用特征的权重会被置为0；`L2 regularization` 会让特征的权重不过大，使得特征的权重比较平均）

```python
def variable_with_weight_loss(shape, stddev, w1):
    var = tf.Variable(tf.truncated_normal(shape, stddev=stddev)) # 使用 截断正态分布 初始化权重
    if w1 is not True:
        weight_loss = tf.multiply(tf.nn.l2_loss(var), w1, name='weight_loss')
        tf.add_to_collection('losses', weight_loss)
    return var
```

使用 `cifar10` 类下载数据集，并解压、展开到指定位置：

```python
cifar10.maybe_download_and_extract()
```

产生训练和测试数据:

- `cifar10_input.distorted_inputs` 产生训练所需要的数据，包括特征及其对应的 label，该函数已经进行了数剧增强（Data Augmentation），包括：随机的水平翻转 `tf.image.random_flip_left_right`、随即剪切一块 24x24 大小的图片 `tf.random_crop`、设置随机的亮度和对比度 `tf.image.random_brightness`, `tf.image.random_contrast`、对数据进行标准化 `tf.image.per_image_whitening`
- `cifar10_input.inputs` 生成测试数据，不需要想生成训练数据一样做太多处理

```python
# 产生训练和测试数据
images_train, labels_train = cifar10_input.distorted_inputs(data_dir=data_dir, batch_size=batch_size)
images_test, labels_test = cifar10_input.inputs(eval_data=True, data_dir=data_dir, batch_size=batch_size)
```

创建输入数据的placeholder：

```python
# cifar10_input.distorted_inputs 随即剪切一块 24x24 大小的图片，颜色通道数为 3（因为是彩色）
image_holder = tf.placeholder(tf.float32, [batch_size, 24, 24, 3])
label_holder = tf.placeholder(tf.int32, [batch_size])
```

第一个卷积层：

池化层之后使用 `LRN` 对结果进行处理，对局部神经元的活动创建竞争环境，使得其中相应比较大的值变得更大，并抑制其他反馈较小的神经元

```python
# 第一个卷积层
# 不对第一个卷积层的 weight1 进行 L2 的正则，所以 wl=0.0
weight1 = variable_with_weight_loss(shape=[5, 5, 3, 64], stddev=5e-2, wl=0.0) # 5x5 大小，3 颜色通道，64 个卷积核
kernal1 = tf.nn.conv2d(image_holder, weight1, [1, 1, 1, 1], padding='SAME')
bias1 = tf.Variable(tf.constant(0.0, shape=[64]))
conv1 = tf.nn.relu(tf.nn.bias_add(kernal1, bias1))
pool1 = tf.nn.max_pool(conv1, 4, ksize=[1, 3, 3, 1], strides=[1, 2, 2, 1], padding='SAME')
# tf.nn.lrn 最后使用 LRN 对结果进行处理
norm1 = tf.nn.lrn(pool1, bias=1.0, alpha=0.001 / 9.0, beta=0.75)
```

第二个卷积层:

```python
# 第二个卷积层
weight2 = variable_with_weight_loss(shape=[5, 5, 64, 64], stddev=5e-2, wl=0.0) # 5x5 大小，64 通道，64 个卷积核
kernal2 = tf.nn.conv2d(norm1, weight2, [1, 1, 1, 1], padding='SAME')
bias2 = tf.Variable(tf.constant(0.1, shape=[64])) # 与第一层卷积层不同，这里全部初始化为 0.1，而不是 0.0
conv2 = tf.nn.relu(tf.nn.bias_add(kernal2, bias2))
# 与第一个卷积层不同，调换了 LRN层和池化层的顺序
norm2 = tf.nn.lrn(conv2, bias=1.0, alpha=0.001 / 9.0, beta=0.75)
pool2 = tf.nn.max_pool(norm2, 4, ksize=[1, 3, 3, 1], strides=[1, 2, 2, 1], padding='SAME')
```

全连接层:

```python
# 全连接层
reshape = tf.reshape(pool2, [batch_size, -1]) # 把每个样本展开成一维
dim = reshape.get_shape()[1].value
weight3 = variable_with_weight_loss(shape=[dim, 384], stddev=0.04, w1=0.004) # 隐含层节点数为384，正态分布标准差为 0.04
bias3 = tf.Variable(tf.constant(0.1, shape=[384]))
local3 = tf.nn.relu(tf.matmul(reshape, weight3) + bias3)

# 第二个全连接层，和第一个卷积层一样，只不过隐含节点数下降了一半
weight4 = variable_with_weight_loss(shape=[384, 192], stddev=0.04, w1=0.04)
bias4 = tf.Variable(tf.constant(0.1, shape=[192]))
local4 = tf.nn.relu(tf.matmul(local3, weight4) + bias4)
```

最后一层：

```python
# 最后一层
weight5 = variable_with_weight_loss(shape=[192, 10], stddev=1 / 192.0, wl=0.0)
bias5 = tf.Variable(tf.constant(0.0, shape=[10]))
logits = tf.add(tf.matmul(local4, weight5), bias5)
```

计算 loss:

```python
def loss(logits, labels):
    labels = tf.cast(labels, tf.int64)
    cross_entropy = tf.nn._sparse_softmax_cross_entropy_with_logits(
        logits=logits, labels=labels, name='cross_entropy_per_example'
    )
    cross_entropy_mean = tf.reduce_mean(cross_entropy, name='cross_entropy')
    tf.add_to_collection('losses', cross_entropy_mean)
    return tf.add_n(tf.get_collection('losses'), name='total_loss')
```

训练模型：

(其中使用了 `tf.nn.in_top_k` 计算输出结果中 `top k` 的准确率)

```python
loss = loss(logits, label_holder)
train_op = tf.train.AdamOptimizer(1e-3).minimize(loss)
# 使用 tf.nn.in_top_k 计算输出结果中 top k 的准确率，默认使用 top 1，也就是输出分数最高的那一类的准确率
top_k_op = tf.nn.in_top_k(logits, label_holder, 1)
```

创建 session：

```python
sess = tf.InteractiveSession()
tf.initialize_all_variables().run()
```

启动图片数据增强的线程队列，这里一共使用了16个线程来进行加速：

```python
# 启动图片数据增强的线程队列
tf.train.start_queue_runners()
```

开始训练：

```python
for step in range(max_step):
    start_time = time.time()
    image_batch, labels_batch = sess.run([images_train, labels_train])
    _, loss_value = sess.run([train_op, loss], feed_dict={image_holder: image_batch, label_holder: labels_batch})
    duration = time.time() - start_time
    if step % 10 == 0:
        examples_per_sec = batch_size / duration
        sec_per_batch = float(duration)
        format_str = ('step %d, loss = %.2f  (%.1f examples/sec; %.3f sec/batch)')
        print(format_str % (step, loss_value, examples_per_sec, sec_per_batch))
```

完整源码（参考《TensorFlow实现》）：

```python
import cifar10, cifar10_input
import tensorflow as tf
import numpy as np
import time

max_step = 3000 # 训练轮数
batch_size = 128
data_dir = '/Users/dbb/desktop/my-github/Demos_of_Python/Demos_tensorflow/models/tutorials/image/cifar10'

def variable_with_weight_loss(shape, stddev, w1):
    var = tf.Variable(tf.truncated_normal(shape, stddev=stddev)) # 使用 截断正态分布 初始化权重
    if w1 is not True:
        weight_loss = tf.multiply(tf.nn.l2_loss(var), w1, name='weight_loss')
        tf.add_to_collection('losses', weight_loss)
    return var

cifar10.maybe_download_and_extract()

# 产生训练和测试数据
images_train, labels_train = cifar10_input.distorted_inputs(data_dir=data_dir, batch_size=batch_size)
images_test, labels_test = cifar10_input.inputs(eval_data=True, data_dir=data_dir, batch_size=batch_size)

# cifar10_input.distorted_inputs 随即剪切一块 24x24 大小的图片，颜色通道数为 3（因为是彩色）
image_holder = tf.placeholder(tf.float32, [batch_size, 24, 24, 3])
label_holder = tf.placeholder(tf.int32, [batch_size])

# 第一个卷积层
# 不对第一个卷积层的 weight1 进行 L2 的正则，所以 wl=0.0
weight1 = variable_with_weight_loss(shape=[5, 5, 3, 64], stddev=5e-2, wl=0.0) # 5x5 大小，3 颜色通道，64 个卷积核
kernal1 = tf.nn.conv2d(image_holder, weight1, [1, 1, 1, 1], padding='SAME')
bias1 = tf.Variable(tf.constant(0.0, shape=[64]))
conv1 = tf.nn.relu(tf.nn.bias_add(kernal1, bias1))
pool1 = tf.nn.max_pool(conv1, 4, ksize=[1, 3, 3, 1], strides=[1, 2, 2, 1], padding='SAME')
# tf.nn.lrn 最后使用 LRN 对结果进行处理
norm1 = tf.nn.lrn(pool1, bias=1.0, alpha=0.001 / 9.0, beta=0.75)

# 第二个卷积层
weight2 = variable_with_weight_loss(shape=[5, 5, 64, 64], stddev=5e-2, wl=0.0) # 5x5 大小，64 通道，64 个卷积核
kernal2 = tf.nn.conv2d(norm1, weight2, [1, 1, 1, 1], padding='SAME')
bias2 = tf.Variable(tf.constant(0.1, shape=[64])) # 与第一层卷积层不同，这里全部初始化为 0.1，而不是 0.0
conv2 = tf.nn.relu(tf.nn.bias_add(kernal2, bias2))
# 与第一个卷积层不同，调换了 LRN层和池化层的顺序
norm2 = tf.nn.lrn(conv2, bias=1.0, alpha=0.001 / 9.0, beta=0.75)
pool2 = tf.nn.max_pool(norm2, 4, ksize=[1, 3, 3, 1], strides=[1, 2, 2, 1], padding='SAME')

# 全连接层
reshape = tf.reshape(pool2, [batch_size, -1]) # 把每个样本展开成一维
dim = reshape.get_shape()[1].value
weight3 = variable_with_weight_loss(shape=[dim, 384], stddev=0.04, w1=0.004) # 隐含层节点数为384，正态分布标准差为 0.04
bias3 = tf.Variable(tf.constant(0.1, shape=[384]))
local3 = tf.nn.relu(tf.matmul(reshape, weight3) + bias3)

# 第二个全连接层，和第一个卷积层一样，只不过隐含节点数下降了一半
weight4 = variable_with_weight_loss(shape=[384, 192], stddev=0.04, w1=0.04)
bias4 = tf.Variable(tf.constant(0.1, shape=[192]))
local4 = tf.nn.relu(tf.matmul(local3, weight4) + bias4)

# 最后一层
weight5 = variable_with_weight_loss(shape=[192, 10], stddev=1 / 192.0, wl=0.0)
bias5 = tf.Variable(tf.constant(0.0, shape=[10]))
logits = tf.add(tf.matmul(local4, weight5), bias5)

def loss(logits, labels):
    labels = tf.cast(labels, tf.int64)
    cross_entropy = tf.nn._sparse_softmax_cross_entropy_with_logits(
        logits=logits, labels=labels, name='cross_entropy_per_example'
    )
    cross_entropy_mean = tf.reduce_mean(cross_entropy, name='cross_entropy')
    tf.add_to_collection('losses', cross_entropy_mean)
    return tf.add_n(tf.get_collection('losses'), name='total_loss')

loss = loss(logits, label_holder)
train_op = tf.train.AdamOptimizer(1e-3).minimize(loss)
# 使用 tf.nn.in_top_k 计算输出结果中 top k 的准确率，默认使用 top 1，也就是输出分数最高的那一类的准确率
top_k_op = tf.nn.in_top_k(logits, label_holder, 1)

sess = tf.InteractiveSession()
tf.initialize_all_variables().run()

# 启动图片数据增强的线程队列
tf.train.start_queue_runners()

for step in range(max_step):
    start_time = time.time()
    image_batch, labels_batch = sess.run([images_train, labels_train])
    _, loss_value = sess.run([train_op, loss], feed_dict={image_holder: image_batch, label_holder: labels_batch})
    duration = time.time() - start_time
    if step % 10 == 0:
        examples_per_sec = batch_size / duration
        sec_per_batch = float(duration)
        format_str = ('step %d, loss = %.2f  (%.1f examples/sec; %.3f sec/batch)')
        print(format_str % (step, loss_value, examples_per_sec, sec_per_batch))

num_examples = 10000
import math
num_iter = int(math.ceil(num_examples / batch_size))
true_count = 0
total_sample_count = num_iter * batch_size
step = 0
while step < num_iter:
    image_batch, labels_batch = sess.run([images_test, labels_test])
    prediction = sess.run([top_k_op], feed_dict={image_holder: image_batch, label_holder: labels_batch})
    true_count += np.num(prediction)
    step += 1

    precision = true_count / total_sample_count
    print('precision @ 1 = %.3f' % precision)
```