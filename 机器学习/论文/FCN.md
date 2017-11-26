# Fully Convolutional Networks for Semantic Segmentation

## Adapting classifier for dense prediction

Typical recognition nets, including LeNet [21], AlexNet [20], and its deeper successors [31, 32], ostensibly take fixed-sized inputs and produce non-spatial outputs. The fully connected layers of these nets have fixed dimensions and throw away spatial coordinates. However, these **fully connected layers can also be viewed as convolutions with kernels that cover their entire input regions.**

> Furthermore, while the resulting maps are equivalent to the evaluation of the original net on particular input patches, the computation is highly amortized over the overlapping regions of those patches.
>
> With ground truth available at every output cell, both the forward and backward passes are straightforward, and both take advantage of the inherent computational efficiency (and aggressive optimization) of convolution.

## Dense Prediction

### Shift-and-stitch is filter rarefaction

If the output is downsimpled by a factor of f, shift the input x pixels to the right and y pixels down, once for every (x, y) s.t. 0 <= x, y <= f. Process each of these f^2 inputs, and interlace the outputs so that the predictions correspond to the pixels at the centers of their receptive fields.


### Upsampling

**Upsampling is backwards strided convolution**

Another way to connect coarse outputs to dense pixels is interpolation. For instance, simple bilinear interpolation computes each output yij from the nearest four inputs by a linear map that depends only on the relative positions of the input and output cells.

In a sense, upsampling with factor `f` is convolution with a fractional input stride of `1 / f`. So long as `f` is integral, a natural way to upsample is therefore backwards convolution (sometimes called *deconvolution*) with an output stride of `f`. This operation simply reverses the forward and backward passes of convolution.

**Note that the deconvolution filter in such a layer need not be fixed, but can be learned.
