# TensorFlow 常用 API

## tf.nn.conv2d

```python
tf.nn.conv2d(input, filter, strides, padding, use_cudnn_on_gpu=None, data_format=None, name=None)
```

> Computes a 2-D convolution given 4-D input and filter tensors.

Given an input tensor of shape `[batch, in_height, in_width, in_channels]` and a filter / kernel tensor of shape `[filter_height, filter_width, in_channels, out_channels]`, this op performs the following:

1. Flattens the filter to a 2-D matrix with shape `[filter_height * filter_width * in_channels, output_channels]`.
2. Extracts image patches from the input tensor to form a virtual tensor of shape `[batch, out_height, out_width, filter_height * filter_width * in_channels]`. (所谓输出的长宽是通过卷积核的长宽和卷积模式计算好的)
3. For each patch, right-multiplies the filter matrix and the image patch vector.

Args:

- `input`: A Tensor. Must be one of the following types: half, float32, float64.
- `filter`: A Tensor. Must have the same type as input.
- `strides`: A list of ints. 1-D of length 4. The stride of the sliding window for each dimension of input. Must be in the same order as the dimension specified with format.
- `padding`: A string from: "`SAME`", "`VALID`". The type of padding algorithm to use.

参考：[Tensorflow初学笔记——tf.nn.conv2d()的工作方法
](https://zhuanlan.zhihu.com/p/26139876?utm_medium=social&utm_source=qq)
在实际的运算中，计算机实际上首先将输入的`input`数据规模上进行拓展，由原来的`[batch,length,width,channel_in]`转化为`[batch,out_length,out_width,filter_length×filter_width×channel_in]`的格式，其中所谓输出的长宽是通过卷积核的长宽和卷积模式计算好的，一般来讲，卷积过程中卷积核的抽象区域应当有重叠而不应当有缝隙，所以大多数情况下，这样变形的结果是输入数据从规模上被扩大了。而此时，需要进行计算的卷积核矩阵也被变形成`[filter_length×filter_width×channel_in，channel_out]`的格式，虽然从规模上来说矩阵的大小没变，但是从维度上来说，卷积核被从4维拍扁成了两维，两个变形后的矩阵相乘，得到的结果就是`[batch,out_length,out_width,channel_out]`了



## tf.nn.max_pool

```python
tf.nn.max_pool(value, ksize, strides, padding, data_format='NHWC', name=None)
```

> Performs the max pooling on the input.

Args:

- `value`: A 4-D Tensor with shape [batch, height, width, channels] and type tf.float32.
- `ksize`: A list of ints that has length >= 4. The size of the window for each dimension of the input tensor.
- `strides`: A list of ints that has length >= 4. The stride of the sliding window for each dimension of the input tensor.
- `padding`: A string, either 'VALID' or 'SAME'. The padding algorithm.