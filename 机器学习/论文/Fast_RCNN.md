# Fast R-CNN


## drawbacks of R-CNN

1. training is a multi-stage pipeline:
    - fine-tune a ConvNet on object proposals using log loss.
    - fit SVMs to ConvNer features (SVMs replace the softmax classifier learnt by fine-tuning)
    - bounding-box regressors are learned

2. Training is expensive in space and time
3. Object detection is slow


## drawbacks of SPP-net

training is a multi-stage pipeline:
- extracting features and fine-tuning a network with log loss
- training SVMs
- fitting bounding-box regressors

> But unlike R-CNN, the fine-tuning algorithm proposed in [11] cannot update the convolutional layers that precede the spatial pyramid pooling. Unsurprisingly, this limitation (fixed convolutional layers) limits the accuracy of very deep networks.


## Fast R-CNN architecture

1. An input image and multiple regions of interest (RoIs) are input into a fully convolutional network.
2. Each RoI is pooled into a fixed-size feature map and then mapped to a feature vector by FCs
3. output two vectors per PoI: softmax probabilities and per-class bounding-box regression offsets
4. The architecture is trained end-to-end with a multi-task loss


## The RoI pooling layer

> The RoI layer is simply the special-case of the spatial pyramid pooling layer used in SPPnets [11] in which there is only one pyramid level.

RoI max pooling works by dividing the h × w RoI window into an H × W grid of sub-windows of approximate size h/H × w/W and then max-pooling the values in each sub-window into the corresponding output grid cell.


## Initializing from pre-trained networks

use a pre-trained network initializes a Fast R-CNN network, and then make three transformations:

1. the last max pooling layer is replaced by a RoI pooling layer that is configured by setting H and W to be compatible with the net's first fully connected layer. (H = W = 7 for VGG16)
2. FC layer is replaced with FC layer and two sibling layers:
    1. softmax over K + 1 categories
    2. category-specific bounding-box regressors
3. the network is modified to take two data inputs: a list of images and a list of RoIs in those images.


## Fine-tuning for detection

In Fast R- CNN training, stochastic gradient descent (SGD) mini- batches are sampled hierarchically, first by sampling N images and then by sampling R/N RoIs from each image.

In addition to hierarchical sampling, Fast R-CNN uses a streamlined training process with one fine-tuning stage that jointly optimizes a softmax classifier and bounding-box regressors, rather than training a softmax classifier, SVMs, and regressors in three separate stages.

### Multi-task loss

A Fast R-CNN network has two sibling output layers.
1. The first outputs a discrete probability distribution(perRoI),p=(p0,...,pK),overK+1categories. As usual, p is computed by a softmax over the K +1 outputs of a fully connected layer.
2. The second sibling layer outputs bounding-box regression offsets, tk = (tkx , tky , tkw , tkh), for each of the K object classes, indexed by k.

multi-task loss L:

L(p, u, tu, v) = Lcls(p, u) + λ[u ≥ 1]Lloc(tu, v), （u is ground-truth class and v is ground-truth bounding-box regression target）

For bounding-box regression, we use the loss:

Lloc(tu,v)=∑i∈x,y,w,hsmmothL1(tui−vi)

The RoI pooling layer’s backwards function computes partial derivative of the loss function with respect to each input variable xi by following the argmax switches:

∂L/∂xi = ∑r∑j [i=i∗(r,j)] ∂L/∂yrj .


## Scale invariance

We explore two ways of achieving scale invariant object detection:

1. via “brute force” learning
2. by using image pyramids


## Truncated SVD for faster detection


参考: [http://liliangzhang.com/2015/05/17/paper-note-fast-rcnn/](http://liliangzhang.com/2015/05/17/paper-note-fast-rcnn/)

参考：[http://blog.csdn.net/shenxiaolu1984/article/details/51036677](http://blog.csdn.net/shenxiaolu1984/article/details/51036677)

------


SPPnet基于RCNN做改进，它主要有2个亮点：

原图不用resize到统一大小，可直接输入网络，避免失真。因为CNN限制输入的size主要是因为全连接层的结点数是固定的，卷积层是无所谓的，所以在SPPnet中，对最后一个卷积层的结果做固定尺度（如1×1, 2×2, 4×4）的spatial pooling，使得全连接层结点数固定。

不用对原图的多个互相重叠的proposal各自计算CNN特征，只需对原图计算CNN特征，然后将原图proposal的位置映射到特征图上即可。

Faster CNN借鉴了这两点，并且为了整合检测pipeline，将object classification和spatial location都整合到一个网络中，使得它们可以协同地训练。
