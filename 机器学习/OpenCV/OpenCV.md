# OpenCV Example

```c
#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
using namespace std;
using namespace cv;

int main(int argc, const char * argv[]) {

    IplImage* img = 0;
    int height, width, step, channels;
    uchar* data;

    if (argc < 2) {
        cout << "Usage: main <image-file-name>" << endl;
        exit(0);
    }

    img = cvLoadImage(argv[1]);
    if (!img) {
        cout << "Could not load image file:" << argv[1] << endl;
        exit(0);
    }

    height = img->height;
    width = img->width;
    step = img->widthStep;
    channels = img->nChannels;
    data = (uchar*) img->imageData;
    cout << step << endl;
    cout << "Processing a " << height << "x" << width << " image with " << channels << " channels" << endl;

    namedWindow("mainWin", WINDOW_AUTOSIZE);
    cvMoveWindow("mianWin", 100, 100);

    for (int i = 0; i < height; i++)
        for (int j = 0; j < width; j++)
            for (int k = 0; k < channels; k++)
                data[i * step + j * channels + k] = 255 - data[i * step + j * channels + k];
    cvShowImage("mainWin", img);

    waitKey(0);
    cvReleaseImage(&img);

    return 0;
}
```

## Cascade Classifier -- face detection

image face detection:

```c
#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/objdetect.hpp>
#include <opencv2/imgproc.hpp>
using namespace cv;
using namespace std;

const char* cascade_name = "./haarcascades/haarcascade_frontalface_alt.xml";

int main (int argc, char* argv[]) {

    CascadeClassifier cascade;
    cascade.load(cascade_name);

    cvNamedWindow("result");
    Mat image = imread(argv[1], 1);

    // create a b&w image of the same size object as a placeholder for now
    Mat gray;
    cvtColor(image, gray, CV_RGB2GRAY);

    vector<Rect> faces;
    cascade.detectMultiScale(image, faces, 1.1, 2, 0 | CASCADE_SCALE_IMAGE, Size(30, 30));

    for (int i = 0; i < faces.size(); i++) {
        Point LeftTop(faces[i].x, faces[i].y);
        Point RightBottom(faces[i].x + faces[i].width, faces[i].y + faces[i].height);
        rectangle(image, LeftTop, RightBottom, Scalar(255, 0, 255), 1, 8, 0);
    }

    imshow("result", image);

    waitKey(0);

    return 0;
}
```

video face detection:

```c
#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/objdetect.hpp>
#include <opencv2/video.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
using namespace std;
using namespace cv;

void detectAndDisplay (Mat frame);

String face_cascade_name, eyes_cascade_name;
CascadeClassifier face_cascade;
CascadeClassifier eyes_cascade;
String window_name = "Capture - Face detection";

int main(int argc, const char * argv[]) {

    CommandLineParser parser(argc, argv,
                             "{help h||}"
                             "{face_cascade|./haarcascades/haarcascade_frontalface_alt.xml|}"
                             "{eyes_cascade|./haarcascades/haarcascade_eye_tree_eyeglasses.xml|}");

    cout << "This program demonstrates using the cv::CascadeClassifier class to detect objects (Face + eyes) in a video stream.\n" << "You can use Haar or LBP features." << endl;

    parser.printMessage();

    face_cascade_name = parser.get<string>("face_cascade");
    eyes_cascade_name = parser.get<string>("eyes_cascade");
    VideoCapture capture;
    Mat frame;

    if (!face_cascade.load(face_cascade_name)) { cout << "--(!)Error loading face cascade" << endl; return -1; }
    if (!eyes_cascade.load(eyes_cascade_name)) { cout << "--(!)Error loading eye cascade" << endl; return -1; }

    capture.open(0);
    if (!capture.isOpened()) { cout << "--(!)Error opening video capture" << endl; return -1; }

    while (capture.read(frame)) {
        if (frame.empty()) {
            cout << " --(!) No captured frame -- Break!" << endl;
            break;
        }
        detectAndDisplay(frame);

        char c = (char) waitKey(10);
        if (c == 27) { break; } // esc
    }

    return 0;
}

void detectAndDisplay (Mat frame) {
    vector<Rect> faces;
    Mat frame_gray;

    cvtColor(frame, frame_gray, COLOR_BGR2GRAY);
    equalizeHist(frame_gray, frame_gray);

    // Detect faces
    face_cascade.detectMultiScale(frame_gray, faces, 1.1, 2, 0 | CASCADE_SCALE_IMAGE, Size(30, 30));

    for (int i = 0; i < faces.size(); i++) {
        Point center(faces[i].x + faces[i].width / 2, faces[i].y + faces[i].height / 2);
        ellipse(frame, center, Size(faces[i].width / 2, faces[i].height / 2), 0, 0, 360, Scalar(255, 0, 255), 4, 8, 0);

        // In each face, detect eyes
        Mat faceROI = frame_gray(faces[i]);
        vector<Rect> eyes;
        eyes_cascade.detectMultiScale(faceROI, eyes, 1.1, 2, 0 | CASCADE_SCALE_IMAGE, Size(30, 30));

        for (int j = 0; j < eyes.size(); j++) {
            Point eye_center(faces[i].x + eyes[j].x + eyes[j].width / 2, faces[i].y + eyes[j].y + eyes[j].height / 2);
            int radius = cvRound((eyes[j].width + eyes[j].height) * 0.25);
            circle(frame, eye_center, radius, Scalar(255, 0, 0), 4, 8, 0);
        }
    }
    imshow(window_name, frame);
}
```