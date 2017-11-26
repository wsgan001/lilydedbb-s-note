## [【hihocoder】1093 : 最短路径·三：SPFA算法](https://hihocoder.com/problemset/problem/1093)

时间限制:10000ms

单点时限:1000ms

内存限制:256MB

### 输入

每个测试点（输入文件）有且仅有一组测试数据。

在一组测试数据中：

第1行为4个整数N、M、S、T，分别表示鬼屋中地点的个数和道路的条数，入口（也是一个地点）的编号，出口（同样也是一个地点）的编号。

接下来的M行，每行描述一条道路：其中的第i行为三个整数u_i, v_i, length_i，表明在编号为u_i的地点和编号为v_i的地点之间有一条长度为length_i的道路。

对于100%的数据，满足N<=10^5，M<=10^6, 1 <= length_i <= 10^3, 1 <= S, T <= N, 且S不等于T。

对于100%的数据，满足小Hi和小Ho总是有办法从入口通过地图上标注出来的道路到达出口。

### 输出

对于每组测试数据，输出一个整数Ans，表示那么小Hi和小Ho为了走出鬼屋至少要走的路程。

#### 样例输入

```
5 10 3 5
1 2 997
2 3 505
3 4 118
4 5 54
3 5 480
3 4 796
5 2 794
2 5 146
5 4 604
2 5 63
```

#### 样例输出

```
172
```

```c
#include <iostream>
#include <vector>
#include <queue>
#include <algorithm>
#include <climits>
using namespace std;
vector<int> dis;
vector<bool> inQueue;

void SPFA (vector<vector<int>> G, int start) {
    fill(dis.begin(), dis.end(), INT_MAX);
    fill(inQueue.begin(), inQueue.end(), false);
    queue<int> q;
    q.push(start);
    dis[start] = 0;
    inQueue[start] = true;
    while (!q.empty()) {
        int front = q.front();
        q.pop();
        inQueue[front] = false;
        for (int i = 0; i < G[front].size(); i++) {
            if (G[front][i] < INT_MAX && dis[front] + G[front][i] < dis[i]) {
                dis[i] = dis[front] + G[front][i];
                if (!inQueue[i]) {
                    q.push(i);
                    inQueue[i] = true;
                }
            }
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
    inQueue.resize(n + 1);
    SPFA(G, s);
    cout << dis[t] << endl;
    return 0;
}
```