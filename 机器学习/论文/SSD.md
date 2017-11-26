# SSD: Single Shot MultiBox Detector

The fundamental improvement in speed comes from **eliminating bounding box proposals and the subsequent pixel or feature resampling stage**.

## Single Shot Detector

- In a convolutional fashion, we evaluate a small set of default boxes of different aspect ratios at each location in several feature maps with different scales.
- For each default box, we predict both the shape offsets and the confidences for all object categories (***(c1, c2, ···, cp)***)

## Model

![image](http://img.blog.csdn.net/20160918092701558)

**The SSD approach is based on a feed-forward convolutional network that produces a fixed-size collection of bounding boxes and scores for the presence of object class instances in those boxes, followed by a non-maximum suppression step to produce the final detections.**

- base network: a standard architecture used for high quality image classification
- auxiliary structure: to produce detections with the following key features

    - **Multi-scale feature maps for detection**: We add convolutional feature layers to the end of the truncated base network. These layers decrease in size progressively and allow predictions of detections at multiple scales.

    - **Convolutional Predictors for detection**: Each added feature layer (or an existing feature layer from the base network) can produce a fixed set of detection predictions using a set of convolutional filters.

        For a feature layer of size ***m × n*** with ***p*** channels, the basic element for predicting parameters of a potential detection is a ***3 × 3 × p*** small kernel that produces either a score for a category, or a shape offset relative to the default box coordinates.

    - **Default boxes and aspect ratios**: We associate a set of default bounding boxes with each feature map cell, for multiple feature maps at the top of the network. At each feature map cell, we predict the offsets relative to the default box shapes in the cell, as well as the per-class scores that indicate the presence of a class instance in each of those boxes.

        Specifically, for each box out of k at a given location, we compute ***c*** class scores and the **4** offsets relative to the original default box shape. This results in a total of ***(c + 4)k*** filters that are applied around each location in the feature map, yielding ***(c + 4)kmn*** outputs for a ***m × n*** feature map.

## Train

The key difference between training SSD and training a typical detector that uses region proposals, is that ground truth information needs to be assigned to specific outputs in the fixed set of detector outputs. Once this assignment is determined, the loss function and back propagation are applied end-to-end.

Training also involves:
- choosing the set of default boxes
- scales for detection
- the hard negative mining
- data augmentation strategies

### Matching strategy

For each ground truth box we are selecting from default boxes that vary over location, aspect ratio, and scale. We begin by matching each ground truth box to the default box to the default box with the **best jaccard overlap** (as in MultiBox). Unlike MultiBox, we then match default boxes to any ground truth with jaccard overlap higher than a threshold(0.5).

**This simplifies the learning problem, allowing the network to predict high scores for multiple overlapping default boxes rather than requiring it to pick only the one with maximum overlap.**

### Training Objective

Let

```math
x_{ij}^{p} = {1, 0}
```

be an indicator for matching the ***i***-th default box to the ***j***-th ground truth box of category ***p***

In matching strategy above, we have:

```math
\sum_{i} x_{ij}^{p} \geq 0
```

The overall objective loss function is a weighted sum of the localization loss (loc) and the confidence loss (conf):

```math
L(x, c, l, g) = \frac {1}{N} (L_{conf}(x, c) + \alpha L_{loc}(x, l, g))
```

where ***N*** is the number of matched default boxes. If ***N = 0***, wet set the loss to ***0***.

The localization loss is a ***Smooth L1*** loss [6] between the predicted box (***l***) and the ground truth box (***g***) parameters

```math
L_{loc}(x, l, g) = \sum_{i \in Pos}^{N} \sum_{m \in {cx, cy, w, h}} x_{ij}^{k} smooth_{L1}(l_{i}^{m} - \hat g_{j}^{m})

\hat g_{j}^{cx} = (g_{j}^{cx} - d_{i}^{cx}) / d_{i}^{w}

\hat g_{j}^{cy} = (g_{j}^{cy} - d_{i}^{cy}) / d_{i}^{h}

\hat g_{j}{w} = \log(\frac {g_{i}^{w}}{d_{i}^{w}})

\hat g_{j}{h} = \log(\frac {g_{i}^{h}}{d_{i}^{h}})
```

The confidence loss is the softmax loss over multiple classes confidences (***c***)

```math
L_{conf}(x, c) = - \sum_{i \in Pos}^{N} x_{ij}^{p} \log(\hat c_{i}^{0}) - \sum_{i \in Neg} \log(\hat c_{i}^{0}) \ \ \ where \ \ \ c_{i}^{p} = \frac {exp(c_{i}^{p})} {\sum_{p} exp(c_{i}^{p})}
```

and the weight term α is set to ***1*** by cross validation.

### Choosing scales and aspect ratios for default boxes

**Previous works have shown that using feature maps from the lower layers can improve semantic segmentation quality because the lower layers capture more fine details of the input objects. Similarly, showed that adding global context pooled from a feature map can help smooth the segmentation results.**

Motivated by these methods, we use both the lower and upper feature maps for detection.

We design the tiling of default boxes so that specific feature maps learn to be responsive to particular scales of the objects. The scale of the default boxes for each feature map is computed as:

```math
s_k = s_{min} + \frac {s_{max} - s_{min}} {m - 1} (k - 1), \ \ \ k \in [i, m]
```

where ***s_min*** is ***0.2*** and ***s_max*** is ***0.9***, meaning the lowest layer has a scale of ***0.2*** and the highest layer has a scale of ***0.9***.

**By combining predictions for all default boxes with different scales and aspect ratios from all locations of many feature maps, we have a diverse set of predictions, covering various input object sizes and shapes. For example, in Fig. 1, the dog is matched to a default box in the *4 × 4* feature map, but not to any default boxes in the *8 × 8* feature map. This is because those boxes have different scales and do not match the dog box, and therefore are considered as negatives during training.**

![image](http://images2015.cnblogs.com/blog/1005315/201703/1005315-20170321214626940-172561911.png)

### Hard negative mining

Instead of using all the negative examples, we sort them using the highest confidence loss for each default box and pick the top ones so that the ratio between the negatives and positives is at most ***3:1***.

### Data augmentation

Each training image is randomly sampled by one of the following options:

- Use the entire original input image
- Sample a patch so that the minimum jaccard overlap with the objects is 0.1, 0.3, 0.5, 0.7 or 0.9
- Randomly sample a patch


## Experiment

Our experiments are all based on ***VGG16*** [15], which is pre-trained on the ***ILSVRC CLS-LOC*** dataset [16]. Similar to ***DeepLab-LargeFOV*** [17], we convert ***fc6*** and ***fc7*** to convolutional layers, subsample parameters from fc6 and ***fc7***, change ***pool5*** from ***2×2−s2*** to ***3×3−s1***, and use the ***a` trous*** algorithm[18] to fill the ”holes”. We remove all the dropout layers and the ***fc8*** layer. We fine-tune the resulting model using SGD with initial learning rate ***10−3***, ***0.9*** momentum, ***0.0005*** weight decay, and batch size ***32***.

- SSD has more confusions with similar object categories (especially for animals), partly because we share locations for multiple categories.
- SSD is very sensitive to the bounding box size. In other words, it has much worse performance on smaller objects than bigger objects. This is not surprising because those small objects may not even have any information at the very top layers. Increasing the input size (e.g. from ***300 × 300*** to ***512 × 512***) can help improve detecting small objects, but there is still a lot of room to improve.
- On the positive side, we can clearly see that SSD performs really well on large objects. And it is very robust to different object aspect ratios because we use default boxes of various aspect ratios per feature map location.

### Model analysis

- **Data Augmentation is Crucial**: improve 8.8% mAP with the sampling strategy
- **More default box shapes is better**: Using a variety of default box shapes seems to make tha task of predicting boxes easier for the network
- **Atrous is faster**: The result of using full VGG16 is about the same while the speed is about 20% slower.
- **Multiple output layers at different resolutions is better**
