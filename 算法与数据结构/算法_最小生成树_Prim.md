# 最小生成树 —— Prim算法

## Prim 算法

> Prim 算法解决的是最小生成树问题，即在一个给定的无向图 G(V, E) 中求一棵生成树 T ，使得这棵树拥有图 G 中的所有顶点，且所有边都是来自图 G 中的边，并且满足整棵树的边权之和最小

> Prim 算法的思想与最短路径中 Dijkstra 算法的思想几乎完全相同，只是在涉及最短距离时使用了集合 S 代替 Dijkstra 算法中的起点 s


伪代码：

```
// G 为图；数组 d 为顶点与集合 S 的最短距离
Prim (G, d[]) {
    初始化;
    for (循环 n 次) {
        u = 使 d[u] 最小的还未被访问的顶点的标号;
        记 u 已被访问;
        for (从 u 出发能到达的所有顶点 v) {
            if (v 未被访问 && 以 u 为中介点使得 v 与集合 S 的最短距离 d[v] 更优) {
                将 G[u][v] 赋值给 v 与集合 S 的最短距离 d[v];
            }
        }
    }
}
```


代码实现：

```c
struct {
    int adjvex;
    int lowcost;
} closedge[MAX_VERTEX_NUM];

void MiniSpanTree_PRIM(Graph G, int u) {
    // 用 Prim 算法从第 u 个顶点出发构造网 G 的最小生成树 T，输出 T 的各条边
    // 记录从顶点集 U 到 V - U 的代价最小的边的辅助数组定义
    int k = locateVex(G, u);
    for (int j = 0; j < G.vexnum; ++j) { // 辅助数组初始化
        if (j != k)
            closedge[j] = { u, G.arcs[k][j].adj };
    }
    closedge[k].lowcost = 0; // 初始 U = {u}
    for (int i = 1; i < G.vexnum; ++i) { // 从其余 G.vexnum - 1 个顶点中选择
        k = minimum(closedge);
        printf(closedge[k].adjvex, G.vexs[k]);
        closedge[k].lowcost = 0;
        for (int j = 0; j < G.vexnum; ++j) {
            if (arcs[k][j].adj < closedge[j].lowcost)
                closedge[j] = { G.vexs[k], G.arcs[k][j].adj }
        }

    }
}
```


邻接矩阵版：

```c
#include <cstdio>
#include <algorithm>
#include <limits.h>
using namespace std;
const int MAXV = 1000;

int n, G[MAXV][MAXV];
int d[MAXV];
int vis[MAXV] = { false };

int Prim () {

    fill(vis, vis + MAXV, false);
    fill(d, d + MAXV, INT_MAX);
    d[0] = 0;
    int ans = 0;
    for (int i = 0; i < n; i++) {
        int u = -1, min = INT_MAX;
        for (int j = 0; j < n; j++) {
            if (vis[j] == false && d[j] < min) {
                u = j;
                min = d[j];
            }
        }
        if (u == -1) return -1; // 找不到小于 INT_MAX 的 d[u]，则剩下的顶点和集合 S 不连通
        vis[u] = true;
        ans += d[u];
        for (int v = 0; v < n; v++) {
            if (vis[v] == false && G[u][v] != INT_MAX && G[u][v] < d[v]) {
                d[v] = G[u][v];
            }
        }
    }

    return ans;

}
```


邻接表版：

```c
#include <cstdio>
#include <algorithm>
#include <vector>
#include <limits.h>
using namespace std;
const int MAXV = 1000;

struct Node {
    int v, dis;
};

vector<Node> Adj[MAXV];
int n;
int d[MAXV];
int vis[MAXV] = { false };

int Prim () {

    fill(vis, vis + MAXV, false);
    fill(d, d + MAXV, INT_MAX);
    d[0] = 0;
    int ans = 0;
    for (int i = 0; i < n; i++) {
        int u = -1, min = INT_MAX;
        for (int j = 0; j < n; j++) {
            if (vis[j] == false && d[j] < min) {
                u = j;
                min = d[j];
            }
        }
        if (u == -1) return -1; // 找不到小于 INT_MAX 的 d[u]，则剩下的顶点和集合 S 不连通
        vis[u] = true;
        ans += d[u];
        for (int j = 0; j < Adj[u].size(); j++) {
            int v = Adj[u][j].v;
            if (vis[v] == false && Adj[u][v].dis < d[v]) {
                d[v] = Adj[u][v].dis;
            }
        }
    }

    return ans;

}
```