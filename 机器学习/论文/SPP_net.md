# Spatial Pyramid Pooling in Deep Convolutional Networks for Visual Recognition

![image](http://hexo-pic-zhangliliang.qiniudn.com/%E5%B0%8FQ%E6%88%AA%E5%9B%BE-20140913171023.png)

![image](http://hexo-pic-zhangliliang.qiniudn.com/%E5%B0%8FQ%E6%88%AA%E5%9B%BE-20140913192418.png)


> The SPP layer pools the features and generates fixed-length outputs, which are then fed into the fully-connected layers (or other classifiers). In other words, we perform some information “aggregation” at a deeper stage of the network hierarchy (between convolutional layers and fully-connected layers) to avoid the need for cropping or warping at the beginning. Figure 1 (bottom) shows the change of the network


## SPP-net

1. able to generate fixed-length output regardless of the input size
2. use multi-level spatial bins, while the sliding window pooling used in the previous deep networks
3. pool features extracted at variable scales thanks to the flexibility of input size


- Training with variable-size images increases scale-invariance and reduces over-fitting.


> R-CNN is time-consuming, because it repeatedly applies the deep convolutional networks to the raw pixels of thousands of warped regions per image. SPPnet can run the convolutional layers only once on the entire image (regardless of the number of windows), and then extract features by SPP-net on the feature maps. This method yields a speedup of over one hundred times over R-CNN.

> **Note that training/running a detector on the feature maps (rather than image regions) is actually a more popular idea.**


## The Spatial Pyramid Pooling Layer

- **Spatial pyramid pooling maintain spatial information by pooling in local spatial bins. These spatial bins have sizes proportional to the image size, so the number of bins is fixed regardless of the image size.**

- replace the last pooling layer (e.g., pool5, after the last convolutional layer) with a spatial pyramid pooling layer

- The outputs of the spatial pyramid pooling are kM dimensional vectors with the number of bins denoted as M (k is the number of filters in the last convolutional layer). The fixed-dimensional vectors are the input to the fully-connected layer.


## Training

1. Single-size training (224×224)
2. Multi-size training (180×180, 224×224)

- With a pyramid level of n×n bins, we implement this pooling level as a sliding window pooling, where the window size win = ⌈a/n⌉ and stride str = ⌊a/n⌋ with ⌈·⌉ and ⌊·⌋ denoting ceiling and floor operations.
- **Note that the above single/multi-size solutions are for training only. At the testing stage, it is straight forward to apply SPP-net on images of any sizes.**


## SPP-net for Image Classification

1. The advantages of SPP are independent of the convolutional network architectures used.
2. Multi-level Pooling Improves Accuracy
    - **It is worth noticing that the gain of multi-level pooling is not simply due to more parameters; rather, it is because the multi-level pooling is robust to the variance in object deformations and spatial layout.**
3. Multi-size Training Improves Accuracy
4. Full-image Representations Improve Accuracy
5. Multi-view Testing on Feature Maps


## SPP-net for Object Detection

> R-CNN first extracts about 2,000 candidate windows from each image via selective search [20]. Then the image region in each window is warped to a fixed size (227×227). A pre-trained deep network is used to extract the feature of each window. A binary SVM classifier is then trained on these features for detection. **Feature extraction is the major timing bottleneck in testing.**

- SPP-net extracts the feature maps from the entire image only once. Then applies the pyramid pooling on each candidate window of the feature maps to pool a fixed-length representation of this window.

Detection Algorithm:

1. use selective search to generate about 2000 candidate windows per image.
2. resize the image such that min(w, h) = s, and extract the feature maps from the entire image.
3. use M-level spatial pyramid to pool the features. This generates kM-d representations for each window.
4. These representations are provided to the fully-connected layers of the network.
5. train a binary linear SVM classifier for each category on these features.

- improved by multi-scale feature extraction
- fine-tune our pre-trained network


## Implementation of Pooling Bins

For a pyramid level with n×n bins, the (i, j)-th bin is in the range of [⌊ ((i−1)/n) * w⌋, ⌈ (i/n) * w⌉] × [⌊ ((j−1)/n) * h⌋, ⌈ (j/n) * h⌉]. (Denote the width and height of the conv5 feature maps (can be the full image or a window) as w and h.)


## Mapping a Window to Feature Maps

> In our implementation, we project the corner point of a window onto a pixel in the feature maps, such that this corner point in the image domain is closest to the center of the receptive field of that feature map
pixel.

- For a response centered at (x′,y′) , its effective receptive field in the image domain is centered at (x,y) = (Sx′,Sy′) where S is the product of all previous strides.
- Given a window in the image domain, we project the left (top) boundary by: x′ = ⌊x/S⌋ + 1 and the right (bottom) boundary x′ = ⌈x/S⌉ − 1. If the padding is not ⌊p/2⌋, we need to add a proper offset to x.


参考：

- [http://liliangzhang.com/2014/09/13/paper-note-sppnet/](http://liliangzhang.com/2014/09/13/paper-note-sppnet/)
- [http://blog.csdn.net/hjimce/article/details/50187655](http://blog.csdn.net/hjimce/article/details/50187655)
