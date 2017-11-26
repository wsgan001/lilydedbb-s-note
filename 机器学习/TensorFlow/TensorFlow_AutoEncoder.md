# TensorFlow —— AutoEncoder

> 自编码器(autoencoder)，顾名思义，即可以用自身的高阶特征编码自己。自编码器也是一种神经网络，他的输入输出是一致的，它借助稀疏编码的思想，目标是使用稀疏的一些高阶特征重新组合来重构自己


去躁自编码器示例源码：

```python
import numpy as np
import sklearn.preprocessing as prep
import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data

# 标准的均匀分布的 Xaiver 初始化器
def xaiver_init(fan_in, fan_out, constant = 1):
    """
    :param fan_in: 为输入节点数量
    :param fan_out: 为输出节点数量
    :param constant:
    :return:
    """
    low = -constant * np.sqrt(6.0 / (fan_in + fan_out))
    high = constant * np.sqrt(6.0 / (fan_in + fan_out))
    return tf.random_uniform((fan_in, fan_out), minval=low, maxval=high, dtype=tf.float32)

class AdditiveGaussianNoiseAutoencoder (object):

    def __init__(self, n_input, n_hidden, transfer_function=tf.nn.softplus, optimizer=tf.train.AdamOptimizer, scale=0.1):
        """
        :param n_input: 输入变量数
        :param n_hidden: 隐含层节点数
        :param transfer_function: 隐含层激活函数，默认为 softplus
        :param optimizer: 优化器，默认为 AdamOptimizer
        :param scale: 高斯噪声系数
        """
        self.n_input = n_input
        self.n_hidden = n_hidden
        self.transfer = transfer_function
        self.scale = tf.placeholder(tf.float32)
        self.training_scale = scale
        network_weights = self._initialize_weights()
        self.weights = network_weights
        self.x = tf.placeholder(tf.float32, [None, self.n_input])
        self.hidden = self.transfer(
            tf.add(
                tf.matmul(self.x + scale * tf.random_normal((n_input, )), self.weights['w1']), # x 加上噪声：self.x + scale * tf.random_normal((n_input, ))
                self.weights['b1'])
        )
        self.reconstruction = tf.add(tf.matmul(self.hidden, self.weights['w2']), self.weights['b2'])
        # 平方误差作为损失函数
        self.cost = 0.5 * tf.reduce_sum(tf.pow(tf.subtract(self.reconstruction, self.x), 2.0))
        self.optimizer = optimizer.minimize(self.cost)
        init = tf.initialize_all_variables()
        self.sess = tf.Session()
        self.sess.run(init)

    # 返回一个包含 w1, b1, w2, b2 的字典
    def _initialize_weights(self):
        all_weights = dict()
        all_weights['w1'] = tf.Variable(xaiver_init(self.n_input, self.n_hidden))
        all_weights['b1'] = tf.Variable(tf.zeros([self.n_hidden], dtype=tf.float32))
        all_weights['w2'] = tf.Variable(xaiver_init(self.n_hidden, self.n_input))
        all_weights['b2'] = tf.Variable(tf.zeros([self.n_input], dtype=tf.float32))
        return all_weights

    # 用一 batch 数据进行训练，并返回当前的损失 cost
    def partial_fit(self):
        cost, opt = self.sess.run((self.cost, self.optimizer), feed_dict={self.x: X, self.scale: self.training_scale})
        return cost

    # 只求 cost，与 partial_fit 函数不同，calc_total_cost 不进行训练
    def calc_total_cost(self, X):
        return self.sess.run(self.cost, feed_dict={self.x: X, self.scale: self.training_scale})

    # 返回编码器隐含层的输出结果
    def transform(self, X):
        return self.sess.run(self.hidden, feed_dict={self.x: X, self.scale: self.training_scale})

    # 将隐含层输出结果作为输入，通过之后的重建层将提取到的高阶特征复原为原始数据
    def generate(self, hidden=None):
        if hidden is None:
            hidden = np.random.normal(size=self.weights['b1'])
        return self.sess.run(self.reconstruction, feed_dict={self.hidden: hidden})

    # 相当于 transform 和 generate 的合并
    def reconstruct(self, X):
        return self.sess.run(self.reconstruction, feed_dict={self.x: X, self.scale: self.training_scale})

    # 获取隐含层权重 w1
    def getWeights(self):
        return self.sess.run(self.weights['w1'])

    # 获取隐含层偏置系数 b1
    def getBiases(self):
        return self.sess.run(self.weights['b1'])


def standard_scale(X_train, X_test):
    """
    对训练集进行标准化（即 0 为均值，1 为方差）的函数
    """
    preprocessor = prep.StandardScaler().fit(X_train)
    X_train = preprocessor.transform(X_train)
    X_test = preprocessor.transform(X_test)
    return X_train, X_test

def get_random_block_from_data(data, batch_size):
    start_index = np.random.randint(0, len(data) - batch_size)
    return data[start_index : (start_index + batch_size)]

if __name__ == '__main__':
    # 倒入 MNIST 数据集
    mnist = input_data.read_data_sets('MNIST_DATA', one_hot=True)
    # 对数据集进行标准化变换
    X_train, X_test = standard_scale(mnist.train.images, mnist.test.images)
    # 总训练样本数
    n_samples = int(mnist.train.num_examples)
    # 最大训练轮数
    training_epochs = 20
    batch_size = 128
    display_step = 1
    AutoEncoder = AdditiveGaussianNoiseAutoencoder(n_input=784,
                                                   n_hidden=200,
                                                   transfer_function=tf.nn.softplus,
                                                   optimizer=tf.train.AdamOptimizer(learning_rate = 0.001),
                                                   scale=0.01)
    for epoch in range(training_epochs):
        avg_cost = 0
        total_batch = int(n_samples / batch_size)
        for i in range(total_batch):
            batch_xs = get_random_block_from_data(X_train, X_test)
            cost = AutoEncoder.partial_fit(batch_xs)
            avg_cost += cost / n_samples * batch_size
        if epoch % display_step == 0:
            print("Epoch: ", '%04d' % (epoch + 1), "cost=", "{:.9f}".format(avg_cost))
```