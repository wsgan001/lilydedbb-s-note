# Fully Convolutional Instance-aware Semantic Segmentation


The drawbacks of FCNs:

Convolution is translation invariant, so the same image pixel receives the same responses irrespective to its relative position in the context. So FCNs do not work for the instance-aware semantic segmentation task, which requires the detection and segmentation of individual object instances.

However, instance-aware semantic segmentation needs to operate on region level, and the same pixel can have different semantics in different re- gions. This behavior cannot be modeled by a single FCN on the whole image.


