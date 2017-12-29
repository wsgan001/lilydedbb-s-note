## pythonic `NetSpec` interface

可以使用 `caffe.NetSpec()` 在 python 中定义 caffe 网络，并生成 prototxt

**Note: If you use a net with a "Python" layer, Make sure the python module implementing your layer is in `$PYTHONPATH` so that when caffe imports it - it can be found. For instance, if your module `my_python_layer.py` is in `/path/to/my_python_layer.py` then `$PYTHONPATH` should be**

```
PYTHONPATH=/path/to:$PYTHONPATH
```

参考：[What is a `“Python”` layer in caffe?](https://stackoverflow.com/questions/41344168/what-is-a-python-layer-in-caffe/41481539#41481539)

如：(下面代码实现 `py-faster-rcnn` 中的 `py-faster-rcnn/models/pascal_voc/VGG16/faster_rcnn_end2end/train.prototxt` )

```python
import caffe
import _init_paths
from caffe import layers as L, params as P
from roi_data_layer.layer import RoIDataLayer

weight_param = dict(lr_mult=1)
bias_param = dict(lr_mult=2)
learned_param = [weight_param, bias_param]
frozen_param = [dict(lr_mult=0, decay_mult=0)] * 2
gaussian_filler = dict(type='gaussian', std=0.01)
constant_filler = dict(type='constant', value=0)
MAX = 0

def conv_relu(bottom, ks, nout, stride=1, pad=1, group=1,
              param=learned_param):
    conv = L.Convolution(bottom, kernel_size=ks, stride=stride,
                         num_output=nout, pad=pad, group=group,
                         param=param)
    return conv, L.ReLU(conv, in_place=True)

def fc_relu_drop(bottom, nout, param=learned_param, dropout_ratio=0.5):
    fc = L.InnerProduct(bottom, num_output=nout, param=param)
    return fc, L.ReLU(fc, in_place=True), L.Dropout(fc, dropout_param=dict(dropout_ratio=dropout_ratio), in_place=True)

net = caffe.NetSpec()
# net.name = "VGG_ILSVRC_16_layers"

net.data, net.im_info, net.gt_boxes = L.RoIDataLayer(name='input-data', ntop=3,
               python_param=dict(module='roi_data_layer.layer', layer='RoIDataLayer', param_str="'num_classes': 21"))

net.conv1_1, net.relu1_1 = conv_relu(net.data, 3, 64, param=frozen_param)
net.conv1_2, net.relu1_2 = conv_relu(net.conv1_1, 3, 64, param=frozen_param)
net.pool1 = L.Pooling(net.conv1_2, name='pool1', ntop=1, pooling_param=dict(pool=P.Pooling.MAX, kernel_size=2, stride=2))

net.conv2_1, net.relu2_1 = conv_relu(net.pool1, 3, 128, param=frozen_param)
net.conv2_2, net.relu2_2 = conv_relu(net.conv2_1, 3, 128, param=frozen_param)
net.pool2 = L.Pooling(net.conv2_2, name='pool2', ntop=1, pooling_param=dict(pool=MAX, kernel_size=2, stride=2))

net.conv3_1, net.relu3_1 = conv_relu(net.pool2, 3, 256, param=learned_param)
net.conv3_2, net.relu3_2 = conv_relu(net.conv3_1, 3, 256, param=learned_param)
net.conv3_3, net.relu3_3 = conv_relu(net.conv3_2, 3, 256, param=learned_param)
net.pool3 = L.Pooling(net.conv3_3, name='pool3', ntop=1, pooling_param=dict(pool=MAX, kernel_size=2, stride=2))

net.conv4_1, net.relu4_1 = conv_relu(net.pool3, 3, 512, param=learned_param)
net.conv4_2, net.relu4_2 = conv_relu(net.conv4_1, 3, 512, param=learned_param)
net.conv4_3, net.relu4_3 = conv_relu(net.conv4_2, 3, 512, param=learned_param)
net.pool4 = L.Pooling(net.conv4_3, name='pool4', ntop=1, pooling_param=dict(pool=MAX, kernel_size=2, stride=2))

net.conv5_1, net.relu5_1 = conv_relu(net.pool4, 3, 512, param=learned_param)
net.conv5_2, net.relu5_2 = conv_relu(net.conv5_1, 3, 512, param=learned_param)
net.conv5_3, net.relu5_3 = conv_relu(net.conv5_2, 3, 512, param=learned_param)

# ==== RPN ====
net["rpn/output"] = L.Convolution(net.conv5_3, name='rpn_conv/3x3', kernel_size=3, num_output=512, param=learned_param, stride=1, pad=1, ntop=1,
                                                      weight_filler=gaussian_filler, bias_filler=constant_filler)
net["rpn/output_relu"] = L.ReLU(net["rpn/output"], name='rpn_relu/3x3', in_place=True)
net.rpn_cls_score = L.Convolution(net['rpn/output'], name='rpn_cls_score', ntop=1,
                                    param=learned_param,
                                    convolution_param=dict(num_output=18, kernel_size=1, pad=0, stride=1),
                                    weight_filler=gaussian_filler,
                                    bias_filler=constant_filler)
net.rpn_bbox_pred = L.Convolution(net['rpn/output'], name='rpn_bbox_pred', ntop=1,
                                    param=learned_param,
                                    convolution_param=dict(num_output=36, kernel_size=1, pad=0, stride=1),
                                    weight_filler=gaussian_filler,
                                    bias_filler=constant_filler)
net.rpn_cls_score_reshape = L.Reshape(net.rpn_cls_score, name='rpn_cls_score_reshape', ntop=1,
                                        reshape_param=dict(shape=dict(dim=[0, 2, -1, 0])))
net.rpn_labels, net.rpn_bbox_targets, net.rpn_bbox_inside_weights, net.rpn_bbox_outside_weights = \
                    L.Python(net.rpn_cls_score, net.gt_boxes, net.im_info, net.data,
                            name='rpn-data', ntop=4,
                            python_param=dict(module='rpn.anchor_target_layer', layer='AnchorTargetLayer', param_str="'feat_stride': 16"))
net.rpn_loss_cls = L.SoftmaxWithLoss(net.rpn_cls_score_reshape, net.rpn_labels,
                                    propagate_down=[1, 0], loss_weight=1,
                                    loss_param=dict(ignore_label=-1, normalize=True))
net.rpn_loss_bbox = L.SmoothL1Loss(net.rpn_bbox_pred, net.rpn_bbox_targets, net.rpn_bbox_inside_weights, net.rpn_bbox_outside_weights,
                                  name='rpn_loss_bbox', loss_weight=1
#                                   , smooth_l1_loss_param=dict(sigma=3.0)
                                  )

# ========= RoI Proposal ============
net.rpn_cls_prob = L.Softmax(net.rpn_cls_score_reshape)
net.rpn_cls_prob_reshape = L.Reshape(net.rpn_cls_prob, reshape_param=dict(shape=dict(dim=[0, 18, -1, 0])))
net.rpn_rois = L.Python(net.rpn_cls_prob_reshape, net.rpn_bbox_pred, net.im_info, name='proposal',
                        python_param=dict(module='rpn.proposal_layer', layer='ProposalLayer', param_str="'feat_stride': 16"))
net.rois, net.labels, net.bbox_targets, net.bbox_inside_weights, net.bbox_outside_weights = \
                        L.Python(net.rpn_rois, net.gt_boxes, ntop=5, name='roi-data',
                                python_param=dict(module='rpn.proposal_target_layer', layer='ProposalTargetLayer', param_str="'num_classes': 21"))

# # ========= RCNN ============
net.roi_pool5 = L.ROIPooling(net.conv5_3, net.rois
#                          , roi_pooling_param=dict(pooled_w=7, pooled_h=7, spatial_scale=0.0625)
                        )
net.fc6, net.relu6, net.drop6 = fc_relu_drop(net.roi_pool5, nout=4096, param=learned_param)
net.fc7, net.relu7, net.drop7 = fc_relu_drop(net.fc6, nout=4096, param=learned_param)
net.cls_score = L.InnerProduct(net.fc7, num_output=21, param=learned_param,
                               weight_filler=gaussian_filler, bias_filler=constant_filler)
net.bbox_pred = L.InnerProduct(net.fc7, num_output=84, param=learned_param,
                               weight_filler=gaussian_filler, bias_filler=constant_filler)
net.loss_cls = L.SoftmaxWithLoss(net.cls_score, net.labels, propagate_down=[1, 0], loss_weight=1)
net.loss_bbox = L.SmoothL1Loss(net.bbox_pred, net.bbox_targets, net.bbox_inside_weights, net.bbox_outside_weights, loss_weight=1)

print(net.to_proto())
```
