# Double DQN

DQN 的神经网络部分可以看成一个 最新的神经网络 + 老神经网络, 他们有相同的结构, 但内部的参数更新却有时差. 而它的 `Q现实` 部分是这样的:

![image](https://morvanzhou.github.io/static/results/reinforcement-learning/4-5-1.png)

因为我们的神经网络预测 `Qmax` 本来就有误差, 每次也向着最大误差的 `Q现实` 改进神经网络, 就是因为这个 `Qmax` 导致了 overestimate. 所以 `Double DQN` 的想法就是引入另一个神经网络来打消一些最大误差的影响. 而 DQN 中本来就有两个神经网络, 我们何不利用一下这个地理优势呢. 所以, 我们用 `Q估计` 的神经网络估计 `Q现实` 中 `Qmax(s', a')` 的最大动作值. 然后用这个被 `Q估计` 估计出来的动作来选择 `Q现实` 中的 `Q(s')`. 总结一下:

有两个神经网络: `Q_eval` (Q估计中的), `Q_next` (Q现实中的).

原本的 **`Q_next = max(Q_next(s', a_all))`**.

`Double DQN` 中的 **`Q_next = Q_next(s', argmax(Q_eval(s', a_all)))`**. 也可以表达成下面那样.

![image](https://morvanzhou.github.io/static/results/reinforcement-learning/4-5-2.png)

修改 `learn()` 中的代码:（接上一篇）

```python
# 与普通 DQN 不同
        q_next, q_eval4next = self.sess.run(
            [self.q_next, self.q_eval],
            feed_dict={
                self.s_: batch_memory[:, -self.n_features:],  # next state
                self.s: batch_memory[:, -self.n_features:]  # next state
            }
        )
        q_eval = self.sess.run(self.q_eval, feed_dict={self.s: batch_memory[:, self.n_features]})

        q_target = q_eval.copy()
        batch_index = np.arange(self.batch_size, dtype=np.int32)
        eval_act_index = batch_memory[:, self.n_features].astype(int)  # 记忆里当前 state 采取的 action
        reward = batch_memory[:, self.n_features + 1]  # 对应获得的 reward

        max_act4next = np.argmax(q_eval4next, axis=1)  # q_eval 得出的最高奖励动作
        selected_q_next = q_next[batch_index, max_act4next]  # Double DQN 选择 q_next 依据 q_eval 选出的动作
```


