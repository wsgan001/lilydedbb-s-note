# Faster R-CNN 源码 —— ProposalLayer

`py-faster-rcnn` 中关于 **ROIPooling** 层的 prototxt:

```
layer {
  name: 'proposal'
  type: 'Python'
  bottom: 'rpn_cls_prob_reshape'
  bottom: 'rpn_bbox_pred'
  bottom: 'im_info'
  top: 'rpn_rois'
#  top: 'rpn_scores'
  python_param {
    module: 'rpn.proposal_layer'
    layer: 'ProposalLayer'
    param_str: "'feat_stride': 16"
  }
}
```

`ProposalLayer` 的源码中有一段注释对其算法流程进行了解释：

```
Algorithm:

for each (H, W) location i
  generate A anchor boxes centered on cell i
  apply predicted bbox deltas at cell i to each of the A anchors
clip predicted boxes to image
remove predicted boxes with either height or width < threshold
sort all (proposal, score) pairs by score from highest to lowest
take top pre_nms_topN proposals before NMS
apply NMS with threshold 0.7 to remaining proposals
take after_nms_topN proposals after NMS
return the top proposals (-> RoIs top, scores top)
```

**Setup**:

```python
def setup(self, bottom, top):
    # parse the layer parameter string, which must be valid YAML
    # layer_params = yaml.load(self.param_str_)
    layer_params = yaml.load(self.param_str)

    self._feat_stride = layer_params['feat_stride']
    anchor_scales = layer_params.get('scales', (8, 16, 32))
    anchor_ratios = layer_params.get('ratios', (0.5, 1, 2))
    self._anchors = generate_anchors(scales=np.array(anchor_scales), ratios=np.array(anchor_ratios))
    self._num_anchors = self._anchors.shape[0]

    if DEBUG:
        print 'feat_stride: {}'.format(self._feat_stride)
        print 'anchors:'
        print self._anchors

    # rois blob: holds R regions of interest, each is a 5-tuple
    # (n, x1, y1, x2, y2) specifying an image batch index n and a
    # rectangle (x1, y1, x2, y2)
    top[0].reshape(1, 5)

    # scores blob: holds scores for R regions of interest
    if len(top) > 1:
        top[1].reshape(1, 1, 1, 1)
```

**Forward**:

首先初始化一些配置和变量：

- `bottom[0]`: `rpn_cls_prob_reshape` 传过来的 cls_scores, shape 为 (N, 2 * A, H, W), A 为 anchors 的数量
- `bottom[1]`: `rpn_bbox_pred` 传过来的 bbox_deltas, shape 为 (N, 4 * A, H, W)
- `bottom[2]`: `data` 层传过来的 `im_info`: [M, N, scale_factor] 保存了原始图像的信息【图片在传入 Faster R-CNN 之前会 resize 为固定的 `M x N`，`im_info` 保存了这次 resize 的所有信息】

```python
# the first set of _num_anchors channels are bg probs
# the second set are the fg probs, which we want
scores = bottom[0].data[:, self._num_anchors:, :, :]
bbox_deltas = bottom[1].data
im_info = bottom[2].data[0, :]
```

***1. Generate proposals from bbox deltas and shifted anchors***

首先产生了 feature map 的每一个位置（坐标对应于 original image）

```python
height, width = scores.shape[-2:]

# Enumerate all shifts
shift_x = np.arange(0, width) * self._feat_stride
shift_y = np.arange(0, height) * self._feat_stride
shift_x, shift_y = np.meshgrid(shift_x, shift_y)
shifts = np.vstack((shift_x.ravel(), shift_y.ravel(),
                    shift_x.ravel(), shift_y.ravel())).transpose()
# print(shifts)
# [[  0   0   0   0]
#  [ 16   0  16   0]
#  [ 32   0  32   0]
#  [ 48   0  48   0]
#  [ 64   0  64   0]
#  [ 80   0  80   0]
#  [ 96   0  96   0]
#  [112   0 112   0]
#  [128   0 128   0]
#  [144   0 144   0]
#  [160   0 160   0]
#  [176   0 176   0]
#  [192   0 192   0]
#  [208   0 208   0]
#  [  0  16   0  16]
#  [ 16  16  16  16]
#  [ 32  16  32  16]
#  [ 48  16  48  16]
#  [ 64  16  64  16]
#  [ 80  16  80  16]
#  [ 96  16  96  16]
#  [112  16 112  16]
#  ....
```

然后将生成的 anchors 偏移到相应的上面的每一个位置：

```python
# Enumerate all shifted anchors:
#
# add A anchors (1, A, 4) to
# cell K shifts (K, 1, 4) to get
# shift anchors (K, A, 4)
# reshape to (K*A, 4) shifted anchors
A = self._num_anchors
K = shifts.shape[0]
anchors = self._anchors.reshape((1, A, 4)) + \
          shifts.reshape((1, K, 4)).transpose((1, 0, 2))
anchors = anchors.reshape((K * A, 4))
```

对 bbox_deltas 和 scores 进行 reshape：

```python
# Transpose and reshape predicted bbox transformations to get them
# into the same order as the anchors:
#
# bbox deltas will be (1, 4 * A, H, W) format
# transpose to (1, H, W, 4 * A)
# reshape to (1 * H * W * A, 4) where rows are ordered by (h, w, a)
# in slowest to fastest order
bbox_deltas = bbox_deltas.transpose((0, 2, 3, 1)).reshape((-1, 4))

# Same story for the scores:
#
# scores are (1, A, H, W) format
# transpose to (1, H, W, A)
# reshape to (1 * H * W * A, 1) where rows are ordered by (h, w, a)
scores = scores.transpose((0, 2, 3, 1)).reshape((-1, 1))
```

对每一个 anchors，根据 bbox_deltas 回归得到 predicted proposals：

```python
# Convert anchors into proposals via bbox transformations
proposals = bbox_transform_inv(anchors, bbox_deltas)
```

`bbox_transform_inv` 函数：

```python
def bbox_transform_inv(boxes, deltas):
    if boxes.shape[0] == 0:
        return np.zeros((0, deltas.shape[1]), dtype=deltas.dtype)

    boxes = boxes.astype(deltas.dtype, copy=False)

    widths = boxes[:, 2] - boxes[:, 0] + 1.0
    heights = boxes[:, 3] - boxes[:, 1] + 1.0
    ctr_x = boxes[:, 0] + 0.5 * widths
    ctr_y = boxes[:, 1] + 0.5 * heights

    dx = deltas[:, 0::4]
    dy = deltas[:, 1::4]
    dw = deltas[:, 2::4]
    dh = deltas[:, 3::4]

    pred_ctr_x = dx * widths[:, np.newaxis] + ctr_x[:, np.newaxis]
    pred_ctr_y = dy * heights[:, np.newaxis] + ctr_y[:, np.newaxis]
    pred_w = np.exp(dw) * widths[:, np.newaxis]
    pred_h = np.exp(dh) * heights[:, np.newaxis]

    pred_boxes = np.zeros(deltas.shape, dtype=deltas.dtype)
    # x1
    pred_boxes[:, 0::4] = pred_ctr_x - 0.5 * pred_w
    # y1
    pred_boxes[:, 1::4] = pred_ctr_y - 0.5 * pred_h
    # x2
    pred_boxes[:, 2::4] = pred_ctr_x + 0.5 * pred_w - 1
    # y2
    pred_boxes[:, 3::4] = pred_ctr_y + 0.5 * pred_h - 1

    return pred_boxes
```

***2. clip predicted boxes to image***

把超出图片边界的 predicted proposals 进行裁剪：

```python
proposals = clip_boxes(proposals, im_info[:2])
```

***3. remove predicted boxes with either height or width < threshold***

把小于阈值的 predicted boxes 过滤掉：

这里的 min_size 源于设置 (这里的 min_size 相对于 feature map 的大小，需乘以 `im_info[2]` 才对应于原始图片的大小)

```python
min_size = cfg[cfg_key].RPN_MIN_SIZE
```

```python
# (NOTE: convert min_size to input image scale stored in im_info[2])
keep = _filter_boxes(proposals, min_size * im_info[2])
proposals = proposals[keep, :]
scores = scores[keep]

# ....

def _filter_boxes(boxes, min_size):
    """Remove all boxes with any side smaller than min_size."""
    ws = boxes[:, 2] - boxes[:, 0] + 1
    hs = boxes[:, 3] - boxes[:, 1] + 1
    keep = np.where((ws >= min_size) & (hs >= min_size))[0]
    return keep
```

***4. sort all (proposal, score) pairs by score from highest to lowest***

按照 scores 从大到小进行排序：

```python
order = scores.ravel().argsort()[::-1]
```

***5. take top pre_nms_topN (e.g. 6000)***

进行 NMS 之前，保留排序后的前多少个：

```python
order = scores.ravel().argsort()[::-1]
if pre_nms_topN > 0:
    order = order[:pre_nms_topN]
proposals = proposals[order, :]
scores = scores[order]
```

***6. apply nms (e.g. threshold = 0.7)***

非极大值抑制：

```python
# 6. apply nms (e.g. threshold = 0.7)
# 7. take after_nms_topN (e.g. 300)
# 8. return the top proposals (-> RoIs top)
keep = nms(np.hstack((proposals, scores)), nms_thresh)
if post_nms_topN > 0:
    keep = keep[:post_nms_topN]
proposals = proposals[keep, :]
scores = scores[keep]
```

***Output***

```python
# Our RPN implementation only supports a single input image, so all
# batch inds are 0
batch_inds = np.zeros((proposals.shape[0], 1), dtype=np.float32)
blob = np.hstack((batch_inds, proposals.astype(np.float32, copy=False)))
top[0].reshape(*(blob.shape))
top[0].data[...] = blob
```



------


完整源码：`lib/rpn/proposal_layer.py`


```python
# --------------------------------------------------------
# Faster R-CNN
# Copyright (c) 2015 Microsoft
# Licensed under The MIT License [see LICENSE for details]
# Written by Ross Girshick and Sean Bell
# --------------------------------------------------------

import caffe
import numpy as np
import yaml
from fast_rcnn.config import cfg
from generate_anchors import generate_anchors
from fast_rcnn.bbox_transform import bbox_transform_inv, clip_boxes
from fast_rcnn.nms_wrapper import nms

DEBUG = False

class ProposalLayer(caffe.Layer):
    """
    Outputs object detection proposals by applying estimated bounding-box
    transformations to a set of regular boxes (called "anchors").
    """

    def setup(self, bottom, top):
        # parse the layer parameter string, which must be valid YAML
        # layer_params = yaml.load(self.param_str_)
        layer_params = yaml.load(self.param_str)

        self._feat_stride = layer_params['feat_stride']
        anchor_scales = layer_params.get('scales', (8, 16, 32))
        anchor_ratios = layer_params.get('ratios', (0.5, 1, 2))
        self._anchors = generate_anchors(scales=np.array(anchor_scales), ratios=np.array(anchor_ratios))
        self._num_anchors = self._anchors.shape[0]

        if DEBUG:
            print 'feat_stride: {}'.format(self._feat_stride)
            print 'anchors:'
            print self._anchors

        # rois blob: holds R regions of interest, each is a 5-tuple
        # (n, x1, y1, x2, y2) specifying an image batch index n and a
        # rectangle (x1, y1, x2, y2)
        top[0].reshape(1, 5)

        # scores blob: holds scores for R regions of interest
        if len(top) > 1:
            top[1].reshape(1, 1, 1, 1)

    def forward(self, bottom, top):
        # Algorithm:
        #
        # for each (H, W) location i
        #   generate A anchor boxes centered on cell i
        #   apply predicted bbox deltas at cell i to each of the A anchors
        # clip predicted boxes to image
        # remove predicted boxes with either height or width < threshold
        # sort all (proposal, score) pairs by score from highest to lowest
        # take top pre_nms_topN proposals before NMS
        # apply NMS with threshold 0.7 to remaining proposals
        # take after_nms_topN proposals after NMS
        # return the top proposals (-> RoIs top, scores top)

        assert bottom[0].data.shape[0] == 1, \
            'Only single item batches are supported'

        # cfg_key = str(self.phase) # either 'TRAIN' or 'TEST'
        cfg_key = 'TEST' if self.phase == 1 else 'TRAIN'
        pre_nms_topN  = cfg[cfg_key].RPN_PRE_NMS_TOP_N
        post_nms_topN = cfg[cfg_key].RPN_POST_NMS_TOP_N
        nms_thresh    = cfg[cfg_key].RPN_NMS_THRESH
        min_size      = cfg[cfg_key].RPN_MIN_SIZE

        # the first set of _num_anchors channels are bg probs
        # the second set are the fg probs, which we want
        scores = bottom[0].data[:, self._num_anchors:, :, :]
        bbox_deltas = bottom[1].data
        im_info = bottom[2].data[0, :]

        if DEBUG:
            print 'im_size: ({}, {})'.format(im_info[0], im_info[1])
            print 'scale: {}'.format(im_info[2])

        # 1. Generate proposals from bbox deltas and shifted anchors
        height, width = scores.shape[-2:]

        if DEBUG:
            print 'score map size: {}'.format(scores.shape)

        # Enumerate all shifts
        shift_x = np.arange(0, width) * self._feat_stride
        shift_y = np.arange(0, height) * self._feat_stride
        shift_x, shift_y = np.meshgrid(shift_x, shift_y)
        shifts = np.vstack((shift_x.ravel(), shift_y.ravel(),
                            shift_x.ravel(), shift_y.ravel())).transpose()

        # Enumerate all shifted anchors:
        #
        # add A anchors (1, A, 4) to
        # cell K shifts (K, 1, 4) to get
        # shift anchors (K, A, 4)
        # reshape to (K*A, 4) shifted anchors
        A = self._num_anchors
        K = shifts.shape[0]
        anchors = self._anchors.reshape((1, A, 4)) + \
                  shifts.reshape((1, K, 4)).transpose((1, 0, 2))
        anchors = anchors.reshape((K * A, 4))

        # Transpose and reshape predicted bbox transformations to get them
        # into the same order as the anchors:
        #
        # bbox deltas will be (1, 4 * A, H, W) format
        # transpose to (1, H, W, 4 * A)
        # reshape to (1 * H * W * A, 4) where rows are ordered by (h, w, a)
        # in slowest to fastest order
        print(bbox_deltas)
        bbox_deltas = bbox_deltas.transpose((0, 2, 3, 1)).reshape((-1, 4))

        # Same story for the scores:
        #
        # scores are (1, A, H, W) format
        # transpose to (1, H, W, A)
        # reshape to (1 * H * W * A, 1) where rows are ordered by (h, w, a)
        scores = scores.transpose((0, 2, 3, 1)).reshape((-1, 1))

        # Convert anchors into proposals via bbox transformations
        proposals = bbox_transform_inv(anchors, bbox_deltas)

        # 2. clip predicted boxes to image
        proposals = clip_boxes(proposals, im_info[:2])

        # 3. remove predicted boxes with either height or width < threshold
        # (NOTE: convert min_size to input image scale stored in im_info[2])
        keep = _filter_boxes(proposals, min_size * im_info[2])
        proposals = proposals[keep, :]
        scores = scores[keep]

        # 4. sort all (proposal, score) pairs by score from highest to lowest
        # 5. take top pre_nms_topN (e.g. 6000)
        order = scores.ravel().argsort()[::-1]
        if pre_nms_topN > 0:
            order = order[:pre_nms_topN]
        proposals = proposals[order, :]
        scores = scores[order]

        # 6. apply nms (e.g. threshold = 0.7)
        # 7. take after_nms_topN (e.g. 300)
        # 8. return the top proposals (-> RoIs top)
        keep = nms(np.hstack((proposals, scores)), nms_thresh)
        if post_nms_topN > 0:
            keep = keep[:post_nms_topN]
        proposals = proposals[keep, :]
        scores = scores[keep]

        # Output rois blob
        # Our RPN implementation only supports a single input image, so all
        # batch inds are 0
        batch_inds = np.zeros((proposals.shape[0], 1), dtype=np.float32)
        blob = np.hstack((batch_inds, proposals.astype(np.float32, copy=False)))
        top[0].reshape(*(blob.shape))
        top[0].data[...] = blob

        # [Optional] output scores blob
        if len(top) > 1:
            top[1].reshape(*(scores.shape))
            top[1].data[...] = scores

    def backward(self, top, propagate_down, bottom):
        """This layer does not propagate gradients."""
        pass

    def reshape(self, bottom, top):
        """Reshaping happens during the call to forward."""
        pass

def _filter_boxes(boxes, min_size):
    """Remove all boxes with any side smaller than min_size."""
    ws = boxes[:, 2] - boxes[:, 0] + 1
    hs = boxes[:, 3] - boxes[:, 1] + 1
    keep = np.where((ws >= min_size) & (hs >= min_size))[0]
    return keep
```
