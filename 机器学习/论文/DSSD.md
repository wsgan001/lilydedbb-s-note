# DSSD: Deconvolutional Single Shot Detector


> Looking to concurrent research outside of detection, there has been a work on integrating context using so called "encoder-decoder" networks where a bottleneck layer in the middle of a network is used to encode information about an input image and then progressively larger layers decode this into a map over the whole image.


## DSSD

### Using Residual-101 in place of VGG

First modification is using Residual-101 in place of VGG used in the original SSD paper.

![image](http://img.blog.csdn.net/20170215170947594?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvSmVzc2VfTXg=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

Here we are adding layers after the conv5_x block, and predicting scores and box offsets from conv3_x, conv5_x, and the additional layers. (By itself this does not improve results.)

### Prediction module

In the original SSD, the objective functions are applied on the selected feature maps directly.

MS-CNN points out that **improving the sub-network of each task can improve accuracy**.

![image](http://img.blog.csdn.net/20170215175004262?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvSmVzc2VfTXg=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

Residual-101 and the prediction module seem to perform significantly better than VGG without the prediction module for higher resolution input images.

### Deconvolutional SSD

In order to include more high-level context in detection, we move prediction to a series of deconvolutional layers placed after the original SSD setup, effectively making an asymmetric hourglass network structure.

In order to strengthen features, we adopt the "**skip connection**" idea from the Hourglass model.

 Although the hourglass model contains symmetric layers in both the Encoder and Decoder stage, we **make the decoder stage extremely shallow** for two reasons.
 - First, detection is a fundamental task in vision and may need to provide information for the downstream tasks. Therefore, **speed is an important factor**. Building the symmetric network means the time for inference will double. This is not what we want in this fast detection framework.
 - Second, **there are no pretrained models** which include a decoder stage trained on the classification task of ILSVRC CLS-LOC dataset [25] because classification gives a single whole image label instead of a local label as in detection.

### Deconvolution Module

![image](http://img.blog.csdn.net/20170215171442159?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvSmVzc2VfTXg=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

> The deconvolution module is inspired by Pinheiro et al. [22] who suggested that **a factored version of the deconvolution module for a refinement network has the same accuracy as a more complicated one and the network will be more efficient.**

We make the following modifications:

- First, a batch normalization layer is added after each convolution layer
- Second, we use the learned deconvolution layer instead of bilinear upsampling
- Last, we test different combination methods: element-wise sum and element-wise product

    The experimental results show that the **element-wise product provides the best accuracy**.


## Train

We made minor change in the prior box aspect ratios setting. In the original SSD model, boxes with aspect ratios of ***2*** and ***3*** were proven useful from the experiments. **We run K-means clustering on the training boxes with square root of box area as the feature.**

