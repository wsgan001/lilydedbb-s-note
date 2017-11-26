# Rich feature hierarchies for accurate object detection and semantic segmentat


![image](http://images2015.cnblogs.com/blog/838537/201511/838537-20151117093009952-1629236827.jpg)


- mAP: mean average precision

## R-CNN two key insights:

1. apply high-capacity CNN to bottom-up region proposals in order to localize and segment objects
2. supervised pre-training for an auxiliary task, followed by domain-specific fine-tuning (a significant performance boost when labeled training data is scarce)

## challenges of R-CNN:

1. challenge 1: units high up in our network, which has five convolutional layers, have very large receptive fields (195 × 195 pixels) and strides (32×32 pixels) in the input image, which makes precise localization within the sliding-window paradigm an open technical challenge. Solution:

    1. generate around 2000 category-independent region proposals for input image
    2. extract a fixed-length feature vector from proposals for input image using a CNN
    3. classify each region with category-specific linear SVMs

    ( use a simple technique (affine image warping) to compute a fixed-size CNN input from each region proposal, regardless of the region’s shape )

2. challenge 2: labeled data is scarce and the amount currently available is insufficient for training a large CNN. Solution: use unsupervised pre-training, followed by supervised fine-tuning


- supervised pre-training on a large auxiliary dataset (ILSVRC), followed by domain-specific fine-tuning on a small dataset (PASCAL), is an effective paradigm for learning high-capacity CNNs


## three modules of R-CNN

1. generate category-independent region proposals
2. a CNN that extracts a fixed-length feature vector from each region
3. a set of class-specific linear SVMs


## Object detection with R-CNN

### Region proposals:

run selective search on the test image extract around 2000 region proposals

### Feature extraction:

wrap each proposal and forward propagate it through the CNN in order to compute features

### Test-time detection

- greedy non-maximum suppression: for each class independently, rejects a region if it has an intersection-over-union (IOU overlap with higher scoring selected region larger than a learned threshold)

    > Given all scored regions in an image, we apply a greedy non-maximum suppression (for each class independently) that rejects a region if it has an intersection-over- union (IoU) overlap with a higher scoring selected region larger than a learned threshold.


## Training

- Supervised pre-training (using image-level annotations only, bounding-box labels are not available for this data)
- Domain-specific fine-tuning (replacing the CNN's ImageNet specific 1000-way classification layer with a randomly initialized (N+1)-way classification layer, where N is the number of objects classes, plus 1 for background (the CNN architecture is unchanged))

    > We treat all region proposals with ≥ 0.5 IoU overlap with a ground-truth box as positives for that box’s class and the rest as negatives. We start SGD at a learning rate of 0.001 (1/10th of the initial pre-training rate), which allows fine-tuning to make progress while not clobbering the initialization. In each SGD iteration, we uniformly sample 32 positive windows (over all classes) and 96 background windows to construct a mini-batch of size 128. We bias the sampling towards positive windows be- cause they are extremely rare compared to background

- Object category classifier
    1. give training labels (divide all proposals positive examples and negative examples)
    2. optimize one linear SVM per class


## Object proposal transformations

1. "tightest square with context" or "tightest square without context"
2. warp

> For each of these transformations, we also consider including additional image context around the original object proposal. The amount of context padding (p) is defined as a border size around the original object proposal in the trans- formed input coordinate frame.
>
> A pilot set of experiments showed that warping with context padding (p = 16 pixels) outperformed the alternatives by a large margin (3-5 mAP points).


## Positive vs. negative examples and softmax


## Bounding-box regression

- After scoring each selective search proposal with a class-specific detection SVM, we predict a new bounding box for the detection using a class-specific bounding-box regressor.
- The input to our training algorithm is a set of N training pairs{(Pi,Gi)}i=1,...,N,wherePi = (Pxi,Pyi,Pwi ,Phi), G = (Gx,Gy,Gw,Gh).
- scale-invariant translation:
    - Gˆx =Pwdx(P)+Px
    - Gˆy =Phdy(P)+Py
- log-space translations:
    - Gˆw = Pw exp(dw(P))
    - Gˆh = Ph exp(dh(P)).
- d⋆(P) = wT⋆φ5(P), where ⋆ is one of x,y,h,w
- w⋆ is a vector of learnable model parameters. We learn w⋆ by optimizing the regularized least squares objective (ridge regression):
    - w⋆ = argmin sum i_N (ti⋆ − wˆ ⋆Tφ5(P i))2 + λ ∥wˆ ⋆∥2 .
- The regression targets t⋆ for the training pair (P, G) are de- fined as
    - tx = (Gx − Px)/Pw
    - ty=(Gy−Py)/Ph
    - tw = log(Gw/Pw)
    - th = log(Gh/Ph)
- regularization is important: we set λ = 1000 based on a validation set
- care must be taken when selecting which training pairs (P, G) to use (only learn from a proposal P if it is nearby at least one ground-truth box)

参考:
- [http://www.cnblogs.com/kingstrong/p/4969472.html](http://www.cnblogs.com/kingstrong/p/4969472.html)
- [http://blog.csdn.net/bixiwen_liu/article/details/53840913](http://blog.csdn.net/bixiwen_liu/article/details/53840913)
