# Caffe 卷积层实现

在caffe中计算卷积分为两个步骤：

1. 使用im2col操作将图片转换为矩阵

2. 调用GEMM计算实际的结果

简单来说就是以下的矩阵相乘操作:

![image](https://pic3.zhimg.com/50/v2-0ea98b8d5834631f9a8406f7231ba942_hd.jpg)

![image](https://pic2.zhimg.com/50/v2-a110f19f0bede9463175a52217c22769_hd.jpg)

![image](https://pic3.zhimg.com/50/v2-3b1ffdb16622ab9aeae58d15495b327e_hd.jpg)

这是将输入转换为feature matrix的过程(im2col)，这里的feature matrix对应于上图中的矩阵B的转置，k即是卷积核的尺寸，C为输入的维度，矩阵B中的

```math
K = C * k * k
```

当然N就等于H' x W'了,H'，W'对应于输出的高和宽,显然

```math
H' = (H - k + 2 * pad) / stride + 1

W' = (W - k + 2 * pad) / stride + 1
```

A矩阵:

![image](https://pic1.zhimg.com/50/v2-339657291663a4e791a9b34952d5859c_hd.jpg)

A矩阵对应于filter matrix,Cout是输出的维度，亦即卷积核的个数

```math
K = C * k * k
```

首先我们已经有从更深层的网络中得到的

```math
\frac{\partial Loss}{\partial C}.
```

根据矩阵微分公式

```math
\frac{\partial Ax + b}{\partial x} = A^T
```

，可推得

```math
\frac{\partial Loss}{\partial B} = \frac{\partial Loss}{\partial C} \cdot \frac{\partial C}{\partial B} =A^T\frac{\partial Loss}{\partial y}
```

### python 实现 im2col

参考：[Implementing convolution as a matrix multiplication](https://buptldy.github.io/2016/10/01/2016-10-01-im2col/)



```python
%%cython
import cython
cimport numpy as np
import numpy as np
ctypedef fused DTYPE_t:
    np.float32_t
    np.float64_t

def im2col_cython(np.ndarray[DTYPE_t, ndim=4] x, int field_height, int field_width, int padding, int stride):
    cdef int N = x.shape[0]
    cdef int C = x.shape[1]
    cdef int H = x.shape[2]
    cdef int W = x.shape[3]

    cdef int HH = int((H + 2 * padding - field_height) / stride) + 1
    cdef int WW = int((W + 2 * padding - field_width) / stride) + 1

    cdef int p = padding
    cdef np.ndarray[DTYPE_t, ndim=4] x_padded = np.pad(x, ((0, 0), (0, 0), (p, p), (p, p)), mode='constant')

    cdef np.ndarray[DTYPE_t, ndim = 2] cols = np.zeros((C * field_height * field_width, N * HH * WW), dtype=x.dtype)

    cdef int c, ii, jj, row, yy, xx, i, col
    for c in range(C):
        for yy in range(HH):
            for xx in range(WW):
                for ii in range(field_height):
                    for jj in range(field_width):
                        row = c * field_width * field_height + ii * field_height + jj
                        for i in range(N):
                            col = (yy * WW + xx) * N + i
                            cols[row, col] = x_padded[i, c, stride * yy + ii, stride * xx + jj]
    return cols

def conv_forward_im2col(x, w, b, conv_params):
    N, C, H, W = x.shape
    num_filters, _, filter_height, filter_width = w.shape
    stride, pad = conv_params['stride'], conv_params['pad']

    # Check dimensions
    assert (W + 2 * pad - filter_width) % stride == 0, 'width does not work'
    assert (H + 2 * pad - filter_height) % stride == 0, 'height does not work'

    out_height = int((H + 2 * pad - filter_height) / stride + 1)
    out_width = int((W + 2 * pad - filter_width) / stride + 1)
    out = np.zeros((N, num_filters, out_height, out_width), dtype=x.dtype)

    x_cols = im2col_cython(x, w.shape[2], w.shape[3], pad, stride)
    res = w.reshape((w.shape[0], -1)).dot(x_cols) + b.reshape(-1, 1)

    out = res.reshape(w.shape[0], out.shape[2], out.shape[3], x.shape[0])
    out = out.transpose(3, 0, 1, 2)

    cache = (x, w, b, conv_params, x_cols)
    return out, cache
```

## caffe 反卷积

其实转置卷积相对于卷积在神经网络结构的正向和反向传播中做相反的运算。
所以所谓的转置卷积其实就是正向时左乘

```math
A^T
```

而反向时左乘

```math
(A^T)^T, \ \ \ \ \ \ just A
```