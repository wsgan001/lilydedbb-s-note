# AOE (Activity On Edge) 网 —— 关键路径 (Critical Path)

AOE (Activity On Edge) 网:

> 用顶点表示事件，用弧表示活动，权表示活动时间；AOE网通常用来估算工程的完成时间

关键路径:

> 完成工程的最短时间是从开始点到完成点的最长路径的长度，**路径最长的路径叫做关键路径**

- `e(i)` 表示活动（弧） `ai` 的最早开始时间
- `l(i)` 表示活动（弧） `a(i)` 的最迟开始时间（不推迟整个工程完成的前提下）
    - `l(i) - e(i)` 表示完成活动 `ai` 的时间余量；**`l(i) == e(i)` 的活动叫做关键活动**

- `ve(i)` 表示事件（顶点）的最早发生时间
- `vl(i)` 表示事件（顶点）的最迟发生时间

如果活动 `ai` 由弧 `<j, k>` 表示，则：

```
e[i] = ve[j];
l[i] = vl[k] - dut(<j, k>);
```

求 `ve(j)` 和 `vl(j)` 需分两步进行：

1. 从 `ve(0) == 0` 开始向前推进：

    ```
    ve(j) = MAX{ ve(i) + dut(<i, j>) }
    ```

2. 从 `vl(n - 1) = ve(n - 1)` 开始向后推进：

    ```
    vl(i) = MIN{ vl(j) - dut(<i, j>) }
    ```

求关键路径的算法：

- 输入 `e` 条弧 `<i, j>`，建立 `AOE网` 的存储结构
- 从原点 `v0` 出发，令 `ve[0] = 0` ，按拓扑排序求其余各顶点的最早发生时间 `ve[i] (1 <= i <= n-1)` 如果得到的拓扑有序序列中顶点个数小于网中顶点数 `n`，则说明网中存在环，不能求关键路径，算法终止，否则执行步骤三
- 从汇总点 `vn` 出发，令 `vl[n - 1] = ve[n - 1]` ，按逆拓扑排序求其余各顶点的最迟发生时间 `vl[i] (n - 2 >= i >= 2)`
- 根据各顶点的 `ve` 和 `vl` 值，求每条弧 `s` 的最早开始时间 `e(s)` 和最迟开时间 `l(s)`，若某条弧满足条件 `e(s) == l(s)` ，则为关键活动


```c
#include <cstdio>
#include <vector>
#include <queue>
#include <stack>
using namespace std;
const int MAXV = 1000;
struct Vertex {
    int v;      // 顶点编号
    int weight;
};
vector<Vertex> G[MAXV];
stack<int> topoOrder;
int n, inDegree[MAXV];
int ve[MAXV], vl[MAXV];

bool TopologicalOrder () {

    queue<int> q;
    for (int i = 0; i < n; i++) {
        if (inDegree[i] == 0)
            q.push(i);
    }

    while (!q.empty()) {
        int u = q.front();
        q.pop();
        topoOrder.push(u);
        for (int i = 0; i < G[u].size(); i++) {
            int v = G[u][i].v;
            inDegree[v]--;
            if (inDegree[v] == 0)
                q.push(v);
            if (ve[u] + G[u][i].weight > ve[v]) // ve(j) = MAX{ ve(i) + dut(<i, j>) }
                ve[v] = ve[u] + G[u][i].weight;
        }
    }

    if (topoOrder.size() == n)
        return true;
    else
        return false;
}

int CriticalPath () {

    memset(ve, 0, sizeof(ve));
    if (!TopologicalOrder()) // 拓扑排序失败，说明不是有向无环图，返回 -1
        return -1;
    fill(vl, vl + n, ve[n - 1]);

    while (!topoOrder.empty()) {
        int u = topoOrder.top();
        topoOrder.pop();
        for (int i = 0; i < G[u].size(); i++) {
            int v = G[u][i].v;
            if (vl[v] - G[u][i].weight < vl[u]) // vl(i) = MIN{ vl(j) - dut(<i, j>) }
                vl[u] = vl[v] - G[u][i].weight;
        }
    }

    for (int u = 0; u < n; u++) {
        for (int i = 0; i < G[u].size(); i++) {
            int v = G[u][i].v, weight = G[u][i].weight;
            int e = ve[u], l = vl[v] - weight;
            if (e == l)
                printf("%d -> %d", u, v); // 输出关键活动
        }
    }
    return ve[n - 1]; // 返回关键路径的长度
}
```