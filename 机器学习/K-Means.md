# K-means

> k-平均聚类 (K-means) 的目的是：把 n 个点（可以是样本的一次观察或一个实例）划分到 k 个聚类中，使得每个点都属于离他最近的均值（此即聚类中心）对应的聚类，以之作为聚类的标准

```
创建k个点作为初始的质心点（随机选择）
当任意一个点的簇分配结果发生改变时
    对数据集中的每一个数据点
        对每一个质心
            计算质心与数据点的距离
            将数据点分配到距离最近的簇
        对每一个簇，计算簇中所有点的均值，并将均值作为质心
```

伪代码：

```
输入：样本集 D = { x1, x2, ... , xm }
      聚类簇数 k
过程：
从 D 中随机选择 k 个样本作为初始均值向量 { u1, u2, ... , uk };
repeat
    令 Ci = 空集 (1 <= i <= k);
    for j = 1, 2, ... , m do
        计算样本 xj 与各均值向量 ui(1 <= i <= k) 的距离：d_ji = ||xj - ui|| ^ 2  (1 <= i <= k);
        根据距离最近的均值向量确定 xj; 的簇标记： lambda_j = argmin d_ji;
        将样本 xj 划入相应的簇：C_lambda_j = C_lambda_j 和 { xj } 做并集;
    end for

    for j = 1, 2, ... , m do
        计算新均值向量：ui' = [1 / |Ci|] *  sum(x)  (x 属于 Ci);
        if ui' != ui then
            将当前均值向量 ui 更新为 ui';
        else
            保持当前均值向量不变;
        end if
    end for
until 当前均值向量均未更新
输出：簇划分 C = { C1, C2, ... , Ck }
```

Matlab:

Syntax:

```
idx = kmeans(X,k)
idx = kmeans(X,k,Name,Value)
[idx,C] = kmeans(___)
[idx,C,sumd] = kmeans(___)
[idx,C,sumd,D] = kmeans(___)
```

> kmeans(X,k) performs k-means clustering to partition the observations of the n-by-p data matrix X into k clusters

- `C` 为每一个聚类的的中心 (the k cluster centroid locations in the k-by-p matrix C)