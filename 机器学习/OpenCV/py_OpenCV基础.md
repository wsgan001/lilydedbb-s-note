# OpenCV 基础

# 设置 ROI

```python
import cv2

img = cv2.imread('./images/IMG_7927.jpg')
my_roi = img[100:200, 300:600, :]
plt.imshow(my_roi)
```

### 视频读/写

```python
import cv2

videoCapture = cv2.VideoCapture('./videos/20171106230613.mp4')
fps = videoCapture.get(cv2.CAP_PROP_FPS)
size = (int(videoCapture.get(cv2.CAP_PROP_FRAME_WIDTH)),
       int(videoCapture.get(cv2.CAP_PROP_FRAME_HEIGHT)))
videoWriter = cv2.VideoWriter('./videos/output.mp4', cv2.VideoWriter_fourcc('X', 'V', 'I', 'D'), fps, size)

success, frame = videoCapture.read()
while success:
    videoWriter.write(frame)
    success, frame = videoCapture.read()
```


### 获取摄像头的帧

```python
import cv2

cameraCapture = cv2.VideoCapture(0)
fps = 30
size = (int(cameraCapture.get(cv2.CAP_PROP_FRAME_WIDTH)),
       int(cameraCapture.get(cv2.CAP_PROP_FRAME_HEIGHT)))
videoWriter = cv2.VideoWriter(
    './videos/camera_output.avi', cv2.VideoWriter_fourcc('I', '4', '2', '0'),
    fps, size)

success, frame = cameraCapture.read()
numFramesRemaining = 10 * fps - 1
while success and numFramesRemaining > 0:
    videoWriter.write(frame)
    success, frame = cameraCapture.read()
    numFramesRemaining -= 1

cameraCapture.release()
```


### # 在窗口显示图像

```python
import cv2

img = cv2.imread('./images/IMG_7927.jpg')
cv2.imshow('image', img)
cv2.waitKey(0)
cv2.destroyAllWindows()
```


### 在窗口显示摄像头帧

```python
import cv2

clicked = False
def onMouse(event, x, y, flags, param):
    global clicked
    if event == cv2.EVENT_LBUTTONUP:
        click = True

cameraCapture = cv2.VideoCapture(0)
cv2.namedWindow('window')
cv2.setMouseCallback('window', onMouse)

success, frame = cameraCapture.read()
while success and cv2.waitKey(1) == -1 and not clicked:
    cv2.imshow('window', frame)
    success, frame = cameraCapture.read()

cv2.destroyWindow('window')
cameraCapture.release()
```
