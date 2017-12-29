# Faster R-CNN 源码

- `anchor_target_layer.py`

官方对该 layer 的解释：

> Generates training targets/labels for each anchor. Classification labels are 1 (object), 0 (not object) or -1 (ignore). Bbox regression targets are specified when the classification label is > 0.

由于 caffe 版本的问题，需将下面的代码作如下修改，否则会报错：

```python
# layer_params = yaml.load(self.param_str_)
layer_params = yaml.load(self.param_str)
```

如想在 prototxt 中自定义 anchor 的 scales 和 ratios ：

```python
anchor_scales = layer_params.get('scales', (8, 16, 32))
anchor_ratios = layer_params.get('ratios', (0.5, 1, 2))
self._anchors = generate_anchors(scales=np.array(anchor_scales), ratios=np.array(anchor_ratios))
```

在 prototxt 中如下定义：

```
layer {
  name: 'rpn-data'
  type: 'Python'
  bottom: 'rpn_cls_score'
  bottom: 'gt_boxes'
  bottom: 'im_info'
  bottom: 'data'
  top: 'rpn_labels'
  top: 'rpn_bbox_targets'
  top: 'rpn_bbox_inside_weights'
  top: 'rpn_bbox_outside_weights'
  python_param {
    module: 'rpn.anchor_target_layer'
    layer: 'AnchorTargetLayer'
    param_str: "{ 'feat_stride': 16, 'scales': [0.5, 1, 2, 4, 8, 16, 32], 'ratios': [0.333, 0.667, 1, 1.5, 3] }"
  }
}
```

论文中把 `anchors` 分为 `positive`，`negative` 和 `don't care` 三类：

> We assign a positive label to two kinds of anchors: (i) the anchor/anchors with the highest Intersection-over-Union (IoU) overlap with a ground-truth box, or (ii) an anchor that has an IoU overlap higher than 0.7 with any ground-truth box.
>
> ...
>
> We assign a negative label to a non-positive anchor if its IoU ratio is lower than 0.3 for all ground-truth boxes. Anchors that are neither positive nor negative do not contribute to the training objective.

代码中的体现：

```python
# label: 1 is positive, 0 is negative, -1 is dont care
labels = np.empty((len(inds_inside), ), dtype=np.float32)
labels.fill(-1)

# overlaps between the anchors and the gt boxes
# overlaps (ex, gt)
overlaps = bbox_overlaps(
    np.ascontiguousarray(anchors, dtype=np.float),
    np.ascontiguousarray(gt_boxes, dtype=np.float))
argmax_overlaps = overlaps.argmax(axis=1)
max_overlaps = overlaps[np.arange(len(inds_inside)), argmax_overlaps]
gt_argmax_overlaps = overlaps.argmax(axis=0)
gt_max_overlaps = overlaps[gt_argmax_overlaps,
                           np.arange(overlaps.shape[1])]
gt_argmax_overlaps = np.where(overlaps == gt_max_overlaps)[0]

if not cfg.TRAIN.RPN_CLOBBER_POSITIVES:
    # assign bg labels first so that positive labels can clobber them
    labels[max_overlaps < cfg.TRAIN.RPN_NEGATIVE_OVERLAP] = 0

# fg label: for each gt, anchor with highest overlap
labels[gt_argmax_overlaps] = 1

# fg label: above threshold IOU
labels[max_overlaps >= cfg.TRAIN.RPN_POSITIVE_OVERLAP] = 1

if cfg.TRAIN.RPN_CLOBBER_POSITIVES:
    # assign bg labels last so that negative labels can clobber positives
    labels[max_overlaps < cfg.TRAIN.RPN_NEGATIVE_OVERLAP] = 0
```
