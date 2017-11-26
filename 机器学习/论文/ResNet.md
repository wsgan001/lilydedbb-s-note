# Deep Residual Learning for Image Recognition


> Driven by the significance of depth, a question arises: *Is
learning better networks as easy as stacking more layers?*
An obstacle to answering this question was the notorious problem of vanishing/exploding gradients, which hamper convergence from the beginning. This problem, however, has been largely addressed by normalized initialization and intermediate normalization layers, which enable networks with tens of layers to start converging for stochastic gradient descent (SGD) with back-propagation.


Formally, denoting the desired underlying mapping as `H(x)`, we let the stacked nonlinear layers fit another mapping of

```math
F (x) := H(x) - x
```

The original mapping is recast into

```math
F(x) + x
```

The formulation of `F(x) + x` can be realized by feedforward neural networks with "shortcut connections". **Shortcut connections are those skipping one or more layers**. In our case, the shortcut connections simply perform **identity mapping**, and their outputs are added to the output of stacked layers. **Identity shortcut connections add neither extra parameter nor computational complexity.** The entire network can still be trained end-to-end by SGD with backpropagation, and can be eas- ily implemented using common libraries (e.g., Caffe [19]) without modifying the solvers.


## Deep Residual Learning

### Residual Learning

> So rather than expect stacked layers to approximate `H(x)`, we explicitly let these layers approximate a residual function `F(x) := H(x) − x`. The original function thus becomes `F(x)+x`. Although both forms should be able to asymptotically approximate the desired functions (as hypothesized), the ease of learning might be different.

### Identity Mapping by Shortcut

Build block defined as:

```math
y = F(x, \{W_i\}) + x
```

Here `x` and `y` are the input and output vectors of the layers considered. The function `F(x, {Wi})` represents the residual mapping to be learned.

We can fairly compare plain/residual networks that simultaneously have the same number of parameters, depth, width, and computa- tional cost (except for the negligible element-wise addition).

**Note:** The dimensions of `x` and `F` must be equal. If this is not the case (e.g., when changing the input/output channels), we can perform a linear projection `Ws` by the shortcut connections to match the dimensions:

```math
y = F(x, \{W_i\}) + W_sx
```

> The form of the residual function F is flexible. Experiments in this paper involve a function F that has two or three layers (Fig. 5), while more layers are possible. But if F has only a single layer, Eqn.(1) is similar to a linear layer: y = W1 x + x, for which we have not observed advantages.

**The function F(x,{Wi}) can also represent multiple convolutional layers. The element-wise addition is performed on two feature maps, channel by channel.**

### Network Architecture

![image](http://upload-images.jianshu.io/upload_images/145616-a35e6a6a37fa7712.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

Based on the above plain network, we insert shortcut connections which turn the network into its counterpart residual version. The identity shortcuts can be directly used when the input and output are of the same dimensions (solid line shortcuts). When the dimensions increase (dotted line shortcuts), we consider two options:

1. The shortcut still performs identity mapping, with extra zero entries padded for increasing dimensions. This option introduces no extra paramater
2. The projection shortcut is used to match dimensions.


## Experiments

### Identity vs. Projection Shortcuts

(A) zero-padding shortcuts are used for increasing dimensions, and all shortcuts are parameter-free;

(B) projec- tion shortcuts are used for increasing dimensions, and other shortcuts are identity;

(C) all shortcuts are projections.

B is slightly better than A. We argue that this is because the zero-padded dimensions in A indeed have no residual learning. C is marginally better than B, and we attribute this to the extra parameters introduced by many (thirteen) projection shortcuts.


------

参考：[http://www.jianshu.com/p/f71ba99157c7](http://www.jianshu.com/p/f71ba99157c7)

## 对ResNet的解读

基本的残差网络其实可以从另一个角度来理解，这是从另一篇论文里看到的，如下图所示：

![image](http://img.blog.csdn.net/20161125155120022)

残差网络单元其中可以分解成右图的形式，从图中可以看出，残差网络其实是由多种路径组合的一个网络，直白了说，残差网络其实是很多并行子网络的组合，整个残差网络其实相当于一个多人投票系统（Ensembling）。
