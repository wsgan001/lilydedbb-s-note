# 最小生成树 —— Krustal算法

> 与 Prim 算法相比，Krustal 算法采用了“边贪心”的策略

> Krustal算法的基本思想就是：每次选择途中最小边权的边，如果边两端的顶点在不同的连通块中，就把这条边加入最小生成树中


伪代码：

```
int Krustal () {
    令最小生成树的边权之和为 ans 、最小生成树的当前边数 Num_Edge;
    将所有边按边权从小到大排序;
    for (从小到大枚举所有边) {
        if (当前测试边的两个端点在不同的连通块中) {
            将该测试边加入最小生成树中;
            ans += 测试边的边权;
            最小生成树的当前边数 Num_Edge 加1;
            当边数 Num_Edge 等于顶点数减 1 时结束循环;
        }
    }
}
```


代码实现：

```c
#include <cstdio>
#include <algorithm>
using namespace std;
const int MAXV = 1000;
const int MAXE = MAXV * (MAXV - 1);

struct Edge {
    int u, v;
    int cost;
} edge[MAXE];

bool cmp (Edge a, Edge b) {
    return a.cost < b.cost;
}

int n, father[MAXE];
int findFather (int x) {
    int a = x;
    while (x != father[x]) {
        x = father[x];
    }
    while (a != father[a]) {
        int z = a;
        a = father[a];
        father[z] = x;
    }
    return x;
}

int Krustal (int n, int m) { // n 为顶点个数，m 为图的边数

    int ans = 0, Num_Edge = 0;
    for (int i = 0; i < n; i++) father[i] = i;
    sort(edge, edge + MAXE, cmp);
    for (int i = 0; i < m; i++) {
        int faU = findFather(edge[i].u);
        int faV = findFather(edge[i].v);
        if (faU != faV) {
            father[faU] = faV;
            ans += edge[i].cost;
            Num_Edge++;
            if (Num_Edge == n - 1) break;
        }
    }
    if (Num_Edge != n - 1) return -1;
    else return ans;

}
```