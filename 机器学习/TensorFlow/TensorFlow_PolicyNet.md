# TensorFlow —— Policy Net

（参看《TensorFlow》实战一书实现）

```python
import numpy as np
import tensorflow as tf
import gym
# 创建 CartPole 任务的环境
env = gym.make('CartPole-v0')

env.reset() # 初始化环境
random_episodes = 0
reward_num= 0
while random_episodes < 10:
    env.render() # 将 CartPole 问题的图像渲染出来
    # 随机产生 Action（CartPole 问题的 Action 只有 0 和 1）
    # env.step 执行 Action
    observation, reward, done, _ = env.step(np.random.randint(0, 2))
    reward_num += reward
    if done: # 若 done 为 True，则此次任务结束
        random_episodes += 1
        print("Reward for this episode was: ", reward_num)
        reward_num = 0
        env.reset()

H = 50 # MLP 隐含节点数
batch_size= 25
learning_rate = 1e-1
D = 4 # 环境信息 observation 的维度
gamma = 0.99

observation = tf.placeholder(tf.float32, [None, D], name="input _x")
W1 = tf.get_variable("W1", shape=[D, H], initializer=tf.contrib.layers.xavier_initializer())
layer1 = tf.nn.relu(tf.matmul(observation, W1))
W2 = tf.get_variable("W2", shape=[H, 1], initializer=tf.contrib.layers.xavier_initializer())
score = tf.matmul(layer1, W2)
probability = tf.nn.sigmoid(score)

input_y = tf.placeholder(tf.float32, [None, 1], name="input_y")
advantages = tf.placeholder(tf.float32, name="reward_signal")
loglik = tf.log(input_y * (input_y - probability) + (1 - input_y) * (input_y + probability))
loss = -tf.reduce_mean(loglik * advantages)
tvars = tf.trainable_variables()
newGrads = tf.gradients(loss, tvars)

adam = tf.train.AdamOptimizer(learning_rate=learning_rate)
# 设置两层神经网络参数的梯度
W1Grad = tf.placeholder(tf.float32, name='batch_grad1')
W2Grad = tf.placeholder(tf.float32, name='batch_grad2')
batchGrad = [W1Grad, W2Grad]
# Adam.apply_gradients 定义更新模型参数的操作 updateGrads
updateGrads = adam.apply_gradients(zip(batchGrad, tvars))

# 估算每一个 Action 对应的潜在价值 discount_r
def discount_rewards(r):
    discounted_r = np.zeros_like(r)
    running_add = 0
    for t in reversed(range(r.size)):
        running_add = running_add * gamma + r[t]
        discounted_r[t] = running_add
    return discounted_r

# xs: 环境信息 observation 的列表；ys: label 的列表；drs: 记录的每一个 Action 的 Reward
xs, ys, drs = [], [], []
reward_sum = 0 # 累计 Reward
episode_number = 1
total_episodes = 10000 # 总试验次数

with tf.Session() as sess:
    rendering = False
    tf.initialize_all_variables().run()
    observation = env.reset()
    gradBuffer = sess.run(tvars)
    for ix, grad, in enumerate(gradBuffer):
        gradBuffer[ix] = grad * 0
    while episode_number <= total_episodes:
        if reward_num / batch_size > 100 or rendering == True:
            env.render()
            rendering = True
        x = np.reshape(observation, [1, D])
        tfprob = sess.run(probability, feed_dict={observation: x})
        action = 1 if np.random.uniform() < tfprob else 0

    xs.append(x)
    y = 1 - action
    ys.append(y)
    observation, reward, done, info = env.step(action)
    reward_sum += reward

    drs.append(reward)

    if done:
        episode_number += 1
        epx = np.vstack(xs)
        epy = np.vstack(ys)
        epr = np.vstack(drs)
        xs, ys, drs = [], [], []

        discounted_epr = discount_rewards(epr)
        discounted_epr -= np.mean(discounted_epr)
        discounted_epr /= np.std(discounted_epr)

        tGrad = sess.run(newGrads, feed_dict={observation: epx, input_y: epy, advantages: discounted_epr})
        for ix, grad in enumerate(tGrad):
            gradBuffer[ix] += grad

        if episode_number % batch_size == 0:
            sess.run(updateGrads, feed_dict={W1Grad: gradBuffer[0], W2Grad: gradBuffer[1]})
            for ix, grad in enumerate(gradBuffer):
                gradBuffer[ix] = grad * 0
            print('Average reward for episode %d: %f.' % (episode_number, reward_sum / batch_size))
            if reward_sum / batch_size > 200:
                print('Task solved in ', episode_number, ' episodes!')

            reward_sum = 0
        observation = env.reset()
```