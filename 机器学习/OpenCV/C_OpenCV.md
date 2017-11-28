# OpenCV 基础

### 图像矩阵

访问像素：

```
value = Row_i * num_col * num_channels + Col_i + channel_j
```

读取图像示例：

```c
#include <iostream>
#include <string>
#include <sstream>

using namespace std;

#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
using namespace cv;

int main (int argc, const char** argv) {

    // 读取图像
    string filename = "./images/IMG_7927.jpg";
    Mat color = imread(filename);
    Mat gray = imread(filename, CV_LOAD_IMAGE_GRAYSCALE);  // 图像转化为灰度

    // 读取像素
    int myRow = color.rows - 1;
    int myCol = color.cols - 1;
    Vec3b pixel = color.at<Vec3b>(myRow, myCol);
    cout << (int) pixel[0] << "," << (int) pixel[1] << "," << (int) pixel[2] << endl;

    // 展示图像
    imshow("color", color);
    imshow("gray", gray);

    waitKey(0);

    return 0;
}
```

读取视频示例：

```c
#include <iostream>
#include <string>
#include <sstream>

using namespace std;

#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
using namespace cv;

// OpenCV 命令行解析器函数
// 命令行解析器接受的按键
const char* keys = {
        "{help h usage ? | | print this message}"
        "{@video | | video file, if not defined try to use webcamera}"
};

int main (int argc, const char** argv) {

    CommandLineParser parser(argc, argv, keys);
    parser.about("video example");

    if (parser.has("help")) {  // 如果需要，显示帮助文档
        parser.printMessage();
        return 0;
    }
    String videoFile = parser.get<String>(0);

    if (!parser.check()) {  // 分析 params 的变量，检查 params 是否正确
        parser.printErrors();
        return 0;
    }

    VideoCapture cap;
    if (videoFile != "") {
        cap.open(videoFile);
    } else {
        cap.open(0);  // 打开默认相机
    }

    if (!cap.isOpened())  // 检查是否打开成功
        return -1;

    namedWindow("video", 1);
    for (;;) {
        Mat frame;
        cap >> frame;
        imshow("video", frame);
        if (waitKey(30) >= 0) break;
    }

    cap.release();  // 释放摄像机或video cap

    return 0;
}
```

### 基本图形界面

- `moveWindow(window_name, x, y)`
- `resizeWindow(window_name, width, height)`
- `destroyWindow(window_name)`
- `destroyAllWindows()`


- `createTrackbar(bar_name, window_name, init_value, max_value, callback, data)`
- `setMouseCallback(window_name, callback, data)`


创建 Trackbar 和 鼠标事件 示例：

```c
#include <iostream>
#include <string>
#include <sstream>

using namespace std;

#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
using namespace cv;

// 保存滑动条位置值
int blurAmount = 15;

// 滑动条的回掉函数
static void onChange(int pos, void* userInput) {
    if (pos <= 0)
        return;
    Mat imgBlur;

    Mat* img = (Mat*) userInput;
    blur(*img, imgBlur, Size(pos, pos));

    imshow("image", imgBlur);
}

// 鼠标的回掉
static void onMouse(int event, int x, int y, int, void* userInput) {
    if (event != EVENT_LBUTTONDOWN) // 当用户按下鼠标左键
        return;
    // do something
}

int main (int argc, const char** argv) {

    Mat img = imread("./images/IMG_7927.jpg");
    namedWindow("image", WINDOW_NORMAL);

    // 创建滑动条
    createTrackbar("blur", "image", &blurAmount, 30, onChange, &img);

    setMouseCallback("image", onMouse, &img);

    // 调用 onChange 以初始化
    onChange(blurAmount, &img);

    waitKey(0);

    destroyAllWindows();

    return 0;
}
```
