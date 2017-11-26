# TensorFlow —— MNIST

MINST 训练数据：

MINST 数据集中的图片为 `28x28` ，像素矩阵的取值为 `[0, 1]` 代表了颜色的深浅，0 为白色，1 为黑色。

`input_data.read_data_sets` 生成的类会自动将 MNIST 数据集划分为 `train`, `validation`, `test` 三个数据集，如

```python
import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets('./MNIST_DATA', one_hot=True)

print("Training data size: ", mnist.train.num_examples)
# Training data size:  55000
print("Validating data size: ", mnist.validation.num_examples)
# Validating data size:  5000
print("Testing data size: ", mnist.test.num_examples)
# Testing data size:  10000
print("Example training data: ", mnist.train.images[0])
# Example training data:  [ 0.          0.          0. ... 0.]
print("Example training data label: ", mnist.train.labels[0])
# [ 0.  0.  0.  0.  0.  0.  0.  1.  0.  0.]
```

还提供了 `mnist.train.next_batch` 函数，可以从所有的训练数据中读取一小部分作为一个训练 batch，如：

```python
import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets('./MNIST_DATA', one_hot=True)

batch_size = 100
xs, ys = mnist.train.next_batch(batch_size)
print("X shape: ", xs.shape) # X shape:  (100, 784)
print("Y shape: ", ys.shape) # Y shape:  (100, 10)
```


下面源码参考《TensorFlow 实战Google深度学习框架》实现：

```python
import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data

INPUT_NODE = 784
OUTPUT_NODE = 10

LAYER1_NODE = 500
BATCH_SIZE = 100

LEARNABLE_RATE_BASE = 0.8 # 基础学习率
LEARNABLE_RATE_DECAY = 0.99 # 学习率的衰减率

REGULARIZATION_RATE = 0.0001 # 正则化的系数
TRAINING_STEPS = 10000 # 训练轮数
MOVING_AVERAGE_DECAY = 0.99 # 滑动平均衰减率

def inference(input_tensor, avg_class, weights1, biases1, weights2, biases2):
    if avg_class == None:
        layer1 = tf.nn.relu(tf.matmul(input_tensor, weights1) + biases1)
        return tf.matmul(layer1, weights2) + biases2
    else:
        layer1 = tf.nn.relu(tf.matmul(input_tensor, avg_class.average(weights1)) + avg_class.average(biases1))
        return tf.matmul(layer1, avg_class.average(weights2) + avg_class.average(biases2))

def train(mnist):
    x = tf.placeholder(tf.float32, [None, INPUT_NODE], name='x-input')
    y_ = tf.placeholder(tf.float32, [None, OUTPUT_NODE], name='y-input')

    weights1 = tf.Variable(tf.random_normal([INPUT_NODE, LAYER1_NODE], stddev=0.1))
    biases1 = tf.Variable(tf.constant(0.1, shape=[LAYER1_NODE]))
    weights2 = tf.Variable(tf.random_normal([LAYER1_NODE, OUTPUT_NODE], stddev=0.1))
    biases2 = tf.Variable(tf.constant(0.1, shape=[OUTPUT_NODE]))

    y = inference(x, None, weights1, biases1, weights2, biases2)

    # 训练轮数
    global_step = tf.Variable(0, trainable=False)

    # 给定滑动平均衰减率和寻轮轮数的变量，初始化滑动平均类
    variable_averages = tf.train.ExponentialMovingAverage(MOVING_AVERAGE_DECAY, global_step)
    # 在所有代表神经网络的参数的变量上使用滑动平均
    variable_average_op = variable_averages.apply(tf.trainable_variables())
    average_y = inference(x, variable_averages, weights1, biases1, weights2, biases2)

    # softmax 和 交叉熵
    cross_entropy = tf.nn.sparse_softmax_cross_entropy_with_logits(y, tf.argmax(y_, 1))
    cross_entropy_mean = tf.reduce_mean(cross_entropy)

    # 正则化损失函数
    regularizer = tf.contrib.layers.l2_regularizer(REGULARIZATION_RATE)
    # 对权重 weights1 weights2 计算正则化损失
    regularization = regularizer(weights1) + regularizer(weights2)
    loss = cross_entropy_mean + regularization

    learning_rate = tf.train.exponential_decay(LEARNABLE_RATE_BASE, global_step, mnist.train.num_examples, LEARNABLE_RATE_DECAY)

    train_step = tf.train.GradientDescentOptimizer(learning_rate).minimize(loss, global_step=global_step)

    # TensorFlow 提供 tf.control_dependencies 函数来实现，每过一遍数据，在反向传播更新神经网络的参数的同时，更新每一个参数的滑动平均值
    with tf.control_dependencies([train_step, variable_average_op]):
        train_op = tf.no_op(name='train')

        correct_prediction = tf.equal(tf.argmax(average_y, 1), tf.argmax(y_, 1))
        accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))

    with tf.Session() as sess:
        tf.initialize_all_variables().run()
        variable_feed = {x: mnist.validation.images,
                         y_: mnist.validation.labels}
        test_feed = {x: mnist.test.images,
                     y_: mnist.test.labels}
        for i in range(TRAINING_STEPS):
            if i % 1000 == 0:
                validate_acc = sess.run(accuracy, feed_dict=variable_feed)
                print("After %d training step(s), validation accuracy using average model is %g" % (i, validate_acc))

            xs, ys = mnist.train.next_batch(BATCH_SIZE)
            sess.run(train_op, feed_dict={x: xs, y_: ys})

        test_acc = sess.run(accuracy, feed_dict=test_feed)
        print("After %d training step(s), validation accuracy using average model is %g" % (TRAINING_STEPS, test_acc))

def main(argv=None):
    mnist = input_data.read_data_sets("./MNIST_DATA", one_hot=True)
    train(mnist)

if __name__ == '__main__':
    # TensorFlow 提供一个主程序入口，tf.app.run() 会调用上面定义的 main 函数
    tf.app.run()
```