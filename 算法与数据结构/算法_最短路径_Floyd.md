# 最短路径 —— Floyd算法

Floyd算法，是解决任意两点间的最短路径的一种算法，可以正确处理**有向图**或**负权**（但不可存在负权回路)的最短路径问题，同时也被用于计算有向图的传递闭包

时间复杂度为 `O(N^3)`，空间复杂度为 `O(N^2)`

伪代码：

```
for k = 1 .. N
    for i = 1 .. N
        for j = 1 .. N
            若i, j, k各不相同
                MinDistance[i, j] = min{MinDistance[i, j], MinDistance[i, k] + MinDistance[k, j]}
```

代码实现：

```c
// ...
for (int i = 1; i < dis.size(); i++) dis[i][i] = 0;

// ...

void Floyd (vector<vector<int>> &dis) {
    for (int i = 1; i < dis.size(); i++) {
        for (int j = 1; j < dis.size(); j++) {
            for (int k = 1; k < dis.size(); k++) {
                if (i != j && j != k && i != k &&
                    dis[i][k] < INT_MAX && dis[k][j] < INT_MAX)
                    dis[i][j] = min(dis[i][j], dis[i][k] + dis[k][j]);
            }
        }
    }
}
```