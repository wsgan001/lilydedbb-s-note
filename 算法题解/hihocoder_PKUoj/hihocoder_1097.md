## [【hihocoder】1097 : 最小生成树一·Prim算法](https://hihocoder.com/problemset/problem/1097)

时间限制:10000ms

单点时限:1000ms

内存限制:256MB

### 输入

每个测试点（输入文件）有且仅有一组测试数据。

在一组测试数据中：

第1行为1个整数N，表示小Hi拥有的城市数量。

接下来的N行，为一个N*N的矩阵A，描述任意两座城市之间建造道路所需要的费用，其中第i行第j个数为Aij，表示第i座城市和第j座城市之间建造道路所需要的费用。

对于100%的数据，满足N<=10^3，对于任意i，满足Aii=0，对于任意i, j满足Aij=Aji, 0<Aij<10^4.

### 输出

对于每组测试数据，输出1个整数Ans，表示为了使任意两座城市都可以通过所建造的道路互相到达至少需要的建造费用。

#### 样例输入

```
5
0 1005 6963 392 1182
1005 0 1599 4213 1451
6963 1599 0 9780 2789
392 4213 9780 0 5236
1182 1451 2789 5236 0
```

### 样例输出

```
4178
```

```c
#include <iostream>
#include <vector>
#include <algorithm>
#include <climits>
using namespace std;
vector<int> dis;
vector<bool> vis;

int Prim (vector<vector<int>> G) {
    fill(dis.begin(), dis.end(), INT_MAX);
    fill(vis.begin(), vis.end(), false);
    int min_tree = 0;
    dis[1] = 0;
    for (int i = 1; i < G.size(); i++) {
        int u = -1, _min = INT_MAX;
        for (int j = 1; j < G.size(); j++) {
            if (!vis[j] && dis[j] < _min) {
                u = j;
                _min = dis[j];
            }
        }
        if (u == -1) return -1;
        vis[u] = true;
        min_tree += dis[u];
        for (int v = 1; v < G.size(); v++) {
            if (!vis[v] && G[u][v] < dis[v])
                dis[v] = G[u][v];
        }
    }
    return min_tree;
}

int main(int argc, const char * argv[]) {

    int n, edge;
    cin >> n;
    vector<vector<int>> G(n + 1, vector<int>(n + 1, INT_MAX));
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= n; j++) {
            cin >> edge;
            G[i][j] = min(G[i][j], edge);
            G[j][i] = G[i][j];
        }
    }
    dis.resize(n + 1);
    vis.resize(n + 1);
    cout << Prim(G) << endl;
    return 0;
}
```