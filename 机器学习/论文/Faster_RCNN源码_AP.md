# Faster R-CNN 源码 —— AP

计算某一 class 的 AP：

1. 加载 `gt_boxes`:

    这里如果有之前存储的 cache 文件，就直接从 cache 文件中读取，如果没有 cache 文件，则从 `annotations` 文件里读取 `gt_box`，构造一个 `imagename -> gt_box` 的字典 `recs`，并且写入 cache 文件

    ```python
    recs[imagename] = parse_rec(annopath.format(imagename))
    ```

    ```python
    # first load gt
    if not os.path.isdir(cachedir):
        os.mkdir(cachedir)
    cachefile = os.path.join(cachedir, 'annots.pkl')
    # read list of images
    with open(imagesetfile, 'r') as f:
        lines = f.readlines()
    imagenames = [x.strip() for x in lines]

    if not os.path.isfile(cachefile):
        # load annots
        recs = {}
        for i, imagename in enumerate(imagenames):
            recs[imagename] = parse_rec(annopath.format(imagename))
            if i % 100 == 0:
                print 'Reading annotation for {:d}/{:d}'.format(
                    i + 1, len(imagenames))
        # save
        print 'Saving cached annotations to {:s}'.format(cachefile)
        with open(cachefile, 'w') as f:
            cPickle.dump(recs, f)
    else:
        # load
        with open(cachefile, 'r') as f:
            recs = cPickle.load(f)
    ```

    `parse_rec` 接收 annatation 文件的 filename， 函数返回这样一个结构：

    ```
    [
        {
            'name': name,
            'pase': pose,
            'truncated': truncated,
            'difficult': difficult,
            'bbox': [xmin, ymin, xmax, ymax]
        },
        ...
    ]
    ```

2. 对于 `recs` 的每一个条目，筛选出当前 `class` 的 `gt_box`，构造新字典 `class_recs`

    ```python
    # extract gt objects for this class
    class_recs = {}
    npos = 0
    for imagename in imagenames:
        R = [obj for obj in recs[imagename] if obj['name'] == classname]
        bbox = np.array([x['bbox'] for x in R])
        difficult = np.array([x['difficult'] for x in R]).astype(np.bool)
        det = [False] * len(R)
        npos = npos + sum(~difficult)
        class_recs[imagename] = {'bbox': bbox,
                                 'difficult': difficult,
                                 'det': det}
    ```

    这里 `npos` 为这一 class 的所有 label 中 not difficult 的总数

3. 读取 dets （包含该 class 在测试集中所有的 detection 结果）

    ```python
    # read dets
    detfile = detpath.format(classname)
    with open(detfile, 'r') as f:
        lines = f.readlines()

    splitlines = [x.strip().split(' ') for x in lines]
    image_ids = [x[0] for x in splitlines]
    confidence = np.array([float(x[1]) for x in splitlines])
    BB = np.array([[float(z) for z in x[2:]] for x in splitlines])
    ```

4. 将所有的 dets 按照 confidence 从大到小排序

    ```python
    # sort by confidence
    sorted_ind = np.argsort(-confidence)
    sorted_scores = np.sort(-confidence)
    BB = BB[sorted_ind, :]
    image_ids = [image_ids[x] for x in sorted_ind]
    ```

5. 遍历排序后的 `dets`：

    对于每一个 `det`，从 `class_recs` 找到该 `det` 所属图片中所有同属于该 `class` 的 `gt_box`，计算该 `det` 与所有这样的 `gt_box` 的 `IOU`，若所有 `IOU` 中的最大值比设定阈值大，且 not difficult 并且没有重复重复计算则 `tp += 1`，否则 `fp += 1`

    ```python
    # go down dets and mark TPs and FPs
    nd = len(image_ids)
    tp = np.zeros(nd)
    fp = np.zeros(nd)
    for d in range(nd):
        R = class_recs[image_ids[d]]
        bb = BB[d, :].astype(float)
        ovmax = -np.inf
        BBGT = R['bbox'].astype(float)

        if BBGT.size > 0:
            # compute overlaps
            # intersection
            ixmin = np.maximum(BBGT[:, 0], bb[0])
            iymin = np.maximum(BBGT[:, 1], bb[1])
            ixmax = np.minimum(BBGT[:, 2], bb[2])
            iymax = np.minimum(BBGT[:, 3], bb[3])
            iw = np.maximum(ixmax - ixmin + 1., 0.)
            ih = np.maximum(iymax - iymin + 1., 0.)
            inters = iw * ih

            # union
            uni = ((bb[2] - bb[0] + 1.) * (bb[3] - bb[1] + 1.) +
                   (BBGT[:, 2] - BBGT[:, 0] + 1.) *
                   (BBGT[:, 3] - BBGT[:, 1] + 1.) - inters)

            overlaps = inters / uni
            ovmax = np.max(overlaps)
            jmax = np.argmax(overlaps)

        if ovmax > ovthresh:
            if not R['difficult'][jmax]:
                if not R['det'][jmax]:
                    tp[d] = 1.
                    R['det'][jmax] = 1
                else:
                    fp[d] = 1.
        else:
            fp[d] = 1.
    ```

6. 计算 precise recall 和 AP：

    ```python
        # compute precision recall
        fp = np.cumsum(fp)
        tp = np.cumsum(tp)
        rec = tp / float(npos)
        # avoid divide by zero in case the first detection matches a difficult
        # ground truth
        prec = tp / np.maximum(tp + fp, np.finfo(np.float64).eps)
        ap = voc_ap(rec, prec, use_07_metric)

        return rec, prec, ap
    ```
