# DQN


参考：[http://www.cnblogs.com/casperwin/p/6235490.html](http://www.cnblogs.com/casperwin/p/6235490.html)


## MDP（Markov Decision Process）马尔科夫决策过程

一个状态S_t是Markov当且仅当：

```math
P(s_{t+1}|s_t)=P(s_{t+1}|s_t,s_{t-1},...s_1,s_0)
```

即：下一个状态仅取决于当前的状态和当前的动作

回报Return来表示某个时刻t的状态将具备的回报：

```math
G_t = R_{t+1} + \lambda R_{t+2} + ... = \sum_{k=0}^\infty\lambda^kR_{t+k+1}
```

上面R是Reward反馈，λ是discount factor折扣因子，一般小于1，就是说一般当下的反馈是比较重要的，时间越久，影响越小。

那么实际上除非整个过程结束，否则显然我们无法获取所有的reward来计算出每个状态的Return，因此，再引入一个概念价值函数Value Function,用value function v(s)来表示一个状态未来的潜在价值。

从定义上看，value function就是回报的期望：

```math
v(s) = \mathbb E[G_t|S_t = s]
```

引出价值函数，对于获取最优的策略Policy这个目标，我们就会有两种方法：

- 直接优化策略
    ```math
    \pi(a|s)
    ```
    或者
    ```math
    a = \pi(s)
    ```
    使得回报更高
- 通过估计 value function 来间接获得优化的策略。道理很简单，既然我知道每一种状态的优劣，那么我就知道我应该怎么选择了，而这种选择就是我们想要的策略


## Bellman方程

```math
G_t = R_{t+1} + \lambda R_{t+2} + ... = \sum_{k=0}^\infty\lambda^kR_{t+k+1}

v(s) = \mathbb E[G_t|S_t = s]
```

上式展开如下：

```math
 v(s) = \mathbb E[G_t|S_t = s]

      = \mathbb E[R_{t+1}+\lambda R_{t+2} + \lambda ^2R_{t+3} + ...|S_t = s]

      = \mathbb E[R_{t+1}+\lambda (R_{t+2} + \lambda R_{t+3} + ...)|S_t = s]

      = \mathbb E[R_{t+1} + \lambda G_{t+1}|S_t = s]

      = \mathbb E[R_{t+1} + \lambda v(S_{t+1})|S_t = s]
```

因此，

```math
v(s) = \mathbb E[R_{t+1} + \lambda v(S_{t+1})|S_t = s]
```


## Action-Value function 动作价值函数

```math
Q^\pi(s,a) =  \mathbb E[r_{t+1} + \lambda r_{t+2} + \lambda^2r_{t+3} + ... |s,a] = \mathbb E_{s^\prime}[r+\lambda Q^\pi(s^\prime,a^\prime)|s,a]
```

**这里的reward和之前的reward不一样，这里是执行完动作action之后得到的reward，之前state对应的reward则是多种动作对应的reward的期望值**


## Optimal value function 最优价值函数

首先是最优动作价值函数和一般的动作价值函数的关系：

```math
Q^*(s,a) = \max_\pi Q^\pi(s,a)
```

即

```math
Q^*(s,a) = \mathbb E_{s^\prime}[r+\lambda \max _{a^\prime}Q^*(s^\prime,a^\prime)|s,a]
```


## 策略迭代 Policy Iteration

Policy Iteration的目的是通过迭代计算value function 价值函数的方式来使policy收敛到最优。


## 价值迭代 Value Iteration

```math
Q_{i+1}(s,a) = \mathbb E_{s^\prime}[r+\lambda \max_{a^\prime}Q_i(s^\prime,a^\prime)|s,a]
```


## Q-Learning

**Q Learning的思想完全根据value iteration得到**

但要明确一点是value iteration每次都对所有的Q值更新一遍，也就是所有的状态和动作。但事实上在实际情况下我们没办法遍历所有的状态，还有所有的动作，我们只能得到有限的系列样本。因此，只能使用有限的样本进行操作

Q-Learning提出了一种更新Q值的办法：

```math
Q(S_{t},A_{t}) \leftarrow Q(S_{t},A_{t})+\alpha({R_{t+1}+\lambda \max _aQ(S_{t+1},a)} - Q(S_t,A_t))
```

**Q-Learning需要使用某一个policy来生成动作，也就是说这个policy不是优化的那个policy，所以Q-Learning算法叫做Off-policy的算法。另一方面，因为Q-Learning完全不考虑model模型也就是环境的具体情况，只考虑看到的环境及reward，因此是model-free的方法**

policy：

- 随机的生成一个动作
- 根据当前的Q值计算出一个最优的动作，这个policy\pi称之为greedy policy贪婪策略。也就是


## 价值函数近似 Value Function Approximation

价值函数近似即用一个函数来表示Q(s,a)。即

```math
Q(s,a) = f(s,a)
```

f可以是任意类型的函数，比如线性函数：

```math
Q(s,a) = w_1s + w_2a + b
```


## 示例

参考 [https://morvanzhou.github.io/tutorials/machine-learning/reinforcement-learning/4-1-DQN1/](https://morvanzhou.github.io/tutorials/machine-learning/reinforcement-learning/4-1-DQN1/)


RL_brain.py

```python
import tensorflow as tf
import numpy as np


# 为了使用 Tensorflow 来实现 DQN, 比较推荐的方式是搭建两个神经网络,
# target_net 用于预测 q_target 值, 他不会及时更新参数.
# eval_net 用于预测 q_eval, 这个神经网络拥有最新的神经网络参数.
# 不过这两个神经网络结构是完全一样的, 只是里面的参数不一样

class DeepQNetwork:

    def __init__(
            self,
            n_actions,
            n_features,
            learning_rate=0.01,
            reward_decay=0.9,
            e_greedy=0.9,
            replace_target_iter=300,
            memory_size=500,
            batch_size=32,
            e_greedy_increment=None,
            output_graph=False
        ):
        self.n_actions = n_actions
        self.n_features = n_features
        self.lr = learning_rate
        self.gamma = reward_decay
        self.epsilon_max = e_greedy
        self.replace_target_iter = replace_target_iter
        self.memory_size = memory_size
        self.batch_size = batch_size
        self.epsilon_increment = e_greedy_increment
        self.epsilon = 0 if e_greedy_increment is not None else self.epsilon_max

        self.learn_step_counter = 0

        # 初始化全 0 记忆 [s, a, r, s_]
        self.memory = np.zeros((self.memory_size, n_features * 2 + 2))

        self.build_network()

        t_params = tf.get_collection('target_net_params')  # target_net 参数
        e_params = tf.get_collection('eval_net_params')  # eval_net 参数
        self.replace_target_op = [tf.assign(t, e) for t, e in zip(t_params, e_params)]  # 替换 target_net 参数

        self.sess = tf.Session()

        if output_graph:
            # $ tensorboard --logdir=logs
            tf.summary.FileWriter("logs/", self.sess.graph)

        self.sess.run(tf.global_variables_initializer())
        self.cost_his = []  # 记录所有 cost 变化, 用于最后 plot 出来观看

    def store_transition(self, s, a, r, next_s):

        if not hasattr(self, 'memory_counter'):
            self.memory_counter = 0

        transition = np.hstack((s, [a, r], next_s))

        # 总 memory 大小是固定的, 如果超出总大小, 旧 memory 就被新 memory 替换
        index = self.memory_counter % self.memory_size
        self.memory[index, :] = transition  # 替换过程

        self.memory_counter += 1

    def choose_action(self, state):
        # 统一 state 的 shape (1, size_of_state)
        state = state[np.newaxis, :]

        if np.random.uniform() < self.epsilon:  # # 让 eval_net 神经网络生成所有 action 的值, 并选择值最大的 action
            action_value = self.sess.run(self.q_eval, feed_dict={self.s: state})
            action = np.argmax(action_value)
        else:  # 随机选择
            action = np.random.randint(0, self.n_actions)
        return action

    def learn(self):

        if self.learn_step_counter % self.replace_target_iter == 0:
            self.sess.run(self.replace_target_op)  # 替换 target_net 参数
            print('\ntarget_params_replaced\n')

        # 从 memory 中随机抽取 batch_size 这么多记忆
        if self.memory_counter > self.memory_size:
            sample_index = np.random.choice(self.memory_size, size=self.batch_size)
        else:
            sample_index = np.random.choice(self.memory_counter, size=self.batch_size)
        batch_memory = self.memory[sample_index, :]

        # 获取 q_next (target_net 产生了 q) 和 q_eval(eval_net 产生的 q)
        q_next, q_eval = self.sess.run(
            [self.q_next, self.q_eval],
            feed_dict={
                self.s_: batch_memory[:, -self.n_features:],  # fixed params
                self.s: batch_memory[:, :self.n_features]  # newest params
            }
        )
        # 下面这几步十分重要. q_next, q_eval 包含所有 action 的值,
        # 而我们需要的只是已经选择好的 action 的值, 其他的并不需要.
        # 所以我们将其他的 action 值全变成 0, 将用到的 action 误差值 反向传递回去, 作为更新凭据.
        # 这是我们最终要达到的样子, 比如 q_target - q_eval = [1, 0, 0] - [-1, 0, 0] = [2, 0, 0]
        # q_eval = [-1, 0, 0] 表示这一个记忆中有我选用过 action 0, 而 action 0 带来的 Q(s, a0) = -1, 所以其他的 Q(s, a1) = Q(s, a2) = 0.
        # q_target = [1, 0, 0] 表示这个记忆中的 r+gamma*maxQ(s_) = 1, 而且不管在 s_ 上我们取了哪个 action,
        # 我们都需要对应上 q_eval 中的 action 位置, 所以就将 1 放在了 action 0 的位置.

        # 下面也是为了达到上面说的目的, 不过为了更方面让程序运算, 达到目的的过程有点不同.
        # 是将 q_eval 全部赋值给 q_target, 这时 q_target-q_eval 全为 0,
        # 不过 我们再根据 batch_memory 当中的 action 这个 column 来给 q_target 中的对应的 memory-action 位置来修改赋值.
        # 使新的赋值为 reward + gamma * maxQ(s_), 这样 q_target-q_eval 就可以变成我们所需的样子.

        q_target = q_eval.copy()
        batch_index = np.arange(self.batch_size, dtype=np.int32)
        eval_act_index = batch_memory[:, self.n_features].astype(int)  # 记忆里当前 state 采取的 action
        reward = batch_memory[:, self.n_features + 1]  # 对应获得的 reward

        q_target[batch_index, eval_act_index] = reward + self.gamma * np.max(q_next, axis=1)

        # train eval network
        _, self.cost = self.sess.run([self._train_op, self.loss],
                                     feed_dict={self.s: batch_memory[:, :self.n_features],
                                                self.q_target: q_target})
        self.cost_his.append(self.cost)  # 记录 cost 误差

        # increasing epsilon
        self.epsilon = self.epsilon + self.epsilon_increment if self.epsilon < self.epsilon_max else self.epsilon_max

        self.learn_step_counter += 1


    def plot_cost(self):
        import matplotlib.pyplot as plt
        plt.plot(np.arange(len(self.cost_his)), self.cost_his)
        plt.ylabel('Cost')
        plt.xlabel('training steps')
        plt.show()


    def build_network(self):
        """
        两个神经网络是为了固定住一个神经网络 (target_net) 的参数,
        target_net 是 eval_net 的一个历史版本, 拥有 eval_net 很久之前的一组参数,
        而且这组参数被固定一段时间, 然后再被 eval_net 的新参数所替换.
        而 eval_net 是不断在被提升的, 所以是一个可以被训练的网络 trainable=True.
        而 target_net 的 trainable=False.
        """

        # ------------------ build evaluate_net ------------------

        self.s = tf.placeholder(tf.float32, [None, self.n_features], name='s')  # input
        self.q_target = tf.placeholder(tf.float32, [None, self.n_actions], name='Q_target')  # for calculate loss

        with tf.variable_scope('eval_net'):
            # c_names(collections_names) are the collections to store variables
            c_names, n_l1, w_initializer, b_initializer = \
                ['eval_net_params', tf.GraphKeys.GLOBAL_VARIABLES], 10, tf.random_normal_initializer(0., 0.3), tf.constant_initializer(0.1)

            with tf.variable_scope('l1'):
                w1 = tf.get_variable('w1', [self.n_features, n_l1], initializer=w_initializer, collections=c_names)
                b1 = tf.get_variable('b1', [1, n_l1], initializer=b_initializer, collections=c_names)
                l1 = tf.nn.relu(tf.matmul(self.s, w1) + b1)

            with tf.variable_scope('l2'):
                w2 = tf.get_variable('w2', [n_l1, self.n_actions], initializer=w_initializer, collections=c_names)
                b2 = tf.get_variable('b2', [1, self.n_actions], initializer=b_initializer, collections=c_names)
                self.q_eval = tf.matmul(l1, w2) + b2

        with tf.variable_scope('loss'):
            self.loss = tf.reduce_mean(tf.squared_difference(self.q_target, self.q_eval))

        with tf.variable_scope('train'):
            self._train_op = tf.train.RMSPropOptimizer(self.lr).minimize(self.loss)

        # ------------------- build target_net --------------------

        self.s_ = tf.placeholder(tf.float32, [None, self.n_features], name='s_')  # input
        with tf.variable_scope('target_net'):
            # c_names(collections_names) are the collections to store variables
            c_names = ['target_net_params', tf.GraphKeys.GLOBAL_VARIABLES]

            # first layer. collections is used later when assign to target net
            with tf.variable_scope('l1'):
                w1 = tf.get_variable('w1', [self.n_features, n_l1], initializer=w_initializer, collections=c_names)
                b1 = tf.get_variable('b1', [1, n_l1], initializer=b_initializer, collections=c_names)
                l1 = tf.nn.relu(tf.matmul(self.s_, w1) + b1)

            # second layer. collections is used later when assign to target net
            with tf.variable_scope('l2'):
                w2 = tf.get_variable('w2', [n_l1, self.n_actions], initializer=w_initializer, collections=c_names)
                b2 = tf.get_variable('b2', [1, self.n_actions], initializer=b_initializer, collections=c_names)
                self.q_next = tf.matmul(l1, w2) + b2
```

demo.py

```python
from maze_env import Maze
from RL_brain import DeepQNetwork


def run_maze():
    step = 0
    for episode in range(300):
        # initial state
        state = env.reset()

        while True:
            # fresh env
            env.render()

            # RL choose action based on state
            action = RL.choose_action(state)

            # RL take action and get next state and reward
            next_state, reward, done = env.step(action)

            RL.store_transition(state, action, reward, next_state)

            if (step > 200) and (step % 5 == 0):
                RL.learn()

            # swap state
            state = next_state

            # break while loop when end of this episode
            if done:
                break
            step += 1

    # end of game
    print('game over')
    env.destroy()


if __name__ == "__main__":
    # maze game
    env = Maze()
    RL = DeepQNetwork(env.n_actions, env.n_features,
                      learning_rate=0.01,
                      reward_decay=0.9,
                      e_greedy=0.9,
                      replace_target_iter=200,
                      memory_size=2000,
                      # output_graph=True
                      )
    env.after(100, run_maze)
    env.mainloop()
    RL.plot_cost()
```

maze_env.py

```python
"""
Reinforcement learning maze example.
Red rectangle:          explorer.
Black rectangles:       hells       [reward = -1].
Yellow bin circle:      paradise    [reward = +1].
All other states:       ground      [reward = 0].
This script is the environment part of this example.
The RL is in RL_brain.py.
View more on my tutorial page: https://morvanzhou.github.io/tutorials/
"""
import numpy as np
import time
import sys
if sys.version_info.major == 2:
    import Tkinter as tk
else:
    import tkinter as tk

UNIT = 40   # pixels
MAZE_H = 4  # grid height
MAZE_W = 4  # grid width


class Maze(tk.Tk, object):
    def __init__(self):
        super(Maze, self).__init__()
        self.action_space = ['u', 'd', 'l', 'r']
        self.n_actions = len(self.action_space)
        self.n_features = 2
        self.title('maze')
        self.geometry('{0}x{1}'.format(MAZE_H * UNIT, MAZE_H * UNIT))
        self._build_maze()

    def _build_maze(self):
        self.canvas = tk.Canvas(self, bg='white',
                           height=MAZE_H * UNIT,
                           width=MAZE_W * UNIT)

        # create grids
        for c in range(0, MAZE_W * UNIT, UNIT):
            x0, y0, x1, y1 = c, 0, c, MAZE_H * UNIT
            self.canvas.create_line(x0, y0, x1, y1)
        for r in range(0, MAZE_H * UNIT, UNIT):
            x0, y0, x1, y1 = 0, r, MAZE_H * UNIT, r
            self.canvas.create_line(x0, y0, x1, y1)

        # create origin
        origin = np.array([20, 20])

        # hell1
        hell1_center = origin + np.array([UNIT * 2, UNIT])
        self.hell1 = self.canvas.create_rectangle(
            hell1_center[0] - 15, hell1_center[1] - 15,
            hell1_center[0] + 15, hell1_center[1] + 15,
            fill='black')
        # hell2
        hell2_center = origin + np.array([UNIT, UNIT * 2])
        self.hell2 = self.canvas.create_rectangle(
            hell2_center[0] - 15, hell2_center[1] - 15,
            hell2_center[0] + 15, hell2_center[1] + 15,
            fill='black')

        # create oval
        oval_center = origin + UNIT * 2
        self.oval = self.canvas.create_oval(
            oval_center[0] - 15, oval_center[1] - 15,
            oval_center[0] + 15, oval_center[1] + 15,
            fill='yellow')

        # create red rect
        self.rect = self.canvas.create_rectangle(
            origin[0] - 15, origin[1] - 15,
            origin[0] + 15, origin[1] + 15,
            fill='red')

        # pack all
        self.canvas.pack()

    def reset(self):
        self.update()
        time.sleep(0.1)
        self.canvas.delete(self.rect)
        origin = np.array([20, 20])
        self.rect = self.canvas.create_rectangle(
            origin[0] - 15, origin[1] - 15,
            origin[0] + 15, origin[1] + 15,
            fill='red')
        # return observation
        return (np.array(self.canvas.coords(self.rect)[:2]) - np.array(self.canvas.coords(self.oval)[:2]))/(MAZE_H*UNIT)

    def step(self, action):
        s = self.canvas.coords(self.rect)
        base_action = np.array([0, 0])
        if action == 0:   # up
            if s[1] > UNIT:
                base_action[1] -= UNIT
        elif action == 1:   # down
            if s[1] < (MAZE_H - 1) * UNIT:
                base_action[1] += UNIT
        elif action == 2:   # right
            if s[0] < (MAZE_W - 1) * UNIT:
                base_action[0] += UNIT
        elif action == 3:   # left
            if s[0] > UNIT:
                base_action[0] -= UNIT

        self.canvas.move(self.rect, base_action[0], base_action[1])  # move agent

        next_coords = self.canvas.coords(self.rect)  # next state

        # reward function
        if next_coords == self.canvas.coords(self.oval):
            reward = 1
            done = True
        elif next_coords in [self.canvas.coords(self.hell1)]:
            reward = -1
            done = True
        else:
            reward = 0
            done = False
        s_ = (np.array(next_coords[:2]) - np.array(self.canvas.coords(self.oval)[:2]))/(MAZE_H*UNIT)
        return s_, reward, done

    def render(self):
        # time.sleep(0.01)
        self.update()
```