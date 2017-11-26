# Faster R-CNN: Towards Real-Time Object Detection with Region Proposal Networks


> Fast R-CNN, achieves near real-time rates using very deep networks, when ignoring the time spent on region proposals. Now, proposals are the test-time computational bottleneck in state-of-the-art detection systems.

> Our observation is that the convolutional feature maps used by region-based detectors, like Fast R-CNN, can also be used for generating region proposals. On top of these convolutional features, we construct an RPN by adding a few additional convolutional layers that simultaneously regress region bounds and objectness scores at each location on a regular grid. The RPN is thus a kind of fully convolutional network (FCN) and can be trained end-to-end specifically for the task for generating detection proposals.

**Faster R-CNN is a single, unified network for object detection. The RPN module serves as the ‘attention’ of this unified network.**


## Faster R-CNN

Faster R-CNN is composed of two modules:
1. a deep fully convolutional network that proposes regions
2. a Faster R-CNN detector

> Using the recently popular terminology of neural networks with ‘attention’ mechanisms, the RPN module tells the Fast R-CNN module where to look.


## RPN (Region Proposal Networks)

A RPN takes an image of any size as input and outputs a set of rectangular object proposals, each with an objectiveness score.

> Because our ultimate goal is to share computation with a Fast R-CNN object detection network, we assume that both nets share a common set of convolutional layers.

1. **Generate region proposals:** slide a small network over the convolutional feature map output by the last shared convolutional layer. (this small network takes as input an nxn spatial window of the input convolutional feature map)
2. Each sliding window is mapped to a lower-dimensional feature.(256-d for ZF and 512-d for VGG, with ReLU following). This feature is fed into two fully-connected layers —— a box-regression layer and a box-classification layer.

> **Note that because the mini-network operates in a sliding-window fashion, the fully-connected layers are shared across all spatial locations. This architecture is naturally implemented with an n×n convolutional layer followed by two sibling 1 × 1 convolutional layers (for reg and cls, respectively).**

### Anchors

At each sliding-window location, we simultaneously predict multiple region proposals, where the number of maximum possible proposals for each location is denoted as k. So the reg layer has 4k outputs encoding the coordinates of k boxes, and the cls layer outputs 2k scores that estimate probability of object or not object for each proposal.

#### Translation-Invariant Anchors

> An important property of our approach is that it is translation invariant, both in terms of the anchors and the functions that compute proposals relative to the anchors.

The translation-invariant property also reduces the model size.

#### Multi-Scale Anchors as Regression References

There have been two popular ways for multi-scale predictions.
1. Based on image/feature pyramids (useful but is time-consuming)
2. Use sliding windows of multiple scales (and/or aspect ratios) on the feature maps

> As a comparison, our anchor-based method is built on a pyramid of anchors, which is more cost-efficient.

### Loss Function

For training RPNs, we assign a binary class label (of being an object or not) to each anchor.

Assign a positive label to two kinds of anchors:
1. the anchor/anchors with the highest Intersection-over-Union (IoU) overlap with a ground-truth box
2. an anchor that has an IoU overlap higher than 0.7 with any ground-truth box

Assign a negative label to a non-positive anchor if its IoU ratio is lower than 0.3 for all ground-truth boxes

Anchors that are neither positive nor negative do not contribute to the training objective.

Loss function for an image is defined as:

```math
L(\{p_i\}, \{t_i\}) = \frac {1}{N_{cls}} \sum_i L_{cls}(p_i, p_i^*) + \lambda \frac {1}{N_{reg}} \sum_i p_i^*L_{reg}(t_i, t_i^*)
```

Here, `i` is the index of an anchor in a mini-batch and `pi` is the predicted probability of anchor `i` being an object. The ground-truth label `p∗i` is 1 if the anchor is positive, and is 0 if the anchor is negative. `ti` is a vector representing the 4 parameterized coordinates of the predicted bounding box, and `t∗i` is that of the ground-truth box associated with a positive anchor. The classification loss `Lcls` is **log loss over two classes (object vs. not object)**. For the regression loss, we use Lreg (`ti`, `t∗i` ) = R(`ti` − `t∗i` ) where R is the robust loss function (smooth L1) defined as:

```math
L_{reg}(t_i, t_i^*) = \sum_{i \in \{x, y, w, h\}} smooth_{L1}(t_i - t_i^*)
```

The term `p∗i` Lreg means the regression loss is activated only for positive anchors (`p∗i` = 1) and is disabled otherwise (`p∗i` = 0). The outputs of the cls and reg layers consist of `{pi}` and `{ti}` respectively.

The two terms are normalized by `Ncls` and `Nreg` and weighted by a balancing parameter `λ`.

For bounding box regression, we adopt the parameterizations of the 4 coordinates following :

```math
t_x = (x - x_a) / w_a, \ \ \ t_y = (y - y_a) / h_a

t_w = \log(w / w_a), \ \ \ t_h = \log(h / h_a)

t_x^* = (x^* - x_a) / w_a, \ \ \ t_y^* = (y^* - y_a) / h_a

t_w^* = \log(w^* / w_a), \ \ \ t_h^* = \log(h^* / h_a)
```

> Nevertheless, our method achieves bounding-box regression by a different manner from previous RoI-based (Region of Interest) methods [1], [2]. In [1], [2], bounding-box regression is performed on features pooled from arbitrarily sized RoIs, and the regression weights are shared by all region sizes. In our formulation, the features used for regression are of the same spatial size (3 × 3) on the feature maps. To account for varying sizes, a set of k bounding-box regressors are learned. Each regressor is responsible for one scale and one aspect ratio, and the k regressors do not share weights. As such, it is still possible to predict boxes of various sizes even though the features are of a fixed size/scale, thanks to the design of anchors.

### Training RPNs

The RPN can be trained end-to-end by back- propagation and stochastic gradient descent (SGD) [35]. We follow the “image-centric” sampling strategy from [2] to train this network. Each mini-batch arises from a single image that contains many positive and negative example anchors. It is possible to optimize for the loss functions of all anchors, but this will bias towards negative samples as they are dominate. Instead, we randomly sample 256 anchors in an image to compute the loss function of a mini-batch, where the sampled positive and negative anchors have a ratio of up to 1:1. If there are fewer than 128 positive samples in an image, we pad the mini-batch with negative ones.


## Sharing Features for RPN and Fast R-CNN

Discuss three ways for training networks with features shared:

1. Alternating training:
    - first train RPN
    - use the proposals to train Fast R-CNN
    - the network tuned by Fast R-CNN is then used to initialize RPN
    - then iterate this process
2. Approximate joint training: the RPN and Fast R-CNN networks are merged into one network during training. In each SGD:
    - the forward pass region proposals when training a Fast R-CNN detector
    - BP take place as usual, where for the shared layers the BP signals from both Fast R-CNN loss and RPN loss

    (this solution ignores the derivative w.r.t. the box coordinates)

3. Non-approximate joint training: involve gradients w.r.t. the box coordinates


### 4-step Alternating Training

1. Train the RPN, initialized with an ImageNet-pre-trained model and fine-tuned end-to-end for the region proposal task.
2. Train a separate detection network by Fast R-CNN using the proposals generated by the step-1 RPN, also initialized by the ImageNet-pre-trained model. (At this point the two networks do not share convolutional layers.)
3. use the detector network to initialize RPN training, but fix the shared convolutional layers and only fine-tune the layers unique to RPN. (Now the two networks share convolutional layers.)
4. Keep the shared convolutional layers fixed, fine-tune the unique layers of Fast R-CNN

**As such, both networks share the same convolutional layers and form a unified network.**


------


参考：

- [http://jacobkong.github.io/posts/3802700508/](http://jacobkong.github.io/posts/3802700508/)
- [http://blog.csdn.net/shenxiaolu1984/article/details/51152614](http://blog.csdn.net/shenxiaolu1984/article/details/51152614)


- Keras 实现：[https://github.com/yhenon/keras-frcnn](https://github.com/yhenon/keras-frcnn)
