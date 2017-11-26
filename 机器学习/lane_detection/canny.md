# Canny 算子——边缘检测

## 彩色RGB图像转换为灰度图像

RGB转换成灰度图像的一个常用公式是：

```
Gray = R * 0.299 + G * 0.587 + B * 0.114
```

```c
void ConvertRGB2GRAY(const Mat &image, Mat &imageGray) {
    if (!image.data || image.channels() != 3) {
        return;
    }
    imageGray = Mat::zeros(image.size(), CV_8UC1);
    uchar *pointImage = image.data;
    uchar *pointImageGray = imageGray.data;
    int stepImage = image.step;
    int stepImageGray = imageGray.step;
    for (int i = 0; i < imageGray.rows; i++) {
        for (int j = 0; j < imageGray.cols; j++) {
            pointImageGray[i * stepImageGray + j] =
                    0.114 * pointImage[i * stepImage + 3 * j] + 0.587 * pointImage[i * stepImage + 3 * j + 1] +
                    0.299 * pointImage[i * stepImage + 3 * j + 2];
        }
    }
}
```

## 生成高斯滤波卷积核

二维高斯分布：

```math
G(x) = \frac {1}{2\pi\sigma^2} e^{- \frac {x^2 + y^2} {2\sigma^2}}
```

```c
void GetGaussianKernel(double **gaus, const int size, const double sigma) {
    /*
     * gaus: 一个指向含有N个double类型数组的指针
     * size: 高斯卷积核的尺寸
     * sigma: 卷积核的标准差
     */
    const double PI = 4.0 * atan(1.0);
    int center = size / 2;
    double sum = 0;
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            gaus[i][j] = (1 / (2 * PI * sigma * sigma)) *
                         exp(-((i - center) * (i - center) + (j - center) * (j - center)) / (2 * sigma * sigma));
            sum += gaus[i][j];
        }
    }
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            gaus[i][j] /= sum;
        }
    }
    return;
}
```

## 高斯滤波

```c
void GaussianFilter(const Mat imageSource, Mat &imageGuassian, double **guas, int size) {
    /*
     * imageSource: 待滤波原始图像
     * imageGaussian: 滤波后输出图像
     * gaus: 一个指向含有N个double类型数组的指针
     * size: 滤波核的尺寸
     */
    imageGuassian = Mat::zeros(imageSource.size(), CV_8UC1);
    if (!imageSource.data || imageSource.channels() != 1) {
        return;
    }
    double guasArray[100];
    for (int i = 0; i < size * size; i++) {
        guasArray[i] = 0;
    }
    int array = 0;
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; ++j) {
            guasArray[array] = guas[i][j]; // 二维数组压成一维，方便计算
            array++;
        }
    }
    // 滤波
    for (int i = 0; i < imageSource.rows; i++) {
        for (int j = 0; j < imageGuassian.cols; j++) {
            int k = 0;
            for (int l = -size / 2; l <= size / 2; l++) {
                for (int g = -size / 2; g <= size / 2; g++) {
                    int row = i + l;
                    int col = j + g;
                    row = row < 0 ? 0 : row;
                    row = row >= imageSource.rows ? imageSource.rows - 1 : row;
                    col = col < 0 ? 0 : col;
                    col = col >= imageGuassian.cols ? imageGuassian.cols - 1 : col;
                    imageGuassian.at<uchar>(i, j) += guasArray[k] * imageSource.at<uchar>(row, col);
                    k++;
                }
            }
        }
    }
}
```

## Sobel等梯度算子计算梯度幅值和方向

索贝尔算子（Sobel operator）是图像处理中的算子之一，主要用作边缘检测。在技术上，它是一离散性差分算子，用来运算图像亮度函数的梯度之近似值。在图像的任何一点使用此算子，将会产生对应的梯度矢量或是其法矢量。

该算子包含两组3x3的矩阵，分别为横向及纵向，将之与图像作平面卷积，即可分别得出横向及纵向的亮度差分近似值。如果以 A 代表原始图像，GX 及 GY 分别代表经横向及纵向边缘检测的图像，其公式如下：

```math
G_x = \begin{bmatrix} -1 & 0 & +1 \\ -2 & 0 & +2 \\ -1 & 0 & +1 \end{bmatrix} * A

G_y = \begin{bmatrix} -1 & -2 & -1 \\ 0 & 0 & 0 \\ +1 & +2 & +1 \end{bmatrix} * A
```

图像的每一个像素的横向及纵向梯度近似值可用以下的公式结合，来计算梯度的大小:

```math
G = \sqrt{G_x^2 + G_y^2}
```

然后可用以下公式计算梯度方向:

```math
\theta = arctan(\frac {G_y}{G_x})
```

```c
void SobelGradDirection(const Mat imageSource, Mat &imageSobelX, Mat &imageSobelY, double *&pointDirection) {
    /*
     * imageSourc: 原始灰度图像
     * imageSobelX: 是X方向梯度图像
     * imageSobelY: 是Y方向梯度图像
     * pointDirection: 是梯度方向角数组指针
     */
    pointDirection = new double[(imageSource.rows - 1) * (imageSource.cols - 1)];
    for (int i = 0; i < (imageSource.rows - 1) * (imageSource.cols - 1); i++) {
        pointDirection[i] = 0;
    }
    imageSobelX = Mat::zeros(imageSource.size(), CV_32SC1);
    imageSobelY = Mat::zeros(imageSource.size(), CV_32SC1);
    uchar *P = imageSource.data;
    uchar *PX = imageSobelX.data;
    uchar *PY = imageSobelY.data;

    int step = imageSource.step;
    int stepXY = imageSobelX.step;
    int k = 0, m = 0, n = 0;

    for (int i = 1; i < (imageSource.rows - 1); i++) {
        for (int j = 1; j < (imageSource.cols - 1); j++) {
            double gradY = P[(i - 1) * step + j + 1] + P[i * step + j + 1] * 2 + P[(i + 1) * step + j + 1] -
                           P[(i - 1) * step + j - 1] - P[i * step + j - 1] * 2 - P[(i + 1) * step + j - 1];
            PY[i * stepXY + j * (stepXY / step)] = abs(gradY);
            double gradX = P[(i + 1) * step + j - 1] + P[(i + 1) * step + j] * 2 + P[(i + 1) * step + j + 1] -
                           P[(i - 1) * step + j - 1] - P[(i - 1) * step + j] * 2 - P[(i - 1) * step + j + 1];
            PX[i * stepXY + j * (stepXY / step)] = abs(gradX);
            if (gradX == 0) {
                gradX = 0.00000000000000001;  // 防止除数为0异常
            }
            pointDirection[k] = atan(gradY / gradX) * 57.3; // 弧度转换为度
            pointDirection[k] += 90; // 由于atan求得的角度范围是-π/2~π/2，为了便于计算，这里对每个梯度角加了一个π/2，使范围变成0~π，便于计算
            k++;
        }
    }
    convertScaleAbs(imageSobelX, imageSobelX);
    convertScaleAbs(imageSobelY, imageSobelY);
}
```

## 求梯度图的幅值

```c
void SobelAmplitude(const Mat imageGradX, const Mat imageGradY, Mat &SobelAmpXY) {
    /*
     * imageGradX: X方向梯度图像
     * imageGradY: Y方向梯度图像
     * SobelAmpXY: 输出的X、Y方向梯度图像幅值
     */
    SobelAmpXY = Mat::zeros(imageGradX.size(), CV_32FC1);
    for (int i = 0; i < SobelAmpXY.rows; i++) {
        for (int j = 0; j < SobelAmpXY.cols; j++) {
            SobelAmpXY.at<float>(i, j) = sqrt(imageGradX.at<uchar>(i, j) * imageGradX.at<uchar>(i, j) +
                                              imageGradY.at<uchar>(i, j) * imageGradY.at<uchar>(i, j));
        }
    }
    convertScaleAbs(SobelAmpXY, SobelAmpXY);
}
```

## 对梯度幅值进行非极大值抑制

```c
void LocalMaxValue(const Mat imageInput, Mat &imageOutput, double *pointDirection) {
    /*
     * imageInput: 输入的Sobel梯度图像
     * imageOutPut: 输出的局部极大值抑制图像
     * pointDirection: 图像上每个点的梯度方向数组指针
     */
    imageOutput = imageInput.clone();
    int k = 0;
    for (int i = 1; i < imageInput.rows - 1; i++) {
        for (int j = 1; j < imageInput.cols - 1; j++) {
            int value00 = imageInput.at<uchar>((i - 1), j - 1);
            int value01 = imageInput.at<uchar>((i - 1), j);
            int value02 = imageInput.at<uchar>((i - 1), j + 1);
            int value10 = imageInput.at<uchar>((i), j - 1);
            int value11 = imageInput.at<uchar>((i), j);
            int value12 = imageInput.at<uchar>((i), j + 1);
            int value20 = imageInput.at<uchar>((i + 1), j - 1);
            int value21 = imageInput.at<uchar>((i + 1), j);
            int value22 = imageInput.at<uchar>((i + 1), j + 1);
            if (pointDirection[k] > 0 && pointDirection[k] <= 45) {
                if (value11 <= (value12 + (value02 - value12) * tan(pointDirection[i * imageOutput.rows + j])) ||
                    (value11 <= (value10 + (value20 - value10) * tan(pointDirection[i * imageOutput.rows + j])))) {
                    imageOutput.at<uchar>(i, j) = 0;
                }
            }
            if (pointDirection[k] > 45 && pointDirection[k] <= 90) {
                if (value11 <= (value01 + (value02 - value01) / tan(pointDirection[i * imageOutput.cols + j])) ||
                    value11 <= (value21 + (value20 - value21) / tan(pointDirection[i * imageOutput.cols + j]))) {
                    imageOutput.at<uchar>(i, j) = 0;

                }
            }
            if (pointDirection[k] > 90 && pointDirection[k] <= 135) {
                if (value11 <= (value01 + (value00 - value01) / tan(180 - pointDirection[i * imageOutput.cols + j])) ||
                    value11 <= (value21 + (value22 - value21) / tan(180 - pointDirection[i * imageOutput.cols + j]))) {
                    imageOutput.at<uchar>(i, j) = 0;
                }
            }
            if (pointDirection[k] > 135 && pointDirection[k] <= 180) {
                if (value11 <= (value10 + (value00 - value10) * tan(180 - pointDirection[i * imageOutput.cols + j])) ||
                    value11 <= (value12 + (value22 - value11) * tan(180 - pointDirection[i * imageOutput.cols + j]))) {
                    imageOutput.at<uchar>(i, j) = 0;
                }
            }
            k++;
        }
    }
}
```

## 双阈值处理

```c
void DoubleThreshold(Mat &imageInput, double lowThreshold, double highThreshold) {
    /*
     * imageInput: 输入和输出的的Sobel梯度幅值图像
     * lowThreshold: 低阈值
     * highThreshold: 高阈值
     */
    for (int i = 0; i < imageInput.rows; i++) {
        for (int j = 0; j < imageInput.cols; j++) {
            if (imageInput.at<uchar>(i, j) > highThreshold) {
                imageInput.at<uchar>(i, j) = 255;
            }
            if (imageInput.at<uchar>(i, j) < lowThreshold) {
                imageInput.at<uchar>(i, j) = 0;
            }
        }
    }
}
```

## 双阈值中间像素滤除或连接处理

```c
void DoubleThresholdLink(Mat &imageInput, double lowThreshold, double highThreshold) {
    /*
     * imageInput: 输入和输出的的Sobel梯度幅值图像
     * lowThreshold: 低阈值
     * highThreshold: 高阈值
     */
    for (int i = 1; i < imageInput.rows - 1; i++) {
        for (int j = 1; j < imageInput.cols - 1; j++) {
            if (imageInput.at<uchar>(i, j) > lowThreshold && imageInput.at<uchar>(i, j) < 255) {
                if (imageInput.at<uchar>(i - 1, j - 1) == 255 || imageInput.at<uchar>(i - 1, j) == 255 ||
                    imageInput.at<uchar>(i - 1, j + 1) == 255 ||
                    imageInput.at<uchar>(i, j - 1) == 255 || imageInput.at<uchar>(i, j) == 255 ||
                    imageInput.at<uchar>(i, j + 1) == 255 ||
                    imageInput.at<uchar>(i + 1, j - 1) == 255 || imageInput.at<uchar>(i + 1, j) == 255 ||
                    imageInput.at<uchar>(i + 1, j + 1) == 255) {
                    imageInput.at<uchar>(i, j) = 255;
                    DoubleThresholdLink(imageInput, lowThreshold, highThreshold); //递归调用
                } else {
                    imageInput.at<uchar>(i, j) = 0;
                }
            }
        }
    }
}
```

```c
//
// Created by 大宝宝 on 2017/11/13.
//

#include <iostream>
#include <cstdlib>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>

using namespace cv;
using namespace std;

// RGB图像转换为灰度图像
void ConvertRGB2GRAY(const Mat &image, Mat &imageGray) {
    if (!image.data || image.channels() != 3) {
        return;
    }
    imageGray = Mat::zeros(image.size(), CV_8UC1);
    uchar *pointImage = image.data;
    uchar *pointImageGray = imageGray.data;
    int stepImage = image.step;
    int stepImageGray = imageGray.step;
    for (int i = 0; i < imageGray.rows; i++) {
        for (int j = 0; j < imageGray.cols; j++) {
            pointImageGray[i * stepImageGray + j] =
                    0.114 * pointImage[i * stepImage + 3 * j] + 0.587 * pointImage[i * stepImage + 3 * j + 1] +
                    0.299 * pointImage[i * stepImage + 3 * j + 2];
        }
    }
}

// 生成高斯滤波卷积核
void GetGaussianKernel(double **gaus, const int size, const double sigma) {
    /*
     * gaus: 一个指向含有N个double类型数组的指针
     * size: 高斯卷积核的尺寸
     * sigma: 卷积核的标准差
     */
    const double PI = 4.0 * atan(1.0);
    int center = size / 2;
    double sum = 0;
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            gaus[i][j] = (1 / (2 * PI * sigma * sigma)) *
                         exp(-((i - center) * (i - center) + (j - center) * (j - center)) / (2 * sigma * sigma));
            sum += gaus[i][j];
        }
    }
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            gaus[i][j] /= sum;
        }
    }
    return;
}

// 高斯滤波
void GaussianFilter(const Mat imageSource, Mat &imageGuassian, double **guas, int size) {
    /*
     * imageSource: 待滤波原始图像
     * imageGaussian: 滤波后输出图像
     * gaus: 一个指向含有N个double类型数组的指针
     * size: 滤波核的尺寸
     */
    imageGuassian = Mat::zeros(imageSource.size(), CV_8UC1);
    if (!imageSource.data || imageSource.channels() != 1) {
        return;
    }
    double guasArray[100];
    for (int i = 0; i < size * size; i++) {
        guasArray[i] = 0;
    }
    int array = 0;
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; ++j) {
            guasArray[array] = guas[i][j]; // 二维数组压成一维，方便计算
            array++;
        }
    }
    // 滤波
    for (int i = 0; i < imageSource.rows; i++) {
        for (int j = 0; j < imageGuassian.cols; j++) {
            int k = 0;
            for (int l = -size / 2; l <= size / 2; l++) {
                for (int g = -size / 2; g <= size / 2; g++) {
                    int row = i + l;
                    int col = j + g;
                    row = row < 0 ? 0 : row;
                    row = row >= imageSource.rows ? imageSource.rows - 1 : row;
                    col = col < 0 ? 0 : col;
                    col = col >= imageGuassian.cols ? imageGuassian.cols - 1 : col;
                    imageGuassian.at<uchar>(i, j) += guasArray[k] * imageSource.at<uchar>(row, col);
                    k++;
                }
            }
        }
    }
}

// Sobel等梯度算子计算梯度幅值和方向
void SobelGradDirection(const Mat imageSource, Mat &imageSobelX, Mat &imageSobelY, double *&pointDirection) {
    /*
     * imageSourc: 原始灰度图像
     * imageSobelX: 是X方向梯度图像
     * imageSobelY: 是Y方向梯度图像
     * pointDirection: 是梯度方向角数组指针
     */
    pointDirection = new double[(imageSource.rows - 1) * (imageSource.cols - 1)];
    for (int i = 0; i < (imageSource.rows - 1) * (imageSource.cols - 1); i++) {
        pointDirection[i] = 0;
    }
    imageSobelX = Mat::zeros(imageSource.size(), CV_32SC1);
    imageSobelY = Mat::zeros(imageSource.size(), CV_32SC1);
    uchar *P = imageSource.data;
    uchar *PX = imageSobelX.data;
    uchar *PY = imageSobelY.data;

    int step = imageSource.step;
    int stepXY = imageSobelX.step;
    int k = 0, m = 0, n = 0;

    for (int i = 1; i < (imageSource.rows - 1); i++) {
        for (int j = 1; j < (imageSource.cols - 1); j++) {
            double gradY = P[(i - 1) * step + j + 1] + P[i * step + j + 1] * 2 + P[(i + 1) * step + j + 1] -
                           P[(i - 1) * step + j - 1] - P[i * step + j - 1] * 2 - P[(i + 1) * step + j - 1];
            PY[i * stepXY + j * (stepXY / step)] = abs(gradY);
            double gradX = P[(i + 1) * step + j - 1] + P[(i + 1) * step + j] * 2 + P[(i + 1) * step + j + 1] -
                           P[(i - 1) * step + j - 1] - P[(i - 1) * step + j] * 2 - P[(i - 1) * step + j + 1];
            PX[i * stepXY + j * (stepXY / step)] = abs(gradX);
            if (gradX == 0) {
                gradX = 0.00000000000000001;  // 防止除数为0异常
            }
            pointDirection[k] = atan(gradY / gradX) * 57.3; // 弧度转换为度
            pointDirection[k] += 90; // 由于atan求得的角度范围是-π/2~π/2，为了便于计算，这里对每个梯度角加了一个π/2，使范围变成0~π，便于计算
            k++;
        }
    }
    convertScaleAbs(imageSobelX, imageSobelX);
    convertScaleAbs(imageSobelY, imageSobelY);
}

// 求梯度图的幅值
void SobelAmplitude(const Mat imageGradX, const Mat imageGradY, Mat &SobelAmpXY) {
    /*
     * imageGradX: X方向梯度图像
     * imageGradY: Y方向梯度图像
     * SobelAmpXY: 输出的X、Y方向梯度图像幅值
     */
    SobelAmpXY = Mat::zeros(imageGradX.size(), CV_32FC1);
    for (int i = 0; i < SobelAmpXY.rows; i++) {
        for (int j = 0; j < SobelAmpXY.cols; j++) {
            SobelAmpXY.at<float>(i, j) = sqrt(imageGradX.at<uchar>(i, j) * imageGradX.at<uchar>(i, j) +
                                              imageGradY.at<uchar>(i, j) * imageGradY.at<uchar>(i, j));
        }
    }
    convertScaleAbs(SobelAmpXY, SobelAmpXY);
}

// 对梯度幅值进行非极大值抑制
void LocalMaxValue(const Mat imageInput, Mat &imageOutput, double *pointDirection) {
    /*
     * imageInput: 输入的Sobel梯度图像
     * imageOutPut: 输出的局部极大值抑制图像
     * pointDirection: 图像上每个点的梯度方向数组指针
     */
    imageOutput = imageInput.clone();
    int k = 0;
    for (int i = 1; i < imageInput.rows - 1; i++) {
        for (int j = 1; j < imageInput.cols - 1; j++) {
            int value00 = imageInput.at<uchar>((i - 1), j - 1);
            int value01 = imageInput.at<uchar>((i - 1), j);
            int value02 = imageInput.at<uchar>((i - 1), j + 1);
            int value10 = imageInput.at<uchar>((i), j - 1);
            int value11 = imageInput.at<uchar>((i), j);
            int value12 = imageInput.at<uchar>((i), j + 1);
            int value20 = imageInput.at<uchar>((i + 1), j - 1);
            int value21 = imageInput.at<uchar>((i + 1), j);
            int value22 = imageInput.at<uchar>((i + 1), j + 1);
            if (pointDirection[k] > 0 && pointDirection[k] <= 45) {
                if (value11 <= (value12 + (value02 - value12) * tan(pointDirection[i * imageOutput.rows + j])) ||
                    (value11 <= (value10 + (value20 - value10) * tan(pointDirection[i * imageOutput.rows + j])))) {
                    imageOutput.at<uchar>(i, j) = 0;
                }
            }
            if (pointDirection[k] > 45 && pointDirection[k] <= 90) {
                if (value11 <= (value01 + (value02 - value01) / tan(pointDirection[i * imageOutput.cols + j])) ||
                    value11 <= (value21 + (value20 - value21) / tan(pointDirection[i * imageOutput.cols + j]))) {
                    imageOutput.at<uchar>(i, j) = 0;

                }
            }
            if (pointDirection[k] > 90 && pointDirection[k] <= 135) {
                if (value11 <= (value01 + (value00 - value01) / tan(180 - pointDirection[i * imageOutput.cols + j])) ||
                    value11 <= (value21 + (value22 - value21) / tan(180 - pointDirection[i * imageOutput.cols + j]))) {
                    imageOutput.at<uchar>(i, j) = 0;
                }
            }
            if (pointDirection[k] > 135 && pointDirection[k] <= 180) {
                if (value11 <= (value10 + (value00 - value10) * tan(180 - pointDirection[i * imageOutput.cols + j])) ||
                    value11 <= (value12 + (value22 - value11) * tan(180 - pointDirection[i * imageOutput.cols + j]))) {
                    imageOutput.at<uchar>(i, j) = 0;
                }
            }
            k++;
        }
    }
}

// 双阈值处理
void DoubleThreshold(Mat &imageInput, double lowThreshold, double highThreshold) {
    /*
     * imageInput: 输入和输出的的Sobel梯度幅值图像
     * lowThreshold: 低阈值
     * highThreshold: 高阈值
     */
    for (int i = 0; i < imageInput.rows; i++) {
        for (int j = 0; j < imageInput.cols; j++) {
            if (imageInput.at<uchar>(i, j) > highThreshold) {
                imageInput.at<uchar>(i, j) = 255;
            }
            if (imageInput.at<uchar>(i, j) < lowThreshold) {
                imageInput.at<uchar>(i, j) = 0;
            }
        }
    }
}

// 双阈值中间像素滤除或连接处理
void DoubleThresholdLink(Mat &imageInput, double lowThreshold, double highThreshold) {
    /*
     * imageInput: 输入和输出的的Sobel梯度幅值图像
     * lowThreshold: 低阈值
     * highThreshold: 高阈值
     */
    for (int i = 1; i < imageInput.rows - 1; i++) {
        for (int j = 1; j < imageInput.cols - 1; j++) {
            if (imageInput.at<uchar>(i, j) > lowThreshold && imageInput.at<uchar>(i, j) < 255) {
                if (imageInput.at<uchar>(i - 1, j - 1) == 255 || imageInput.at<uchar>(i - 1, j) == 255 ||
                    imageInput.at<uchar>(i - 1, j + 1) == 255 ||
                    imageInput.at<uchar>(i, j - 1) == 255 || imageInput.at<uchar>(i, j) == 255 ||
                    imageInput.at<uchar>(i, j + 1) == 255 ||
                    imageInput.at<uchar>(i + 1, j - 1) == 255 || imageInput.at<uchar>(i + 1, j) == 255 ||
                    imageInput.at<uchar>(i + 1, j + 1) == 255) {
                    imageInput.at<uchar>(i, j) = 255;
                    DoubleThresholdLink(imageInput, lowThreshold, highThreshold); //递归调用
                } else {
                    imageInput.at<uchar>(i, j) = 0;
                }
            }
        }
    }
}

int main() {

    Mat img = imread("./images/road1.pgm");
    Mat imgGray;
    ConvertRGB2GRAY(img, imgGray);
    imshow("gray-img", imgGray);

    const int SIZE = 5;
    // double guas[SIZE][SIZE];
    double **guas = new double *[SIZE];
    for (int i = 0; i < SIZE; i++) {
        guas[i] = new double[SIZE];
    }
    GetGaussianKernel(guas, 5, 1.0);
    //    0.00296902 0.0133062 0.0219382 0.0133062 0.00296902
    //    0.0133062 0.0596343 0.0983203 0.0596343 0.0133062
    //    0.0219382 0.0983203 0.162103 0.0983203 0.0219382
    //    0.0133062 0.0596343 0.0983203 0.0596343 0.0133062
    //    0.00296902 0.0133062 0.0219382 0.0133062 0.00296902
    Mat imageGuassian;
    GaussianFilter(imgGray, imageGuassian, guas, 5);
    imshow("img-guassian", imageGuassian);

    Mat imageSobelX, imageSobelY;
    double *pointDirection;
    SobelGradDirection(imageGuassian, imageSobelX, imageSobelY, pointDirection);
    imshow("img-sobelX", imageSobelX);
    imshow("img-sobelY", imageSobelY);
    Mat SobelAmpXY;
    SobelAmplitude(imageSobelX, imageSobelY, SobelAmpXY);
    imshow("img-sobelXY", SobelAmpXY);

    Mat imgLocalMaxValue;
    LocalMaxValue(SobelAmpXY, imgLocalMaxValue, pointDirection);
    imshow("img-localmax", imgLocalMaxValue);

    DoubleThreshold(imgLocalMaxValue, 90, 160);
    imshow("img-localmax-DoubleThreshold", imgLocalMaxValue);

    DoubleThresholdLink(imgLocalMaxValue, 90, 160);
    imshow("img-localmax-DoubleThresholdLink", imgLocalMaxValue);

    waitKey(0);

    return 0;
}
```

参考: [http://blog.csdn.net/zhubaohua_bupt/article/details/73826080](http://blog.csdn.net/zhubaohua_bupt/article/details/73826080)

参考: [http://blog.csdn.net/dcrmg/article/details/52344902](http://blog.csdn.net/dcrmg/article/details/52344902)
