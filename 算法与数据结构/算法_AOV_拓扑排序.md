# AOV (Activity On Vertex) 网 —— 拓扑排序 (Topological Ordering)

AOV (Activity On Vertex) 网:

> 用顶点表示活动，用弧表示活动间优先关系的有向图，称为顶点表示活动的网

拓扑排序 (Topological Ordering)：

> 可以判断一个图是否为有向无环图 (Directed Acyclic Graph, DAG)

- 定义一个队列 `Q`，并把所有入度为 `0` 的结点加入队列
- 取队首结点，输出，然后删去所有从它出发的边，并令这些边到达的顶点的入度减1，如果某个顶点的入度减为0，则将其加入队列
- 反复进行第二步，直到队列为空，如果队列为空的时候，入过队的结点数目恰好为 `N` ，则拓扑排序成功；否则，拓扑排序失败


```c
#include <cstdio>
#include <vector>
#include <queue>
using namespace std;
const int MAXV = 1000;
vector<int> G[MAXV];        // 邻接表
int n, inDegree[MAXV];   // 顶点数、入度

bool topologicalOrder () {

    int num = 0;
    queue<int> q;
    for (int i = 0; i < n; i++) { // 把所有入度为0的结点加入队列
        if (inDegree[i] == 0)
            q.push(i);
    }

    while (!q.empty()) {
        int u = q.front(); // 取队首结点，输出
        printf("%d ", u);
        q.pop();
        for (int i = 0; i < G[u].size(); i++) {
            int v = G[u][i];
            inDegree[v]--; // 令这些边到达的顶点的入度减1
            if (inDegree[v] == 0) // 如果某个顶点的入度减为0，则将其加入队列
                q.push(v);
        }
        G[u].clear(); // 删去所有从它出发的边
        num++;
    }

    // 如果队列为空的时候，入过队的结点数目恰好为N，则拓扑排序成功；否则，拓扑排序失败
    if (num == n)
        return true;
    else
        return false;
}
```