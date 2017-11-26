# TensorFlow —— RNN

> 递归神经网络（RNN）是两种人工神经网络的总称:
>
> - 时间递归神经网络（recurrent neural network）
> - 结构递归神经网络（recursive neural network）

![image](../../images/RNN-rolled.png)

RNN 中的循环可以展开为一个个串联的结构：

![image](../../images/RNN-unrolled.png)

需要注意的是，**展开后的每一个层级的神经网络，其参数都是相同的**，因此只需要训练一层 RNN 的参数

一个简单的 RNN 前向传播过程：

```python
import numpy as np

X = [1, 2]
state = [0.0, 0.0]

w_cell_state = np.asarray([[0.1, 0.2], [0.3, 0.4]])
w_cell_input = np.asarray([0.5, 0.6])
b_cell = np.asarray([0.1, -0.1])

w_output = np.asarray([[1.0], [2.0]])
b_output = 0.1

for i in range(len(X)):
    before_activation = np.dot(state, w_cell_state) + X[i] * w_cell_input + b_cell
    state = np.tanh(before_activation)

    final_output = np.dot(state, w_output) + b_output

    print("Before activation: ", before_activation)
    print("state: ", state)
    print("output: ", final_output)
```

```
# output
Before activation:  [ 0.6  0.5]
state:  [ 0.53704957  0.46211716]
output:  [ 1.56128388]
Before activation:  [ 1.2923401   1.39225678]
state:  [ 0.85973818  0.88366641]
output:  [ 2.72707101]
```


## LSTM (Long Short Term Memory)

RNN 虽然被设计为可以处理整个时间序列信息，但是器记忆最深的还是最后输入的一些信号，而更早之前的信号的强度则越来越低，最后只能起一点辅助作用

参考：[Understanding LSTM Networks](http://colah.github.io/posts/2015-08-Understanding-LSTMs/)

> LSTMs are explicitly designed to avoid the long-term dependency problem. Remembering information for long periods of time is practically their default behavior, not something they struggle to learn!

**LSTM (Long Sort Term Memory) 可以解决长程依赖 (long-term dependencies)**

standard RNNs:

![image](../../images/LSTM3-SimpleRNN.png)

LSTMs:

> LSTMs also have this chain like structure, but the repeating module has a different structure. Instead of having a single neural network layer, there are four, interacting in a very special way.

![image](../../images/LSTM3-chain.png)

TensorFlow 实现：

```python
# TensorFlow 中提供 tf.nn.rnn_cell.BasicLSTMCell 可以实现一个完整的 LSTM 结构
lstm = tf.nn.rnn_cell.BasicLSTMCell(lstm_hidden_size)
state = lstm.zero_state(batch_size, tf.float32)

loss = 0.0

for i in range(num_steps):
    # 在第一个时刻声明 LSTM 结构中使用的变量，在之后的时刻都需要复用之前定义好的变量
    if i > 0: tf.get_variable_scope().reuse_variables()
    # 输入当前的输入（current_input）和前一时刻的状态（state），返回输出（lstm_output）和更新后的状态（state）
    lstm_output, state = lstm(current_input, state)
    # 传入一个全连接层，得到最终输出
    final_output = fully_connected(lstm_output)
    # 计算损失
    loss += calc_loss(final_output, expected_output)
```


## 深层循环神经网络 (deepRNN)

深层循环神经网络是循环神经网络的另外一个变种，将每一时刻上的循环体重复多次

TensorFlow 提供了 `MultiRNNCell` 类实现深层循环神经网络的前向传播过程：

```python
# 定义一个基本的 LSTM 结构作为循环体的基础结构
lstm = tf.nn.rnn_cell.MultiRNNCell(lstm_size)
# 通过 MultiRNNCell 类实现深层神经网络中每一个时刻的前向传播过程，其中number_of_layers 表示有多少层（即，xt 到 ht 需要经过多少个 LSTM 结构）
stacked_lstm = tf.nn.rnn_cell.MultiRNNCell([lstm] * number_of_layers)

state = stacked_lstm.zero_state(batch_size, tf.float32)

for i in range(num_steps):
    if i > 0: tf.get_variable_scope().reuse_variables()
    stacked_lstm_output, state = stacked_lstm(current_input, state)
    final_output = fully_connected(stacked_lstm_output)
    loss += calc_loss(final_output, expected_output)
```


## dropout

通过 `dropout` 可以让 RNN 更加健壮

类似 `CNN` 中只在最后的全连接层中使用 `dropout`，RNN 一般只在不同层循环体结构之间使用 `dropout`，而不在同一层的循环体之间使用（即，从时刻 `t - 1` 到时刻 `t`，`RNN` 不会进行 `dropout`，而在同一时刻 `t` 中，不同层的循环体之间会使用 `dropout`

TensorFlow 中可以通过 `tf.nn.rnn_cell.DropoutWrapper` 类实现 `dropout` 功能，`tf.nn.rnn_cell.DropoutWrapper` 类，通过两个参数控制 `dropout` 概率：
- `output_keep_prob` 控制输出的 `dropout` 概率
- `input_keep_prob` 控制输入的 `dropout` 概率

```python
# 定义一个基本的 LSTM 结构作为循环体的基础结构
lstm = tf.nn.rnn_cell.MultiRNNCell(lstm_size)
# tf.nn.rnn_cell.DropoutWrapper 类，通过两个参数控制 dropout 概率：
# output_keep_prob 控制输出的 dropout 概率
# input_keep_prob 控制输入的 dropout 概率
dropout_lstm = tf.nn.rnn_cell.DropoutWrapper(lstm, output_keep_prob=0.5)

# 在 dropout 的基础上定义多层循环神经网络
stacked_lstm = tf.nn.rnn_cell.MultiRNNCell([dropout_lstm] * number_of_layers)
```