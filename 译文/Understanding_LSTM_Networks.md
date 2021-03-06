# 理解LSTM网络

（原文：[Understanding LSTM Networks](http://colah.github.io/posts/2015-08-Understanding-LSTMs/))

## 循环神经网络

人类不是每一秒都开始思考。正如你现在正在阅读的这篇文章，你对每一个字词的理解，都是建立在对于之前字词的理解的基础之上的。你不需要抛开之前阅读的内容，再从看到的每个字词开始开始思考。你的思维是有一定的持久性的。

传统的神经网络不能做到像这样思考，这是其一个主要的缺点。例如，想象你正在对于一部电影的每一时刻发生的事件进行分类，传统的神经网络不懂得用之前的事件去推理之后的事件。

循环神经网络解决了这个问题，它是一种带有循环并允许信息持久记忆的一种网络。

![image](../images/RNN-rolled.png)

在上面的图中，一个神经网络区域 A，接收到输入 xt 然后输出 ht。其中的循环允许信息从神经网络的某一步传递到下一步。

这些循环正是循环神经网络的关键神奇之处。然而，如果你更深入的想一下，它其实和正常的神经网络没有什么区别。一个循环神经网络可以被认为是许多相同的神经网络串联在一起，每一个神经网络传递信息给下一个神经网络。如果我们展开循环就像这样：

![image](../images/RNN-unrolled.png)

这个链式结构揭示出循环神经网络和序列和列表密切相关。他们处理这类数据结构的最自然的选择。

他们确实被广泛应用，在最近的几年中，应用RNN处理一系列问题取得了难以置信的成功，诸如：语音识别、语言模型、翻译、图片注释等。

取得这些成功至关重要的一点就是 LSTMs 的应用，一种特殊的循环神经网络。LSTM在许多问题上，表现的比标准的 RNN 更加出色。几乎所有基于 RNN 的结果都是用 LSTMs 实现的，LSTMs 正是本文要讨论的。


## 长期以来的难题

LSTMs 的一个魅力就在于他们可以将之前的信息和当前的进行关联，如对当前帧处理时会参照对视频中之前的每一帧。如果 RNN 如果能做到这些，将会非常有用，但是他们能吗？答案是，是情况而定。

有时，我们仅需要参考最近的信息，例如：假设一个语言模型尝试在之前单词的基础上预测下一个单词，如果我们尝试预测 "the cloud in the sky" 这句话的最后一个单词时，我们不需要太多的上下文，因为显然下一个单词是 "sky"。这种情况下，待预测位置和相关联位置之间的距离不能太大，RNN 可以通过过往的信息去学习。

![image](../images/RNN-shorttermdepdencies.png)

但是有一些情况，我们需要更多的上下文。假设尝试预测 "I grew up in the France... I speak fluent French." 这句话的最后一个单词时，最近的信息表明下一个单词很有可能是一门语言的名字，但是如果我们想确定具体时哪一门语言时，我们需要关于 "French" 上下文，或者更远的上下文。很有可能相关信息和待预测信息之间的距离是非常大的。

不幸的是，随着距离的增加，RNN 不能通过之前的信息去进行有效的学习。

![image](../images/RNN-longtermdependencies.png)

从理论上讲，RNN 绝对有能力处理任何 “长期依赖”问题。人类可以选择性的给予 RNN 正确的参数，是他们具有解决这类问题的能力。但是，实践中，RNN 似乎不能够学习到这些，这个问题被 Hochreiter 和 Benigo 更加深入的讨论，他们发现了能够证明这种情况是非常困难的一些基础论据。

非常幸运，LSTM 没有这样的问题。


## LSTM 网络

长短期记忆网络——通常被称为 LSTM ，是一种可以解决长期依赖问题的特殊的循环神经网络。LSTM最初由 Hochreiter & Schmidhuber 提出，然后被人们在接下来的一些工作中被重新定义并逐渐流行。LSTM在很多问题上表现很好，现在被广泛应用。

LSTM 被明确设计为，为了避免长期依赖问题。能够记忆长期信息是其默认行为，并不需要通过特殊的学习。

所有的循环神经网络是链式的重复模块的形式，在标准的 RNN 中，这些重复的模块的结构非常简单，比如一个简单的 tanh 层。

![image](../images/LSTM3-SimpleRNN.png)

LSTM 同样具有链式的结构，但是这些重复的模块有着不同的结构，不是单独的一层神经网络，而是四层，以一个特殊的方式结合在一起。

![image](../images/LSTM3-chain.png)

不必担心接下来的一些细节，我们将会沿着 LSTM 的图示结构一步一步说明。现在， 让我们熟悉一下我们将要使用的图例。

![image](../images/LSTM2-notation.png)

在上面的图中，每条线代表 一个向量的传输方向，从一个节点的输出到另一个节点的输入；粉色的圆代表一个操作，如向量加法；而黄色的盒子代表神经网络层。线的合并，代表向量连接，而线的分支代表向量的内容被复制，并分别沿着不同方向传播。


## LSTM 背后的核心思路

LSTM 的关键是神经元的状态，即图中上方的水平方向的线。

神经元的状态，就像一个传送带，沿着整条链的方向传播，只有少数一些线性运算。信息不经改变的沿着这条线传播。

![image](../images/LSTM3-C-line.png)

LSTM 通过一些被称为“门”的结构，实现去除或增加一些信息。

“门”是一种让信息选择性通过的方式，他们由一个 sigmoid 神经网络层和一个乘法运算组成。

![image](../images/LSTM3-gate.png)

sigmoid 层输出 0 到 1 之间的数，描述了信息的各部分分别应当通过多少。0 值代表不让任何信息通过，1 值代表让所有的信息通过。

一个 LSTM 网络有三个类似这样的“门”，去保护和控制神经元的状态。


## 一步一步沿着 LSTM 详解

LSTM 的第一步是决定哪些信息应当从神经元状态中被去掉。这一步由一个被称为“遗忘门”的 sigmoid 层实现。“遗忘门”接受 h_t-1 和 xt 作为输入，然后为神经元状态的每一位分别输出一个 0 到 1 之间的数。1 代表“完全保存”，0 代表“完全遗忘”。

让我们回到我们的通过之前的单词来预测下一个单词的语言模型的例子当中。在这个问题当中，神经元状态可能包含了当前主语的性别，从而使用正确的单词形式。当我们看到一个新的主语的时候，我们需要忘记之前的主语的性别。

![image](../images/LSTM3-focus-f.png)

下一步就是决定哪些新的信息我们打算在神经元状态中保存下来。这分为两步，首先，一个被称为“第一输入门” sigmoid 层决定哪些值我们想要更新，接下来，一个 tanh 层创建一个可能被添加到状态中的新的候选向量 Ct 。下一步中，我们将要将这两步结合在一起来更新神经元状态。

在我们的语言模型的例子中，我们想要把新主语的性别加入到状态中，去代替我们计划遗忘的旧主语的性别。

![image](../images/LSTM3-focus-i.png)

现在是时候去更新旧的神经元状态 C_t-1 为新的状态 Ct 了。前一步已经决定了哪些更新，所以这一步我们只需要实际执行决定即可。

我们将旧的状态乘以 ft，以遗忘那些我们决定遗忘的信息。然后我们加上 it * Ct，这是新的候选值，乘以一个代表我们对每一个状态值决定更新多少的系数。

在我们的语言模型的例子中，这就是我们真正丢弃旧主语的性别，然后记住新主语的性别的地方。

![image](../images/LSTM3-focus-C.png)

最后，我们需要决定哪些我们要输出。这个输出必须基于我们的神经元状态，但是会通过一个过滤器过滤。首先，我们运行一个决定将要输出哪一部分状态的 sigmoid 层，然后，我们把神经元状态通过一个 tanh （把数值置为 -1 到 1 之间），然后让它乘以 sigmoid “门”的输出，从而我们只输出我们想要输出的部分。

以我们的语言模型为例，因为它只看到一个主语，他可能想要反应一个相关信息到一个动词上。例如，它可能输出一个主语是单数还是负数，从而我们知道，如何给动词变形。