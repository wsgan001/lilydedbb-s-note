# OpenCV 滤波


### 高通滤波器

高通滤波器（HPF）是根据像素与周围像素的亮度差值来提升该像素亮度的滤波器

计算完中央像素与周围邻近像素的亮度差值之和以后，如果亮度变化很大，中央像素的亮度会增加，反之则不会。即：一个像素如果比周围像素更突出，就会提升他的亮度

Example: (**note: 高通滤波器的核中所有的值之和为 0**)

```python
# 高通滤波器
import cv2
import numpy as np
from scipy import ndimage
import matplotlib.pyplot as plt

# 两个高通滤波器卷积核
kernel_3x3 = np.array([[-1, -1, -1],
                      [-1, 8, -1],
                      [-1, -1, -1]])
kernel_5x5 = np.array([[-1, -1, -1, -1, -1],
                      [-1, 1, 2, 1, -1],
                      [-1, 2, 4, 2, -1],
                      [-1, 1, 2, 1, -1],
                      [-1, -1, -1, -1, -1]])

img = cv2.imread('./images/IMG_7927.jpg', 0)
k3 = ndimage.convolve(img, kernel_3x3)
k5 = ndimage.convolve(img, kernel_5x5)

# 应用低通滤波器（高斯模糊）后，和原始图像计算差值，效果优于直接应用高通滤波器
blurred = cv2.GaussianBlur(img, (11, 11), 0)
g_hdf = img - blurred

cv2.imshow('img', img)
cv2.imshow('3x3', k3)
cv2.imshow('5x5', k5)
cv2.imshow('blur', blurred)
cv2.imshow('hdf', g_hdf)
cv2.waitKey()
cv2.destroyAllWindows()
```

实现高通滤波器还可以通过：**对图像应用低通滤波器之后，与原始图像计算差值【实际上，这样会比直接应用高通滤波器效果要好】**


### 边缘检测

OpenCV 边缘检测滤波函数：

- `Laplacian()`
- `Sobel()`
- `Scharr()`

这些滤波函数会将非边缘区域转为黑色，将边缘区域转为白色或者其他饱和的颜色。**但是很容易错误地将噪声识别为边缘，缓解这个问题的办法是探测边缘之前对图像进行模糊处理**。

Example:

使用 `medianBlur()` 作为模糊函数【**`medianBlur()`对取出数字化的视频噪声非常有效，特别是彩色图像的噪声**】

使用 `Laplacian()` 作为边缘检测函数

**在使用 `medianBlur()` 之后，使用 `Laplacian()` 之前，需要将彩色图像转化为灰度图像**

```python
def strokeEdges(src, dst, blurKsize=7, edgeKsize=5):
    if blurKsize >= 3:
        blurredSrc = cv2.medianBlur(src, blurKsize)
        graySrc = cv2.cvtColor(blurredSrc, cv2.COLOR_BGR2GRAY)
    else:
        graySrc = cv2.cvtColor(src, cv2.COLOR_BGR2GRAY)
    cv2.Laplacian(graySrc, cv2.CV_8U, graySrc, ksize=edgeKsize)
    normalizedInverseAlpha = (1.0 / 255) * (255 - graySrc)
    channels = cv2.split(src)
    for channel in channels:
        channel[:] = channel * normalizedInverseAlpha
    cv2.merge(channels, dst)
```


### 自定义卷积核

```python
kernel = np.array([[-1, -1, -1],
                  [-1, 9, -1],
                  [-1, -1, -1]])
cv2.filter2D(img, -1, kernel, dst)
cv2.imshow('customized convolution', dst)
```

`cv2.filter2D()` 的第二个参数表示目标图像每个通道的位深度：
- `cv2.CV_8U` 表示每个通道为8位
- 负值，如 `-1` 表示目标图像和原图像有同样的位深度


#### 锐化卷积核 sharpen filter

```python
# sharpen filter
kernel = np.array([[-1, -1, -1],
                           [-1,  9, -1],
                           [-1, -1, -1]])
cv2.filter2D(img, -1, kernel, dst)
```

**注：权重加起来为 1 的卷积核不会改变图像亮度；如果权重加起来为 0，则成了边缘检测核**

#### 边缘检测核

```python
kernel = np.array([[-1, -1, -1],
                   [-1,  8, -1],
                   [-1, -1, -1]])
cv2.filter2D(img, -1, kernel, dst)
```

#### 浮雕效果滤波器

```python
kernel = np.array([[-2, -1, 0],
                   [-1,  1, 1],
                   [ 0,  1, 2]])
cv2.filter2D(img, -1, kernel, dst)
```

### Canny 边缘检测



