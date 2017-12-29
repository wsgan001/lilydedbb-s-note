# MobileNets: Efficient Convolutional Neural Network

MobileNets are based on a streamline architecture that uses** depthwise separable convolutions** to build light weight deep neural networks. We introduce two parameters that efficiently trade off between latency and accuracy. These hyper-parameters allow the model builder to choose the right sized model for their application based on the constraints of the problem.

## Depthwise Separable Convolution

The MobileNet model is based on depthwise separable convolutions which is a form of factorized convolutions which factorize a standard convolution into a depthwise convolution and a ***1 x 1*** convolution called a pointwise convolution.

1. The depthwise convolution applies a single filter to each input channel.
2. The pointwise convolution the applies a ***1 x 1*** convolution to combine the outputs the depthwise convolution.

A standard convolution both filters and combines inputs into a new set of outputs in one step. The depthwise separable convolution splits this into two layers, **a separate layer for filtering** and **a separate layer for combining**.

A standard convolutional layer takes as input a

```math
D_F \times D_F \times M
```

feature map ***F*** and produces a

```math
D_F \times D_F \times N
```

feature map ***G***.

The standard convolutional layer is parameterized by convolution kernel ***K*** of size

```math
D_K \times D_K \times M \times N
```

The output feature map for standard convolution assuming stride one and padding is computed as:

```math
G_{k,l,n} = \sum_{i,j,m} K_{i,j,m,n} \cdot F_{k+i-1, l+j-1, m}
```

The computational cost is:

```math
D_K \cdot D_K \cdot M \cdot N \cdot D_F \cdot D_F
```

**The depthwise separable convolutions split the filtering and conbinations steps.**

Depthwise separable convolution are made up of two layers:

1. **depthwise convolutions**: apply a single filter per each input channel
2. **pointwise convolutions**: a simple ***1 x 1*** convolution to create a linear combination of the output of the depthwise layer.

Depthwise convolution with one filter per input channel can be written as:

```math
\hat G_{k,l,m} = \sum_{i,j} \hat K_{i,j,m} \cdot F_{k+i-1, l+j-1, m}
```

The computional cost is:

```math
D_K \cdot D_K \cdot M \cdot D_F \cdot D_F
```

Combining ***1 x 1*** pointwise convolution, the computional cost of depthwise separable convolution is:

```math
D_K \cdot D_K \cdot M \cdot D_F \cdot D_F + M \cdot N \cdot D_F \cdot D_F
```

By expressing convolution as a two step process of filtering and combining we get a reduction in computation of:

```math
\frac {D_K \cdot D_K \cdot M \cdot D_F \cdot D_F + M \cdot N \cdot D_F \cdot D_F} {D_K \cdot D_K \cdot M \cdot N \cdot D_F \cdot D_F} = \frac {1}{N} + \frac {1}{N_K^2}
```
