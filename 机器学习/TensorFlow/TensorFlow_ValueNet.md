# TensorFlow —— Value Net

几个 state of art 的 Trick：

1. 引入卷积，用来抽取空间结构特征，让模型有能力通过视频图像了解环境信息并学习策略
2. `Experience Replay`：存储 Agent 的 Experience （即样本）并且每次训练随机抽取一部份样本供给网络学习。避免只是短视的学习到最新接触的技术，而是综合反复的利用国外的大量样本进行学习。
3. `target DQN`：前一个 DQN 用来制造学习目标，这一层 DQN 用来学习 Q 值，进行实际训练。拆分为两个 DQN 的目的为：避免因为学习目标每次变化而导致模型难以收敛。
4. `Double DQN`：避免传统的 DQN 会高估某些 Action 的 Q 值，某些 Action 被高估而超过了最优的 Action ，导致永远也发现不了最优的 Action。因而令 target DQN 完全负责产生目标 Q 值，即先产生 Q(s_t+1, a)，再通过 Max 选择最大的 Q 值；Double DQN 这是修改了第二步，不是直接选择 target DQN 产生的最大的 Q，而是在主 DQN 上通过最大 Q 值选择 Action，再去获取这个 Action 在 target DQN 上的 Q 值
5. `Dueling DQN`：将 Q 值拆分为两部分

    ```
    Q(s_t, a_t) = V(s_t) + A(a_t)
    ```


（参看《TensorFlow》实战一书实现）

```python
import numpy as np
import tensorflow as tf
import random
import itertools
import scipy.misc
import matplotlib.pyplot as plt
import os

batch_size = 32
update_freq = 4
y = .99
startE = 1
endE = 0.1
anneling_steps = 10000
num_episodes = 10000
pre_train_steps = 10000
max_epLength = 50
load_model = False
path = "./dqn"
h_size = 512
tau = 0.001

# 环境内物体的对象
class gameOb():

    def __init__(self, coordinate, size, intensity, channel, reward, name):
        """
        :param coordinate: x, y坐标
        :param size: 尺寸
        :param intensity: 亮度值
        :param channel: RGB 颜色通道
        :param reward: 奖励值
        :param name: 名称
        """
        self.x = coordinate[0]
        self.y = coordinate[1]
        self.size = size
        self.intensity = intensity
        self.channel = channel
        self.reward = reward
        self.name = name


# GridWorld 环境的类
class gameEnv():

    def __init__(self, size):
        self.sizeX = size # 环境的宽
        self.sizeY = size # 环境的高
        self.actions = 4 # Action Space 设为 4
        self.objects = [] # 环境对象物体的列表
        a = self.reset() # 重置环境
        plt.imshow(a, interpolation="nearest")

    # 创建 GirdWorld 中的物体，包括 1 个 hero、4 个 goal（reward 为 1）、2 个 fire（reward 为 -1）
    # hero 的 channel 为 2（蓝色），goal 的 channel 为 1（绿色），fire 的 channel 为 0（红色）
    def reset(self):
        self.objects = []
        hero = gameOb(self.newPosition(), 1, 1, 2, None, 'hero')
        self.objects.append(hero)
        goal = gameOb(self.newPosition(), 1, 1, 1, 1, 'goal')
        self.objects.append(goal)
        hole = gameOb(self.newPosition(), 1, 1, 0, -1, 'hole')
        self.objects.append(hole)
        goal2 = gameOb(self.newPosition(), 1, 1, 1, 1, 'goal')
        self.objects.append(goal2)
        hole2 = gameOb(self.newPosition(), 1, 1, 0, -1, 'hole')
        self.objects.append(hole2)
        goal3 = gameOb(self.newPosition(), 1, 1, 1, 1, 'goal')
        self.objects.append(goal3)
        goal4 = gameOb(self.newPosition(), 1, 1, 1, 1, 'goal')
        self.objects.append(goal4)
        state = self.renderEnv()
        self.state = state
        return state

    # 移动 hero
    def moveChar(self, direction):
        hero = self.objects[0]
        heroX = hero.x
        heroY = hero.y
        # 上移
        if direction == 0 and hero.y >= 1:
            hero.y -= 1
        # 下移
        if direction == 1 and hero.y <= self.sizeY - 2:
            hero.y += 1
        # 左移
        if direction == 2 and hero.x >= 1:
            hero.x -= 1
        # 右移
        if direction == 3 and hero.x <= self.sizeX - 2:
            hero.x += 1
        self.objects[0] = hero

    # 选择一个跟现有物体不冲突的位置
    def newPosition(self):
        iterables = [range(self.sizeX), range(self.sizeY)]
        points = []
        # 所有的坐标位置组合
        for t in itertools.product(*iterables):
            points.append(t)
        currentPositions = []
        # 现有已经被物体占据的位置
        for objectA in self.objects:
            if (objectA.x, objectA.y) not in currentPositions:
                currentPositions.append((objectA.x, objectA.y))
        # 除去不可用的位置
        for pos in currentPositions:
            points.remove(pos)
        # 从可以用的位置，随机选择一个
        location = np.random.choice(range(len(points)), replace=False)
        return points[location]

    # 检查 hero 是否碰触的到了 fire 或者 goal
    def checkGoal(self):
        others = []
        for obj in self.objects:
            if obj.name == 'hero':
                hero = obj
            else:
                others.append(obj)
        for other in others:
            if hero.x == other.x and hero.y == other.y:
                self.objects.remove(other)
                if other.reward == 1:
                    self.objects.append(gameOb(self.newPosition(), 1, 1, 1, 1, 'goal'))
                else:
                    self.objects.append(gameOb(self.newPosition(), 1, 1, 0, -1, 'fire'))
                return other.reward, False
        return 0.0, False

    def renderEnv(self):
        a = np.ones([self.sizeY + 2, self.sizeX + 2, 3])
        a[1:-1,1:-1,:] = 0
        hero = None
        for item in self.objects:
            a[item.y + 1 : item.y + item.size + 1, item.x + 1 : item.x + item.size + 1, item.channel] = item.intensity
        b = scipy.misc.imresize(a[:,:,0], [84, 84, 1], interp='nearest')
        c = scipy.misc.imresize(a[:,:,1], [84, 84, 1], interp='nearest')
        d = scipy.misc.imresize(a[:,:,2], [84, 84, 1], interp='nearest')
        a = np.stack([b, c, d], axis=2)
        return a

    def step(self, action):
        self.moveChar(action)
        reward, done = self.checkGoal()
        state = self.renderEnv()
        return state, reward, done

env = gameEnv(size=5)

class Qnetwork():
    def __init__(self, h_size):
        # 84x84x3 = 21168
        self.scalarInput = tf.placeholder(shape=[None, 21168], dtype=tf.float32)
        self.imageIn = tf.reshape(self.scalarInput, shape=[-1, 84, 84, 3]) # 84x84x3
        self.conv1 = tf.contrib.layers.convolution2d(
            inputs=self.imageIn, num_outputs=32,
            kernel_size=[8, 8], stride=[4, 4], padding='VALID', biases_regularizer=None) # 20x20x32
        self.conv2 = tf.contrib.layers.convolution2d(
            inputs=self.conv1, num_outputs=64,
            kernel_size=[4, 4], stride=[2, 2], padding='VALID', biases_regularizer=None) # 9x9x64
        self.conv3 = tf.contrib.layers.convolution2d(
            inputs=self.conv2, num_outputs=64,
            kernel_size=[3, 3], stride=[1, 1], padding='VALID', biases_regularizer=None) # 7x7X64
        self.conv4 = tf.contrib.layers.convolution2d(
            inputs=self.conv3, num_outputs=512,
            kernel_size=[7, 7], stride=[1, 1], padding='VALID', biases_regularizer=None) # 1x1x512

        # tf.split 将 self.conv4 拆分成 2 段，拆分的是第 3 个维度
        # self.streamAC 代表 Advantage Function （Action 带来的价值）
        # self.streamVC 代表 Value Function （环境本身的价值）
        self.streamAC, self.streamVC = tf.split(self.conv4, 2, 3)
        # 转化为扁平的 self.streamA 和 self.streamV
        self.streamA = tf.contrib.layers.flatten(self.streamAC)
        self.streamV = tf.contrib.layers.flatten(self.streamVC)
        # 线性全连接层
        self.AW = tf.Variable(tf.random_normal([h_size//2, env.actions]))
        self.VW = tf.Variable(tf.random_normal([h_size//2, 1]))
        self.Advantage = tf.matmul(self.streamA, self.AW)
        self.Value = tf.matmul(self.streamV, self.VW)

        # Q 值
        self.Qout = self.Value + tf.subtract(self.Advantage, tf.reduce_mean(
            self.Advantage, reduction_indices=1, keep_dims=True))
        self.predict = tf.argmax(self.Qout, 1)
        self.targetQ = tf.placeholder(shape=[None], dtype=tf.float32)
        self.actions = tf.placeholder(shape=[None], dtype=tf.float32)
        self.actions_onehot = tf.one_hot(self.actions, env.actions, dtype=tf.float32)
        self.Q = tf.reduce_sum(tf.multiply(self.Qout, self.actions_onehot), reduction_indices=1)

        # 定义 loss
        self.td_error = tf.square(self.targetQ - self.Q)
        self.loss = tf.reduce_mean(self.td_error)
        self.trainer = tf.train.AdamOptimizer(learning_rate=0.0001)
        self.updateModel = self.trainer.minimize(self.loss)


class experience_buffer():

    def __init__(self, buffer_size=50000):
        self.buffer = []
        self.buffer_size = buffer_size

    def add(self, experience):
        if len(self.buffer) + len(experience) >= self.buffer_size:
            self.buffer[0:(len(experience) + len(self.buffer)) - self.buffer_size] = []
        self.buffer.extend(experience)

    def sample(self, size):
        return np.reshape(np.array(random.sample(self.buffer, size)), [size, 5])


# 把 84x84x3 的 states 扁平化为 1 维
def processState(states):
    return np.reshape(states, [21168])

# 创建更新 target DQN 模型参数的操作
def updateTargetGraph(tfVars, tau):
    total_vars = len(tfVars)
    op_holder = []
    for idx, var in enumerate(tfVars[0:total_vars//2]):
        op_holder.append(tfVars[idx + total_vars//2].assign((var.value() * tau) + ((1 - tau) * tfVars[idx + total_vars//2].value())))
    return op_holder

def updateTarget(op_holder, sess):
    for op in op_holder:
        sess.run(op)

mainQN = Qnetwork(h_size)
targetQN = Qnetwork(h_size)

trainables = tf.trainable_variables()
targetOps = updateTargetGraph(trainables, tau)

myBuffer = experience_buffer()
e = startE
stepDrop = (startE - endE) / anneling_steps

rList = []
total_steps = 0

saver = tf.train.Saver()
if not os.path.exists(path):
    os.makedirs(path)

with tf.Session() as sess:
    if load_model == True:
        print('Loading Model...')
        ckpt = tf.train.get_checkpoint_state(path)
        saver.restore(sess, ckpt.model_checkpoint_path)

    tf.initialize_all_variables().run()
    updateTarget(targetOps, sess)
    for i in range(num_episodes + 1):
        episodeBuffer = experience_buffer()
        s = env.reset()
        s = processState()
        d = False
        rAll = 0
        j = 0

        while j < max_epLength:
            j += 1
            if np.random.rand(1) < e or total_steps < pre_train_steps:
                a = np.random.randint(0, 4)
            else:
                a = sess.run(mainQN.predict, feed_dict={mainQN.scalarInput: [s]})[0]
            s1, r, d = env.step(a)
            s1 = processState(s1)
            total_steps += 1
            episodeBuffer.add(np.reshape(np.array([s, a, r, s1, d]), [1, 5]))

            if total_steps > pre_train_steps:
                if e > endE:
                    e -= stepDrop
                if total_steps % (update_freq) == 0:
                    trainBatch = myBuffer.sample(batch_size)
                    A = sess.run(mainQN.predict, feed_dict={mainQN.scalarInput: np.vstack(trainBatch[:,3])})
                    Q = sess.run(targetQN.Qout, feed_dict={targetQN.scalarInput: np.vstacj(trainBatch[:,3])})
                    doubleQ = Q[range(batch_size), A]
                    targetQ = trainBatch[:,2] + y * doubleQ
                    _ = sess.run(mainQN.updateModel, feed_dict={
                        mainQN.scalarInput: np.vstack(trainBatch[:,0]),
                        mainQN.targetQ: targetQ,
                        mainQN.actions: trainBatch[:,1]
                    })
                    updateTarget(targetOps, sess)

            rAll += r
            s = s1

            if d == True:
                break

        myBuffer.add(episodeBuffer.buffer)
        rList.append(rAll)
        if i > 0 and i % 25 == 0:
            print('episode ', i, ', average reward of last 25 episodes ', np.mean(rList[-25:]))
        if i > 0 and i % 1000 == 0:
            saver.save(sess, path + '/model-' + str(i) + '.ckpt')
            print('Saved Model')

    saver.save(sess, path + '/model-' + str(i) + '.ckpt')
```
