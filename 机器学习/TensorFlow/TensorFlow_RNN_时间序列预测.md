# TensorFlow —— RNN 时间序列预测

下面源码参考《TensorFlow 实战Google深度学习框架》实现：

```python
import tensorflow as tf
import numpy as np
import matplotlib as mpl

mpl.use('Agg')
from matplotlib import pyplot as plt

learn = tf.contrib.learn

HIDDEN_SIZE = 30
NUM_LAYERS = 2
TIMESTEPS = 10
TRAINING_STEPS = 10000
BATCH_SIZE = 32

TRAINING_EXAMPLES = 10000
TESTING_EXAMPLES = 1000
SAMPLE_CAP = 0.01

def generate_data(seq):
    X = []
    y = []
    for i in range(len(seq) - TIMESTEPS - 1):
        X.append(seq[i : i + TIMESTEPS])
        y.append(seq[i + TIMESTEPS])
    return np.array(X, dtype=np.float32), np.array(y, dtype=np.float32)

def lstm_model(X, y):
    lstm_cell = tf.nn.rnn_cell.BasicLSTMCell(HIDDEN_SIZE)
    cell = tf.nn.rnn_cell.MultiRNNCell([lstm_cell] * NUM_LAYERS)
    x_ = tf.unpack(X, axis=1)

    output, _ = tf.nn.rnn(cell, x_, dtype=tf.float32)
    output = output[-1] # 只关注最后一个时刻的输出

    prediction, loss = learn.models.linear_regression(output, y)
    train_op = tf.contrib.layers.optimize_loss(
        loss, tf.contrib.framework.get_global_step(),
        optimizer='Adagard', learning_rate=0.6
    )

    return prediction, loss, train_op

regressor = learn.Estimator(model_fn=lstm_model)

test_start = TRAINING_EXAMPLES * SAMPLE_CAP
test_end = (TRAINING_EXAMPLES + TESTING_EXAMPLES) * SAMPLE_CAP
# np.linspace(start, end, length)
# np.linspace(1, 10, 10)  --> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
train_X, train_y = generate_data(
    np.sin(np.linspace(0, test_start, TRAINING_EXAMPLES, dtype=np.float32))
)
test_X, test_y = generate_data(
    np.sin(np.linspace(test_start, test_end, TESTING_EXAMPLES, dtype=np.float32))
)

regressor.fit(train_X, train_y, batch_size=BATCH_SIZE, steps=TRAINING_STEPS)

predicted = [[pred] for pred in regressor.predict(test_X)]
rmse = np.sqrt(((predicted - test_y) ** 2).mean(axis=0))
print("Mean Square Error is: %f" % rmse[0])

fig = plt.figure()
plot_predicted = plt.plot(predicted, label='predicted')
plot_test = plt.plot(test_y, label='real_sin')
plt.legend([plot_predicted, plot_test], ['predicted', 'real_sin'])
fig.savefig('sin.png')
```