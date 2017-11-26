# You Only Look Once: Unified, Real-Time Object Detection

Drawback of R-CNN:

R-CNN use region proposal methods to first generate potential bounding boxes in an im- age and then run a classifier on these proposed boxes. After classification, post-processing is used to refine the bound- ing boxes, eliminate duplicate detections, and rescore the boxes based on other objects in the scene [13]. These com- plex pipelines are slow and hard to optimize because each individual component must be trained separately.

> We reframe object detection as a single regression prob- lem, straight from image pixels to bounding box coordi- nates and class probabilities. Using our system, you only look once (YOLO) at an image to predict what objects are present and where they are.


## YOLO

1. resizes the input image to 448 x 448
2. runs a single convolutional network on the image
3. thresholds the resulting detection by the model's confidence

**A single convolutional network simultaneously predicts multiple bounding boxes and class probabilities for those boxes. YOLO trains on full images and directly optimizes detection performance. This unified model has several benefits over traditional methods of object detection.**

- extremely fast

- YOLO reasons globally about the image when making prediction

    > YOLO sees the entire image during training and test time so it implicitly encodes contextual information about classes as well as their appearance. Fast R-CNN, a top detection method, mistakes background patches in an image for objects because it can’t see the larger context. YOLO makes less than half the number of background errors compared to Fast R-CNN.

- YOLO learns generalizable representations of objects


## Unified Detection

- Divides the input image into S x S grid. If the center of an object falls into a grid cell, that grid cell is responsible for detecting that object.

- Each grid cell predicts B bounding boxes and confidence scores for those boxes. Define confidence as:

    ```math
    Pr(object) * IOU_{pred}^{truth}
    ```

    If no pred object exists in that cell, the confidence scores should be zero. Otherwise we want the confidence score to equal the intersection over union (IOU) between the predicted box and the ground truth.

    Each bounding box consists of 5 predictions: x, y, w, h, and confidence.

- Each grid cell also predicts C conditional class probabilities:

    ```math
    Pr(Class_i | Object)
    ```

    We only predict one set of class probabilities per grid cell, regardless of the number of boxes B

- Class-specific confidence scores for each box:

    ```math
    Pr(Class_i | Object) * Pr(Object) * IOU_{pred}^{truth} = Pr(Class_i) * IOU_{pred}^{truth}
    ```

    > These scores encode both the probability of that class appearing in the box and how well the predicted box fits the object.


##  The Architecture

Our detection network has 24 convolutional layers followed by 2 fully connected layers. Alternating 1 × 1 convolutional layers reduce the features space from preceding layers.


## Training

Our final layer predicts both class probabilities and bounding box coordinates. We normalize the bounding box width and height by the image width and height so that they fall between 0 and 1.

```math
w = \frac {width_{box}} {width_{image}}

h = \frac {height_{box}} {height_{image}}
```

We parametrize the bounding box x and y coordinates to be offsets of a particular grid cell location so they are also bounded between 0 and 1.

```math
x = x_c \cdot \frac {S}{width_{image}} - col = \frac {x_c}{width_{grid}} - col

y = y_c \cdot \frac {S}{height_{image}} - row = \frac {y_c}{height_{grid}} - row
```

We use a linear activation function for the final layer and all other layers use the following **leaky rectified linear activation**.

We optimize for **sum-squared error** in the output of our model.

Loss Function Problems:

1. It weights localization error equally with classification error which may not be ideal.
2. Also, in every image many grid cells do not contain any object. This pushes the “confidence” scores of those cells towards zero, often overpowering the gradient from cells that do contain objects.

To remedy 1. 2., **we increase the loss from bounding box coordinate predictions and decrease the loss from confidence predictions for boxes that don’t contain objects**. We use two parameters, λcoord and λnoobj to accomplish this. Set:

```math
\lambda_{coord} = 5 \ \ \ and \ \ \  \lambda_{noobj} = .5
```

3. Sum-squared error also equally weights errors in large boxes and small boxes, while it should reflect that small deviations in large boxes matter less than in small boxes.

### Loss Function

```math
L = \lambda_{coord} \sum_{i = 0}^{S^2} \sum_{j = 0}^{B} 1_{ij}^{obj}[(x - \hat x_i)^2 + (y - \hat y_i)^2 + (\sqrt {w_i} - \sqrt {\hat w_i})^2 + (\sqrt {h_i} - \sqrt {h_i})^2]

+ \sum_{i = 0}^{S^2} 1_{ij}^{obj}(C_i - \hat C_i)^2

+ \lambda_{noobj} \sum_{i = 0}^{S^2} 1_{ij}^{noobj}(C_i - \hat C_i)^2 + \sum_{i = 0}^{S^2} 1_{i}^{obj} \sum_{c \in classes}(p_i(c) - \hat p_i(c))^2
```

**Note that the loss function only penalizes classification
error if an object is present in that grid cell (hence the conditional class probability discussed earlier). It also only penalizes bounding box coordinate error if that predictor is “responsible” for the ground truth box (i.e. has the highest IOU of any predictor in that grid cell).**

To avoid overfitting we use dropout and extensive data augmentation. A dropout layer with rate = .5 after the first connected layer prevents co-adaptation between layers.


## Inference

The grid design enforces spatial diversity in the bound- ing box predictions. Often it is clear which grid cell an object falls in to and the network only predicts one box for each object. However, **some large objects or objects near the border of multiple cells can be well localized by multiple cells**. **Non-maximal suppression** can be used to fix these multiple detections.


## Limitations of YOLO

- YOLO imposes strong spatial constraints on bounding box predictions since each grid cell only predicts two boxes and can only have one class. This spatial constraint lim- its the number of nearby objects that our model can pre- dict. Our model struggles with small objects that appear in groups, such as flocks of birds.
- Since our model learns to predict bounding boxes from data, it struggles to generalize to objects in new or unusual aspect ratios or configurations.

