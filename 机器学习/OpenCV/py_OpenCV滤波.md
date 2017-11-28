# OpenCV 滤波

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
