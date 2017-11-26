# MNIST

新建一个项目目录，把下载的数据文件放到对应文件夹里，目录结构如下：

```
.
├── MNIST_data
│   ├── t10k-images-idx3-ubyte.gz
│   ├── t10k-labels-idx1-ubyte.gz
│   ├── train-images-idx3-ubyte.gz
│   └── train-labels-idx1-ubyte.gz
└── mnist_train.py
```

然后在程序中倒入数据：

```python
import numpy as np
import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data

if __name__ == "__main__":
    mnist = input_data.read_data_sets("MINIST_data/", one_hot=True)
```

> The MNIST data is split into three parts: 55,000 data points of training data (`mnist.train`), 10,000 points of test data (`mnist.test`), and 5,000 points of validation data (`mnist.validation`).
>
> Both the training set and test set contain images and their corresponding labels; for example the training images are `mnist.train.images` and the training labels are `mnist.train.labels`.
>
> Each image is 28 pixels by 28 pixels
>
> The result is that mnist.train.images is a tensor (an n-dimensional array) with a shape of `[55000, 784]`. The first dimension is an index into the list of images and the second dimension is the index for each pixel in each image. Each entry in the tensor is a pixel intensity between 0 and 1, for a particular pixel in a particular image.
>
> Each image in MNIST has a corresponding label, a number between 0 and 9 representing the digit drawn in the image.


## Softmax Regressions

```math
y = \text{softmax}(Wx + b)
```

```python
x = tf.placeholder(tf.float32, [None, 784]) # Here "None" means that a dimension can be of any length.
W = tf.Variable(tf.zeros([784, 10]))
b = tf.Variable(tf.zeros([10]))
```

> Notice that W has a shape of `[784, 10]` because we want to multiply the `784-dimensional` image vectors by it to produce `10-dimensional` vectors of evidence for the difference classes. b has a shape of `[10]` so we can add it to the output

`softmax` 训练模型：

```python
y = tf.nn.softmax(tf.matmul(x, W) + b)
```

**交叉信息熵 (cross-entropy)**

> cross-entropy is measuring how inefficient our predictions are for describing the truth

```math
H_{y'}(y) = -\sum_i y'_i \log(y_i)
```

(`y` 是我们预测的结果，`y'` 是实际的结果)

```python
y_ = tf.placeholder(tf.float32, [None, 10])
cross_entropy = tf.reduce_mean(-tf.reduce_sum(y_ * tf.log(y)), reduction_indices=[1])
```

使用梯度下降算法，优化交叉信息熵：

```python
# ask TensorFlow to minimize cross_entropy using the gradient descent algorithm with a learning rate of 0.5
train_step = tf.train.GradientDescentOptimizer(0.5).minimize(cross_entropy)
```

在 `InteractiveSession` 运行训练模型：

> TensorFlow relies on a highly efficient C++ backend to do its computation. The connection to this backend is called a session. **The common usage for TensorFlow programs is to first create a graph and then launch it in a session.**
>
> Here we instead use the convenient InteractiveSession class, which makes TensorFlow more flexible about how you structure your code. It allows you to interleave operations which build a computation graph with ones that run the graph. This is particularly convenient when working in interactive contexts like IPython. If you are not using an InteractiveSession, then you should build the entire computation graph before starting a session and launching the graph.

```python
sess = tf.InteractiveSession()
tf.initialize_all_variables().run()

for _ in range(1000):
    # Each step of the loop, we get a "batch" of one hundred random data points from our training set
    batch_xs, batch_ys = mnist.train.next_batch(100)
    sess.run(train_step, feed_dict={x: batch_xs, y_: batch_ys})
```

Evaluating Our Model：

```python
correct_prediction = tf.equal(tf.argmax(y, 1), tf.argmax(y_, 1))
accurancy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
print(sess.run(accurancy, feed_dict={x: mnist.test.images, y_: mnist.test.labels}))
```

> `tf.argmax(y,1)` is the label our model thinks is most likely for each input, while `tf.argmax(y_,1)` is the correct label. We can use tf.equal to check if our prediction matches the truth.
>
> That gives us a list of booleans. To determine what fraction are correct, we cast to floating point numbers and then take the mean. For example, `[True, False, True, True]` would become `[1,0,1,1]` which would become `0.75`.
>
> This should be about 92%.

完整程序：

```python
import numpy as np
import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data

if __name__ == "__main__":
    mnist = input_data.read_data_sets("MINIST_data/", one_hot=True)
    x = tf.placeholder(tf.float32, [None, 784]) # Here "None" means that a dimension can be of any length.
    W = tf.Variable(tf.zeros([784, 10]))
    b = tf.Variable(tf.zeros([10]))

    # implement softmax model
    y = tf.nn.softmax(tf.matmul(x, W) + b)

    # cross-entropy
    y_ = tf.placeholder(tf.float32, [None, 10])
    cross_entropy = tf.reduce_mean(-tf.reduce_sum(y_ * tf.log(y), reduction_indices=[1]))

    # ask TensorFlow to minimize cross_entropy using the gradient descent algorithm with a learning rate of 0.5
    train_step = tf.train.GradientDescentOptimizer(0.5).minimize(cross_entropy)

    sess = tf.InteractiveSession()
    tf.initialize_all_variables().run()

    for step in range(1000):
        # Each step of the loop, we get a "batch" of one hundred random data points from our training set
        batch_xs, batch_ys = mnist.train.next_batch(100)
        sess.run(train_step, feed_dict={x: batch_xs, y_: batch_ys})
        # Evaluating Our Model
        if (step % 100 == 0):
            correct_prediction = tf.equal(tf.argmax(y, 1), tf.argmax(y_, 1))
            accurancy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
            print(sess.run(accurancy, feed_dict={x: mnist.test.images, y_: mnist.test.labels}))
```


---


## 多层卷积神经网络 (Multilayer Convolutional Network)

### First Convolutional Layer

> We're using `ReLU neurons`, it is also good practice to initialize them with a slightly positive initial bias to avoid `dead neurons`

首先定义两个辅助函数：

```python
def weight_variable(shape):
    initial = tf.truncated_normal(shape, stddev=0.1)
    return tf.Variable(initial)

def bias_variable(shape):
    initial = tf.constant(0.1, shape=shape)
    return tf.Variable(initial)
```

### Convolution and Pooling

> In this example, we're always going to choose the vanilla version. Our convolutions uses a stride of one and are zero padded so that the output is the same size as the input. Our pooling is plain old max pooling over 2x2 blocks.

```python
def conv2d(x, W):
    return tf.nn.conv2d(x, W, strides=[1, 1, 1, 1], padding='SAME')

def max_pool_2x2(x):
    return tf.nn.max_pool(x, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME')
```

### First Convolutional Layer

```python
W_conv1 = weight_variable([5, 5, 1, 32]) # The first two dimensions are the patch size, the next is the number of input channels, and the last is the number of output channels. .
# a bias vector with a component for each output channel
b_conv1 = bias_variable([32])

# reshape x to a 4d tensor
# the second and third dimensions corresponding to image width and height, and the final dimension corresponding to the number of color channels
x_image = tf.reshape(x, [-1, 28, 28, 1])

h_conv1 = tf.nn.relu(conv2d(x_image, W_conv1) + b_conv1)
h_pool1 = max_pool_2x2(h_conv1)
```

### Second Convolutional Layer

```python
W_conv2 = weight_variable([5, 5, 32, 64])
b_conv2 = bias_variable([64])

h_conv2 = tf.nn.relu(conv2d(h_pool1, W_conv2) + b_conv2)
h_pool2 = max_pool_2x2(h_conv2)
```

### Densely Connected Layer

```python
W_fc1 = weight_variable([7 * 7 * 64, 1024])
b_fc1 = bias_variable([1024])

h_pool2_flat = tf.reshape(h_pool2, [-1, 7 * 7 * 64])
h_fc1 = tf.nn.relu(tf.matmul(h_pool2_flat, W_fc1) + b_fc1)
```

### Dropout

> TensorFlow's `tf.nn.dropout` op automatically handles scaling neuron outputs in addition to masking them, so dropout just works without any additional scaling.

```python
keep_prob = tf.placeholder(tf.float32)
h_fc1_drop = tf.nn.dropout(h_fc1, keep_prob)
```

### Readout Layer

```python
W_fc2 = weight_variable([1024, 10])
b_fc2 = bias_variable([10])

y_conv = tf.matmul(h_fc1_drop, W_fc2) + b_fc2
```

### Train and Evaluate the Model

使用与之前简单的单层`SoftMax`神经网络模型几乎相同的一套代码，只是我们会用更加复杂的`ADAM优化器`来做梯度最速下降，在`feed_dict`中加入额外的参数`keep_prob`来控制`dropout`比例。

```python
cross_entropy = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(labels=y_, logits=y_conv))
train_step = tf.train.AdamOptimizer(1e-4).minimize(cross_entropy)
correct_prediction = tf.equal(tf.argmax(y_conv, 1), tf.argmax(y_, 1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
sess = tf.InteractiveSession()
sess.run(tf.initialize_all_variables())
for i in range(20000):
    batch = mnist.train.next_batch(50)
    if i % 100 == 0:
        train_accuracy = accuracy.eval(feed_dict={
            x: batch[0], y_: batch[1], keep_prob: 1.0})
        print("step %d, training accuracy %g" % (i, train_accuracy))
    train_step.run(feed_dict={x: batch[0], y_: batch[1], keep_prob: 0.5})

print("test accuracy %g" % accuracy.eval(feed_dict={
            x: mnist.test.images, y_: mnist.test.labels, keep_prob: 1.0}))
```

完整代码：

```python
import numpy as np
import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data

def weight_variable(shape):
    initial = tf.truncated_normal(shape, stddev=0.1)
    return tf.Variable(initial)

def bias_variable(shape):
    initial = tf.constant(0.1, shape=shape)
    return tf.Variable(initial)

def conv2d(x, W):
    return tf.nn.conv2d(x, W, strides=[1, 1, 1, 1], padding='SAME')

def max_pool_2x2(x):
    return tf.nn.max_pool(x, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME')

if __name__ == "__main__":
    mnist = input_data.read_data_sets("MINIST_data/", one_hot=True)

    x = tf.placeholder(tf.float32, [None, 784])

    # First Convolutional Layer
    W_conv1 = weight_variable([5, 5, 1, 32]) # The first two dimensions are the patch size, the next is the number of input channels, and the last is the number of output channels. .
    # a bias vector with a component for each output channel
    b_conv1 = bias_variable([32])

    # reshape x to a 4d tensor
    # the second and third dimensions corresponding to image width and height, and the final dimension corresponding to the number of color channels
    x_image = tf.reshape(x, [-1, 28, 28, 1])

    h_conv1 = tf.nn.relu(conv2d(x_image, W_conv1) + b_conv1)
    h_pool1 = max_pool_2x2(h_conv1)

    # Second Convolutional Layer
    W_conv2 = weight_variable([5, 5, 32, 64])
    b_conv2 = bias_variable([64])

    h_conv2 = tf.nn.relu(conv2d(h_pool1, W_conv2) + b_conv2)
    h_pool2 = max_pool_2x2(h_conv2)

    # Densely Connected Layer
    W_fc1 = weight_variable([7 * 7 * 64, 1024])
    b_fc1 = bias_variable([1024])

    h_pool2_flat = tf.reshape(h_pool2, [-1, 7 * 7 * 64])
    h_fc1 = tf.nn.relu(tf.matmul(h_pool2_flat, W_fc1) + b_fc1)

    # Dropout
    keep_prob = tf.placeholder(tf.float32)
    h_fc1_drop = tf.nn.dropout(h_fc1, keep_prob)

    # Readout Layer
    W_fc2 = weight_variable([1024, 10])
    b_fc2 = bias_variable([10])

    y_conv = tf.matmul(h_fc1_drop, W_fc2) + b_fc2
    y_ = tf.placeholder(tf.float32, [None, 10])

    # Train and Evaluate the Model
    cross_entropy = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(labels=y_, logits=y_conv))
    train_step = tf.train.AdamOptimizer(1e-4).minimize(cross_entropy)
    correct_prediction = tf.equal(tf.argmax(y_conv, 1), tf.argmax(y_, 1))
    accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
    sess = tf.InteractiveSession()
    sess.run(tf.initialize_all_variables())
    for i in range(20000):
        batch = mnist.train.next_batch(50)
        if i % 100 == 0:
            train_accuracy = accuracy.eval(feed_dict={
                x: batch[0], y_: batch[1], keep_prob: 1.0})
            print("step %d, training accuracy %g" % (i, train_accuracy))

        train_step.run(feed_dict={x: batch[0], y_: batch[1], keep_prob: 0.5})

    print("test accuracy %g" % accuracy.eval(feed_dict={
            x: mnist.test.images, y_: mnist.test.labels, keep_prob: 1.0}))
```