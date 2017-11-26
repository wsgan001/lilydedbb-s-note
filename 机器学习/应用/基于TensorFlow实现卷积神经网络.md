# 基于 TensorFlow 实现卷积神经网络


## 建造神经网络

(这里用随机定义训练的数据 x 和 y)

```python
import tensorflow as tf
import numpy as np

x_data = np.linspace(-1, 1, 300)[:, np.newaxis]
noise = np.random.normal(0, 0.05, x_data.shape)
y_data = np.square(x_data) - 0.05 + noise


def add_layer(inputs, in_size, out_size, activation_function=None):
    weights = tf.Variable(tf.random_normal([in_size, out_size]))
    biases = tf.Variable(tf.zeros([1, out_size]) + 0.1)
    Wx_plus_b = tf.matmul(inputs, weights) + biases
    # 隐含节点dropout率等于0.5的时候效果最好，即 keep_prob=0.5，原因是0.5的时候dropout随机生成的网络结构最多
    Wx_plus_b = tf.nn.dropout(Wx_plus_b, keep_prob=0.5)
    if activation_function is None:
        outputs = Wx_plus_b
    else:
        outputs = activation_function(Wx_plus_b)
    return outputs


xs = tf.placeholder(tf.float32, [None, 1])
ys = tf.placeholder(tf.float32, [None, 1])

l1 = add_layer(xs, 1, 10, activation_function=tf.nn.relu)
predictions = add_layer(l1, 10, 1, activation_function=None)

loss = tf.reduce_mean(tf.reduce_sum(tf.square(ys - predictions)), reduction_indices=[1])
optimizer = tf.train.GradientDescentOptimizer(0.1)
train_step = optimizer.minimize(loss)

init = tf.initialize_all_variables()

with tf.Session() as sess:
    sess.run(init)
    for i in range(1000):
        sess.run(train_step, feed_dict={xs: x_data, ys: y_data})
        if i % 50 == 0:
            print(sess.run(loss, feed_dict={xs: x_data, ys: y_data}))
```

## 可视化 Tensorboard

（用 with tf.name_scope 定义各个框架）

## tf.train.Saver()

```python
import tensorflow as tf

W = tf.Variable([[1, 2, 3], [3, 4, 5]], dtype=tf.float32, name='weights')
b = tf.Variable([[1, 2, 3]], dtype=tf.float32, name='biases')

saver = tf.train.Saver()

with tf.Session() as sess:
    sess.run(tf.initialize_all_variables())
    save_path = saver.save(sess, "my_net/save_net.ckpt")
```
