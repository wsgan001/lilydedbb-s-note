# 最短路径 —— Dijkstra算法

> Dijkstra算法 解决的单源最短路径问题，即给定图 `G(V, E)` 和起点 `s` ，求从起点 `s` 到达其他顶点的最短距离

1. 集合 `S` 可以用一个 `bool` 型数组 `vis[]` 来实现，即当 `vis[i] == true` 时表示顶点 `Vi` 已被访问，当 `vis[i] == false` 时表示顶点 `Vi` 未被访问
2. 令 `int` 型数组 `d[]` 表示起点 `s` 到达顶点 `Vi` 的最短距离，起始时除了起点 `s` 的 `d[s]` 赋为 `0`，其余顶点都赋为 `MAX_INT`


伪代码：

```
Dijkstra (G, d[], s) {
    初始化;
    for (循环 n 次) {
        u = 使 d[u] 最小的还未被访问的顶点的标号;
        记 u 已被访问;
        for (从 u 出发能到达的所有顶点 v) {
            if (v 从未被访问 && 以 u 为中介点使 s 到顶点 v 的最短距离 d[v] 更优) {
                优化 d[v];
            }
        }
    }
}
```


代码实现：

```c
#include <cstdio>
#include <limits>
using namespace std;
const int MAXV = 1000;
bool final[MAXV] = { false };
int D[MAXV];
bool P[MAXV][MAXV];

void Dijkstra (Graph G, int u0, bool &P[][], int &D[]) {

    // Dijkstra 算法求有向图 G 的 u0 顶点到其余顶点 v 的最短路径 P[v] 及其带权长度 D[v]
    // 若 P[v][w] 为 true ，则 w 是从 u0 到 v 当前求的最短路径上的顶点
    // final[v] 为 true 当且仅当 v 属于 S，即已经求得从 u0 到 v 的最短路径
    for (int i = 0; i < G.vexnum; i++) {
        final[i] = false;
        D[i] = G.arcs[u0][i];
        for (int j = 0; j < G.vexnum; j++) P[i][j] = false; // 初始化空路径
        if (D[i] < INT_MAX) {
            P[i][u0] = true;
            P[i][i] = true;
        }
    }
    D[u0] = 0;
    final[u0] = true;
    for (int i = 1; i < G.vexnum; i++) {
        int u = -1, min = INT_MAX;
        for (int j = 0; j < G.vexnum; j++) {
            if (!final[j] && D[j] < min) {
                u = j;
                min = D[j];
            }
        }
        if (u == -1) return;
        final[u] = true;
        for (int v = 0; v < G.vexnum; v++) {
            if (!final[v] && min + G.arcs[u][v] < D[v]) {
                D[v] = min + G.arcs[u][v];
                P[v] = P[u];
                P[v][v] = true;
            }
        }
    }

}
```


邻接矩阵版：

```c
#include <cstdio>
#include <iostream>
#include <limits>
using namespace std;
const int MAXV = 1000;

int n, G[MAXV][MAXV]; // n 为顶点数，MAXV 为最大顶点数
int d[MAXV]; // 起点到达各顶点的最短路径长度
bool vis[MAXV] = { false }; // true 为已被访问，false 为未被访问

void Dijkstra (int s) { // s 为起点

    fill(vis, vis + MAXV, false);
    fill(d, d + MAXV, INT_MAX);
    d[s] = 0;
    for (int i = 0; i < n; i++) {
        int u = -1, min = INT_MAX;
        for (int j = 0; j < n; j++) {
            if (vis[j] == false && d[j] < min) {
                u = j;
                min = d[j];
            }
        }
        if (u == -1) return; // 如果 u == -1 ，说明剩下的顶点中没有和已经被访问的顶点集合连通的
        vis[u] = true;
        for (int v = 0; v < n; v++) {
            // 如果 v 还未被访问 && u 和 v 连通 && 以 u 为中介点可以使 d[v] 更优
            if (vis[v] == false && G[u][v] != INT_MAX && && d[u] + G[u][v] < d[v]) {
                d[v] = d[u] + G[u][v];
            }
        }
    }

}
```


邻接表版：

```c
#include <cstdio>
#include <iostream>
#include <vector>
#include <limits>
using namespace std;
const int MAXV = 1000;

struct Node {
    int v, dis; // v 为边的目标顶点，dis 为边权
};
int n; // n 为顶点数
vector<Node> Adj[MAXV]; // Adj[u] 存放 从顶点 u 能到达的所有顶点
int d[MAXV]; // 起点到达各顶点的最短路径长度
bool vis[MAXV] = { false }; // true 为已被访问，false 为未被访问

void Dijkstra (int s) { // s 为起点

    fill(vis, vis + MAXV, false);
    fill(d, d + MAXV, INT_MAX);
    d[s] = 0;
    for (int i = 0; i < n; i++) {
        int u = -1, min = INT_MAX;
        for (int j = 0; j < n; j++) {
            if (vis[j] == false && d[j] < min) {
                u = j;
                min = d[j];
            }
        }
        if (u == -1) return;
        vis[u] = false;
        for (int j = 0; j < Adj[u].size(); j++) {
            int v = Adj[u][j].v;
            if (vis[v] == false && d[u] + Adj[u][j].dis < d[v]) {
                d[v] = d[u] + Adj[u][j].dis;
            }
        }
    }

}
```