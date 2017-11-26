# OpenCV —— ML

```c
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/ml.hpp>

using namespace cv;
using namespace cv::ml;
using namespace std;

int main (int argc, char* argv[]) {
    int width = 512, height = 512;
    Mat image = Mat::zeros(height, width, CV_8UC3);

    int labels[4] = {1, -1, -1, -1};
    float trainingData[4][2] = { {501, 10}, {255, 10}, {501, 255}, {10, 501} };
    // The function cv::ml::SVM::train that will be used afterwards requires the training data to be stored as cv::Mat objects of floats
    Mat trainingDataMat(4, 2, CV_32FC1, trainingData);
    Mat labelsMat(4, 1, CV_32SC1, labels);

    Ptr<SVM> svm = SVM::create();
    svm->setType(SVM::C_SVC);  // the type C_SVC that can be used for n-class classification (n ≥ 2)
    svm->setKernel(SVM::LINEAR);
    svm->setTermCriteria(TermCriteria(TermCriteria(TermCriteria::MAX_ITER, 100, 1e-6)));
    svm->train(trainingDataMat, ROW_SAMPLE, labelsMat);  // Train the SVM

    // Show the decision regions given by the SVM
    Vec3b green(0, 255, 0), blue(255, 0, 0);
    for (int i = 0; i < image.rows; i++) {
        for (int j = 0; j < image.cols; j++) {
            Mat SampleMat = (Mat_<float>(1, 2) << j, i);
            float response = svm->predict(SampleMat);

            if (response == 1)
                image.at<Vec3b>(i, j) = green;
            else if (response == -1)
                image.at<Vec3b>(i, j) = blue;
        }
    }

    int thickness = 2;
    int lineType = 8;
    circle( image, Point(501,  10), 5, Scalar(  0,   0,   0), thickness, lineType );
    circle( image, Point(255,  10), 5, Scalar(255, 255, 255), thickness, lineType );
    circle( image, Point(501, 255), 5, Scalar(255, 255, 255), thickness, lineType );
    circle( image, Point( 10, 501), 5, Scalar(255, 255, 255), thickness, lineType );

    thickness = 2;
    lineType  = 8;
    Mat sv = svm->getUncompressedSupportVectors();

    for (int i = 0; i < sv.rows; i++) {
        const float* v = sv.ptr<float>(i);
        circle(image, Point((int) v[0], (int) v[1]), 6, Scalar(128, 128, 128), thickness, lineType);
    }

    imwrite("result.png", image);
    imshow("SVM Simple Example", image);

    waitKey(0);

    return 0;
}
```
