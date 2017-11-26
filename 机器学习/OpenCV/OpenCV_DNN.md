# OpenCV —— DNN

## Example —— Load Caffe framework models

download GoogLeNet model files: [bvlc_googlenet.prototxt](https://raw.githubusercontent.com/opencv/opencv/master/samples/data/dnn/bvlc_googlenet.prototxt) and [bvlc_googlenet.caffemodel](http://dl.caffe.berkeleyvision.org/bvlc_googlenet.caffemodel)

Also need file with names of ILSVRC2012 classes: [synset_words.txt](https://raw.githubusercontent.com/opencv/opencv/master/samples/data/dnn/synset_words.txt).

```c
#include <opencv2/dnn.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/core/utils/trace.hpp>
using namespace cv;
using namespace cv::dnn;

#include <fstream>
#include <iostream>
#include <cstdlib>
using namespace std;

static void getMaxClass(const Mat &probBlob, int *classId, double *classProb) {
    Mat probMat = probBlob.reshape(1, 1); // reshape the blob to 1x1000 matrix
    Point classNumber;
    minMaxLoc(probBlob, NULL, classProb, NULL, &classNumber);
    *classId = classNumber.x;
}

static vector<String> readClassNames(const char *filename = "synset_words.txt") {
    std::vector<String> classNames;

    std::ifstream fp(filename);
    if (!fp.is_open()) {
        std::cerr << "File with classes labels not found: " << filename << std::endl;
        exit(-1);
    }

    std::string name;
    while (!fp.eof()) {
        std::getline(fp, name);
        if (name.length())
            classNames.push_back(name.substr(name.find(' ') + 1));
    }
    fp.close();

    return classNames;
}

int main(int argc, const char * argv[]) {

    CV_TRACE_FUNCTION();

    String modelTxt = "bvlc_googlenet.prototxt";
    String modelBin = "bvlc_googlenet.caffemodel";
    String imageFile = (argc > 1) ? argv[1] : "space_shuttle.jpg";

    Net net;

    try {
        net = dnn::readNetFromCaffe(modelTxt, modelBin); // Read and initialize network using path to .prototxt and .caffemodel files
    } catch (cv::Exception& e) {
        std::cerr << "Exception: " << e.what() << std::endl;
        if (net.empty()) {
            std::cerr << "Can't load network by using the following files: " << std::endl;
            std::cerr << "prototxt:   " << modelTxt << std::endl;
            std::cerr << "caffemodel: " << modelBin << std::endl;
            std::cerr << "bvlc_googlenet.caffemodel can be downloaded here:" << std::endl;
            std::cerr << "http://dl.caffe.berkeleyvision.org/bvlc_googlenet.caffemodel" << std::endl;
            exit(-1);
        }
    }

    Mat img = imread(imageFile);
    if (img.empty()) {
        std::cerr << "Can't read image from the file: " << imageFile << std::endl;
        exit(-1);
    }

    // GoogLeNet accepts only 224x224 BGR-images
    Mat inputBlob = blobFromImage(img, 1.0f, Size(224, 224), Scalar(104, 117, 123), false); // use special cv::dnn::blobFromImages constructor to  convert the image to 4-dimensional blob (so-called batch) with 1x3x224x224 shape

    Mat prob;
    cv::TickMeter t;
    for (int i = 0; i < 10; i++) {
        CV_TRACE_REGION("forward");
        net.setInput(inputBlob, "data"); // In bvlc_googlenet.prototxt the network input blob named as "data"
        t.start();
        prob = net.forward("prob");
        t.stop();
    }

    int classId;
    double classProb;
    getMaxClass(prob, &classId, &classProb); // find the best class

    vector<String> classNames = readClassNames();
    std::cout << "Best class: #" << classId << " '" << classNames.at(classId) << "'" << std::endl;
    std::cout << "Probability: " << classProb * 100 << "%" << std::endl;
    std::cout << "Time: " << (double)t.getTimeMilli() / t.getCounter() << " ms (average from " << t.getCounter() << " iterations)" << std::endl;

    return 0;
}
```
