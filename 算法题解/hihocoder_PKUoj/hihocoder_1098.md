## [【hihocoder】1098 : 最小生成树二·Kruscal算法](https://hihocoder.com/problemset/problem/1098)

时间限制:10000ms

单点时限:1000ms

内存限制:256MB

### 输入

每个测试点（输入文件）有且仅有一组测试数据。

在一组测试数据中：

第1行为2个整数N、M，表示小Hi拥有的城市数量和小Hi筛选出路线的条数。

接下来的M行，每行描述一条路线，其中第i行为3个整数N1_i, N2_i, V_i，分别表示这条路线的两个端点和在这条路线上建造道路的费用。

对于100%的数据，满足N<=10^5, M<=10^6，于任意i满足1<=N1_i, N2_i<=N, N1_i≠N2_i, 1<=V_i<=10^3.

对于100%的数据，满足一定存在一种方案，使得任意两座城市都可以互相到达。

### 输出

对于每组测试数据，输出1个整数Ans，表示为了使任意两座城市都可以通过所建造的道路互相到达至少需要的建造费用。

#### 样例输入

```
5 29
1 2 674
2 3 249
3 4 672
4 5 933
1 2 788
3 4 147
2 4 504
3 4 38
1 3 65
3 5 6
1 5 865
1 3 590
1 4 682
2 4 227
2 4 636
1 4 312
1 3 143
2 5 158
2 3 516
3 5 102
1 5 605
1 4 99
4 5 224
2 4 198
3 5 894
1 5 845
3 4 7
2 4 14
1 4 185
```

#### 样例输出

```
92
```

```c
#include <iostream>
#include <vector>
#include <algorithm>
#include <climits>
using namespace std;
vector<int> father;

int findFather (int x) {
    int root = x;
    while (root != father[root])
        root = father[root];
    while (x != father[x]) {
        int f = father[x];
        father[x] = root;
        x = f;
    }
    return root;
}

void Union (int a, int b) {
    int fa = findFather(a);
    int fb = findFather(b);
    if (fa != fb)
        father[fa] = fb;
}

int Kruscal (vector<vector<int>> G) {
    father.resize(G.size());
    for (int i = 0; i < father.size(); i++) father[i] = i;
    int min_tree = 0;
    while (true) {
        int _min = INT_MAX;
        int u = -1, v = -1;
        for (int i = 1; i < G.size(); i++) {
            for (int j = 1; j < G.size(); j++) {
                if (findFather(i) != findFather(j) &&
                    G[i][j] < INT_MAX && G[i][j] < _min) {
                    _min = G[i][j];
                    u = i; v = j;
                }
            }
        }
        if (u == -1 || v == -1) break;
        Union(u, v);
        min_tree += _min;
    }
    return min_tree;
}

int main(int argc, const char * argv[]) {

    int n, m, u, v, edge;
    cin >> n >> m;
    vector<vector<int>> G(n + 1, vector<int>(n + 1, INT_MAX));
    for (int i = 1; i <= m; i++) {
        cin >> u >> v >> edge;
        G[u][v] = min(G[u][v], edge);
        G[v][u] = G[u][v];
    }
    cout << Kruscal(G) << endl;
    return 0;
}
```