## [【hihocoder】1081 : 最短路径·一](https://hihocoder.com/problemset/problem/1081)

时间限制:10000ms

单点时限:1000ms

内存限制:256MB

### 输入

每个测试点（输入文件）有且仅有一组测试数据。

在一组测试数据中：

第1行为4个整数N、M、S、T，分别表示鬼屋中地点的个数和道路的条数，入口（也是一个地点）的编号，出口（同样也是一个地点）的编号。

接下来的M行，每行描述一条道路：其中的第i行为三个整数u_i, v_i, length_i，表明在编号为u_i的地点和编号为v_i的地点之间有一条长度为length_i的道路。

对于100%的数据，满足N<=10^3，M<=10^4, 1 <= length_i <= 10^3, 1 <= S, T <= N, 且S不等于T。

对于100%的数据，满足小Hi和小Ho总是有办法从入口通过地图上标注出来的道路到达出口。

### 输出

对于每组测试数据，输出一个整数Ans，表示那么小Hi和小Ho为了走出鬼屋至少要走的路程。

#### 样例输入

```
5 23 5 4
1 2 708
2 3 112
3 4 721
4 5 339
5 4 960
1 5 849
2 5 98
1 4 99
2 4 25
2 1 200
3 1 146
3 2 106
1 4 860
4 1 795
5 4 479
5 4 280
3 4 341
1 4 622
4 2 362
2 3 415
4 1 904
2 1 716
2 5 575
```

#### 样例输出

```
123
```

```c
#include <iostream>
#include <vector>
#include <algorithm>
#include <climits>
using namespace std;
vector<int> dis;
vector<bool> vis;

void Dijkstra (vector<vector<int>> G, int start) {
    fill(dis.begin(), dis.end(), INT_MAX);
    fill(vis.begin(), vis.end(), false);
    dis[start] = 0;
    for (int i = 0; i < dis.size(); i++) {
        int u = -1, _min = INT_MAX;
        for (int j = 1; j < dis.size(); j++) {
            if (!vis[j] && dis[j] < _min) {
                u = j;
                _min = dis[j];
            }
        }
        if (u == -1) return;
        vis[u] = true;
        for (int v = 1; v < G[u].size(); v++) {
            if (G[u][v] < INT_MAX && dis[v] > dis[u] + G[u][v])
                dis[v] = dis[u] + G[u][v];
        }
    }
}

int main(int argc, const char * argv[]) {

    int n, m, s, t;
    int u, v, len;
    cin >> n >> m >> s >> t;
    vector<vector<int>> G(n + 1, vector<int>(n + 1, INT_MAX));
    for (int i = 0; i < m; i++) {
        cin >> u >> v >> len;
        G[u][v] = min(G[u][v], len);
        G[v][u] = G[u][v];
    }
    dis.resize(n + 1);
    vis.resize(n + 1);
    Dijkstra(G, s);
    cout << dis[t] << endl;
    return 0;
}
```