# TensorFlow —— RNN 自然语言建模（PTB数据集为例）


## 复杂度 (perplexity)

复杂度的通俗理解：如果一个语言模型的 perplexity 为 89，就表示，平均情况下，模型预测下一个词是，有89个词等可能的可以作为下一个词的合理选择


## PTB 数据集

TensorFlow 提供了 `ptb_raw_data` 函数读取 PTB 原始数据，并将原始数据中的单词转换为单词 ID；提供了 `ptb_iterator` 实现截断并将数据组织成 batch

```python
import tensorflow as tf
from tensorflow.models.rnn.ptb import reader

DATA_PATH = './simple-examples/data'
train_data, valid_data, test_data, _ = reader.ptb_raw_data(DATA_PATH)
print(len(train_data))
print(train_data[:100])
# 929589
# [9970, 9971, 9972, 9974, 9975, 9976, 9980, 9981, 9982, 9983, 9984, 9986, 9987, 9988, 9989, 9991, 9992, 9993, 9994, 9995, 9996, 9997, 9998, 9999, 2, 9256, 1, 3, 72, 393, 33, 2133, 0, 146, 19, 6, 9207, 276, 407, 3, 2, 23, 1, 13, 141, 4, 1, 5465, 0, 3081, 1596, 96, 2, 7682, 1, 3, 72, 393, 8, 337, 141, 4, 2477, 657, 2170, 955, 24, 521, 6, 9207, 276, 4, 39, 303, 438, 3684, 2, 6, 942, 4, 3150, 496, 263, 5, 138, 6092, 4241, 6036, 30, 988, 6, 241, 760, 4, 1015, 2786, 211, 6, 96, 4]


# 将训练数据组织成 batch 为4，截断长度为 5 的数据组
result = reader.ptb_iterator(train_data, 4, 5)
x, y = result.__next__()
print("X: ", x)
print("Y: ", y)
# X:  [[9970 9971 9972 9974 9975]
#  [ 332 7147  328 1452 8595]
#  [1969    0   98   89 2254]
#  [   3    3    2   14   24]]
# Y:  [[9971 9972 9974 9975 9976]
#  [7147  328 1452 8595   59]
#  [   0   98   89 2254    0]
#  [   3    2   14   24  198]]
```

完整源码（下面源码参考《TensorFlow 实战Google深度学习框架》实现）：

```python
import tensorflow as tf
import numpy as np
from tensorflow.models.rnn.ptb import reader

DATA_PATH = './simple-examples/data'
HIDDEN_SIZE = 200 # 隐藏层大小
NUM_LAYERS = 2 # 深层 RNN 中 LSTM 结构的层数
VOCAB_SIZE = 10000 # 词典规模，加上语句结束标识符和西游单词标识符，总共 10000 个单词

LAERNING_RATE = 1.0 # 学习率
TRAIN_BATCH_SIZE = 20 # 训练数据 batch 大小
TRAIN_NUM_STEP = 35 # 训练数据的截断长度

# 测试时，数据不需要使用截断，所以可以将测试数据看成一个超长的序列
EVAL_BATCH_SIZE = 1 # 测试数据 batch 大小
EVAL_NUM_STEP = 1 # 测试数据截断长度
NUM_EPOCH = 2 # 使用训练数据的轮数
KEEP_PROB = 0.5 # 节点不被 dropout 的概率
MAX_GRAD_NORM= 5 # 用于控制提督膨胀的参数

class PTBModel(object):
    def __init__(self, is_training, batch_size, num_steps):
        self.batch_size = batch_size
        self.num_steps = num_steps
        self.input_data = tf.placeholder(tf.int32, [batch_size, num_steps])
        self.targets = tf.placeholder(tf.int32, [batch_size, num_steps])

        # 定义 LSTM 结构为循环体结构且使用 dropout 的深层 RNN
        lstm_cell = tf.nn.rnn_cell.BasicLSTMCell(HIDDEN_SIZE)
        if is_training:
            lstm_cell = tf.nn.rnn_cell.DropoutWrapper(lstm_cell, output_keep_prob=KEEP_PROB)
        cell = tf.nn.rnn_cell.MultiRNNCell([lstm_cell] * NUM_LAYERS)

        # 初始状态为全零的向量
        self.initial_state = cell.zero_state(batch_size, tf.float32)

        # 将单词 ID 转换为单词向量
        # 总共 VOCAB_SIZE 个单词，每个单词向量维度为 HIDDEN_SIZE，故 embedding 的维度为 VOCAB_SIZE x HIDDEN_SIZE
        embedding = tf.get_variable("embedding", [VOCAB_SIZE, HIDDEN_SIZE])
        inputs = tf.nn.embedding_lookup(embedding, self.input_data)

        # 只在训练时输入使用 dropout
        if is_training:
            inputs = tf.nn.dropout(inputs, KEEP_PROB)

        outputs = []
        state = self.initial_state
        with tf.variable_scope("RNN"):
            for time_step in range(num_steps):
                if time_step > 0: tf.get_variable_scope().reuse_variables()
                cell_output, state = cell(inputs[:,time_step,:], state)
                outputs.append(cell_output)

        output = tf.reshape(tf.concat(1, outputs), [-1, HIDDEN_SIZE])

        weight = tf.get_variable("weights", [HIDDEN_SIZE, VOCAB_SIZE])
        bias = tf.get_variable("bias", [VOCAB_SIZE])
        logits = tf.matmul(output, weight) + bias

        # 交叉熵损失函数
        loss = tf.nn.seq2seq.sequence_loss_by_example(
            [logits],
            [tf.reshape(self.targets, [-1])],
            [tf.ones([batch_size * num_steps], dtype=tf.float32)]
        )
        self.cost = tf.reduce_sum(loss) / batch_size
        self.final_state = state

        # 只在训练模型时定义反向传播
        if not is_training: return

        trainable_variables = tf.trainable_variables()
        grads, _ = tf.clip_by_global_norm( # 通过 clip_by_global_norm 控制梯度大小，避免梯度膨胀的问题
            tf.gradients(self.cost, trainable_variables),
            MAX_GRAD_NORM
        )
        optimizer = tf.train.GradientDescentOptimizer(LAERNING_RATE)
        self.train_op = optimizer.apply_gradients(zip(grads, trainable_variables))

def run_epoch(session, model, data, train_op, output_log):
    total_costs = 0.0
    iters = 0
    state = session.run(model.initial_state)
    for step, (x, y) in enumerate(reader.ptb_iterator(data, model.batch_size, model.num_steps)):
        cost, state, _ = session.run(
            [model.cost, model.final_state, train_op],
            {model.input_data: x, model.targets: y, model.initial_state: state}
        )
        total_costs += cost
        iters += model.num_steps
        if output_log and step % 100 == 0:
            print("After %d steps, perplexity is %.3f" % (step, np.exp(total_costs / iters)))

    return np.exp(total_costs / iters)

def main(_):
    train_data, valid_data, test_data, _ = reader.ptb_raw_data(DATA_PATH)
    initializer = tf.random_uniform_initializer(-0.05, 0.05)

    # 训练用的 RNN 模型
    with tf.variable_scope("language_model", reuse=None, initializer=initializer):
        train_model = PTBModel(True, TRAIN_BATCH_SIZE, TRAIN_NUM_STEP)

    # 评测用的 RNN 模型
    with tf.variable_scope("language_model", reuse=True, initializer=initializer):
        eval_model = PTBModel(False, EVAL_BATCH_SIZE, EVAL_NUM_STEP)

    with tf.Session() as sess:
        tf.initialize_all_variables().run()
        for i in range(NUM_EPOCH):
            print("In iteration: %d" % (i + 1))
            run_epoch(sess, train_model,
                      train_data, train_model.train_op, True)
            valid_perplexity = run_epoch(sess, eval_model,
                                         valid_data, tf.no_op(), False)
            print("Epoch: %d Validation Perplexity: %.3f" % (i + 1, valid_perplexity))

        test_perplexity = run_epoch(sess, eval_model, test_data, tf.no_op(), False)
        print("Test Perplexity: %.3f" % test_perplexity)

if __name__ == "__main__":
    tf.app.run()
```