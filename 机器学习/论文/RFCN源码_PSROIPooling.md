# R-FCN 源码 —— PSROIPoolingLayer

RFCN 中官方代码中 （以 `/models/rfcn_prototxts/ResNet-101L_res3a/train_val.prototxt` 为例），关于 `PSROIPoolingLayer` 的 `prototxt` 如下：

```
#--------------position sensitive RoI pooling--------------
layer {
    bottom: "rfcn_cls"
    bottom: "rois"
    top: "psroipooled_cls_rois"
    name: "psroipooled_cls_rois"
    type: "PSROIPooling"
    psroi_pooling_param {
        spatial_scale: 0.0625
        output_dim: 21
        group_size: 7
    }
}

layer {
    bottom: "psroipooled_cls_rois"
    top: "cls_score"
    name: "ave_cls_score_rois"
    type: "Pooling"
    pooling_param {
        pool: AVE
        kernel_size: 7
        stride: 7
    }
}


layer {
    bottom: "rfcn_bbox"
    bottom: "rois"
    top: "psroipooled_loc_rois"
    name: "psroipooled_loc_rois"
    type: "PSROIPooling"
    psroi_pooling_param {
        spatial_scale: 0.0625
        output_dim: 8
        group_size: 7
    }
}

layer {
    bottom: "psroipooled_loc_rois"
    top: "bbox_pred"
    name: "ave_bbox_pred_rois"
    type: "Pooling"
    pooling_param {
        pool: AVE
        kernel_size: 7
        stride: 7
    }
}
```

[官方源码](https://github.com/daijifeng001/caffe-rfcn)（只实现了 gpu 版，未实现 cpu 版），这里分析 [`py-RFCN-priv`](https://github.com/soeaver/py-RFCN-priv/blob/520b10e7db0d50853f50b79f35e7b8ddf27972c4/caffe-priv/src/caffe/layers/psroi_pooling_layer.cpp) 的实现版本：

输入为基础网络传过来的 feature maps 和 RPN 生成的 ROIs:

```c
// bottom: "rfcn_cls"
// bottom: "rois"
const Dtype* bottom_data = bottom[0]->cpu_data();
const Dtype* bottom_rois = bottom[1]->cpu_data();
```

之后和 ROIPooling 的步骤差不多，只是在 涉及 bottom index 的时候略有不同（不同的 pw, ph 值，pooling 的 bottom data 的 channel 不同，而 ROIPooling 是针对所有 channel 都进行 pooling）：

```c
int gw = pw;
int gh = ph;
int c = (ctop*group_size + gh)*group_size + gw;
out_sum += bottom_data[(roi_batch_ind * channels + c) * height * width + bottom_index];
```

完整源码：

```c
// ------------------------------------------------------------------
// R-FCN
// Written by Yi Li
// ------------------------------------------------------------------

#include <cfloat>
#include <algorithm>

#include <string>
#include <utility>
#include <vector>

#include "caffe/layers/psroi_pooling_layer.hpp"
#include "caffe/util/math_functions.hpp"

using std::max;
using std::min;
using std::floor;
using std::ceil;

namespace caffe {
  template <typename Dtype>
  void PSROIPoolingLayer<Dtype>::LayerSetUp(const vector<Blob<Dtype>*>& bottom,
    const vector<Blob<Dtype>*>& top) {
    PSROIPoolingParameter psroi_pooling_param =
      this->layer_param_.psroi_pooling_param();
    spatial_scale_ = psroi_pooling_param.spatial_scale();
    LOG(INFO) << "Spatial scale: " << spatial_scale_;

    CHECK_GT(psroi_pooling_param.output_dim(), 0)
      << "output_dim must be > 0";
    CHECK_GT(psroi_pooling_param.group_size(), 0)
      << "group_size must be > 0";

    output_dim_ = psroi_pooling_param.output_dim();
    group_size_ = psroi_pooling_param.group_size();
    pooled_height_ = group_size_;
    pooled_width_ = group_size_;
  }

  template <typename Dtype>
  void PSROIPoolingLayer<Dtype>::Reshape(const vector<Blob<Dtype>*>& bottom,
    const vector<Blob<Dtype>*>& top) {
    channels_ = bottom[0]->channels();
    CHECK_EQ(channels_, output_dim_*group_size_*group_size_)
      << "input channel number does not match layer parameters";
    height_ = bottom[0]->height();
    width_ = bottom[0]->width();
    top[0]->Reshape(
      bottom[1]->num(), output_dim_, pooled_height_, pooled_width_);
    mapping_channel_.Reshape(
      bottom[1]->num(), output_dim_, pooled_height_, pooled_width_);
  }


  template <typename Dtype>
  static void PSROIPoolingForward(
    const int num,
    const Dtype* bottom_data,
    const Dtype spatial_scale,
    const int channels,
    const int height, const int width,
    const int pooled_height, const int pooled_width,
    const Dtype* bottom_rois,
    const int output_dim,
    const int group_size,
    Dtype* top_data,
    int* mapping_channel) {
    for (int n = 0; n < num; ++n) {
      int roi_add = n*5;
      z_size_w = roi_width / static_cast<Dtype>(pooled_width);

      for (int ctop = 0; ctop < output_dim; ++ctop) {
        for (int ph = 0; ph < pooled_height; ++ph) {
          for (int pw = 0; pw < pooled_width; ++pw) {
            int index = n*output_dim*pooled_height*pooled_width + ctop*pooled_height*pooled_width + ph*pooled_width + pw;
            // The output is in order (n, ctop, ph, pw)

            int hstart = floor(static_cast<Dtype>(ph) * bin_size_h
                                + roi_start_h);
            int wstart = floor(static_cast<Dtype>(pw)* bin_size_w
                                + roi_start_w);
            int hend = ceil(static_cast<Dtype>(ph + 1) * bin_size_h
                              + roi_start_h);
            int wend = ceil(static_cast<Dtype>(pw + 1) * bin_size_w
                        + roi_start_w);
            // Add roi offsets and clip to input boundaries
            hstart = min(max(hstart, 0), height);
            hend = min(max(hend, 0), height);
            wstart = min(max(wstart, 0), width);
            wend = min(max(wend, 0), width);
            bool is_empty = (hend <= hstart) || (wend <= wstart);

            int gw = pw;
            int gh = ph;
            int c = (ctop*group_size + gh)*group_size + gw;

            // bottom_data += (roi_batch_ind * channels + c) * height * width;
            Dtype out_sum = 0;
            for (int h = hstart; h < hend; ++h) {
              for (int w = wstart; w < wend; ++w) {
                int bottom_index = h*width + w;
                out_sum += bottom_data[(roi_batch_ind * channels + c) * height * width + bottom_index];
              }
            }

            Dtype bin_area = (hend - hstart)*(wend - wstart);
            if (is_empty) {
              top_data[index] = 0;
            } else {
              top_data[index] = out_sum/bin_area;
            }

            mapping_channel[index] = c;
          }
        }
      }
    }
  }


  template <typename Dtype>
  void PSROIPoolingLayer<Dtype>::Forward_cpu(const vector<Blob<Dtype>*>& bottom,
    const vector<Blob<Dtype>*>& top) {
    const Dtype* bottom_data = bottom[0]->cpu_data();
    const Dtype* bottom_rois = bottom[1]->cpu_data();
    Dtype* top_data = top[0]->mutable_cpu_data();
    int* mapping_channel_ptr = mapping_channel_.mutable_cpu_data();
    int count = top[0]->count();
    caffe_set(count, Dtype(0), top_data);
    caffe_set(count, -1, mapping_channel_ptr);
    // NOLINT_NEXT_LINE(whitespace/operators)
    PSROIPoolingForward(bottom[1]->num(), bottom_data, spatial_scale_,
      channels_, height_, width_, pooled_height_,
      pooled_width_, bottom_rois, output_dim_, group_size_,
      top_data, mapping_channel_ptr);
  }


  template <typename Dtype>
  void PSROIPoolingLayer<Dtype>::Backward_cpu(const vector<Blob<Dtype>*>& top,
    const vector<bool>& propagate_down, const vector<Blob<Dtype>*>& bottom) {
    NOT_IMPLEMENTED;
  }


#ifdef CPU_ONLY
  STUB_GPU(PSROIPoolingLayer);
#endif

  INSTANTIATE_CLASS(PSROIPoolingLayer);
  REGISTER_LAYER_CLASS(PSROIPooling);

}  // namespace caffe
```
