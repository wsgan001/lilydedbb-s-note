## [【hihocoder】1183 : 连通性一·割边与割点](https://hihocoder.com/problemset/problem/1183)

时间限制:10000ms

单点时限:1000ms

内存限制:256MB

### 描述

还记得上次小Hi和小Ho学校被黑客攻击的事情么，那一次攻击最后造成了学校网络数据的丢失。为了避免再次出现这样的情况，学校决定对校园网络进行重新设计。

学校现在一共拥有N台服务器(编号1..N)以及M条连接，保证了任意两台服务器之间都能够通过连接直接或者间接的数据通讯。

当发生黑客攻击时，学校会立刻切断网络中的一条连接或是立刻关闭一台服务器，使得整个网络被隔离成两个独立的部分。

举个例子，对于以下的网络：

week52_1.png

每两个点之间至少有一条路径连通，当切断边(3,4)的时候，可以发现，整个网络被隔离为{1，2，3}，{4，5，6}两个部分：

week52_2.png

若关闭服务器3，则整个网络被隔离为{1，2}，{4，5，6}两个部分：

week52_3.png

小Hi和小Ho想要知道，在学校的网络中有哪些连接和哪些点被关闭后，能够使得整个网络被隔离为两个部分。

在上面的例子中，满足条件的有边(3,4)，点3和点4。

### 提示

割边：在连通图中，删除了连通图的某条边后，图不再连通。这样的边被称为割边，也叫做桥。

割点：在连通图中，删除了连通图的某个点以及与这个点相连的边后，图不再连通。这样的点被称为割点。

DFS搜索树：用DFS对图进行遍历时，按照遍历次序的不同，我们可以得到一棵DFS搜索树。在上面例子中，得到的搜索树为：

week52_4.png

树边：在搜索树中的蓝色线所示，可理解为在DFS过程中访问未访问节点时所经过的边，也称为父子边

回边：在搜索树中的橙色线所示，可理解为在DFS过程中遇到已访问节点时所经过的边，也称为返祖边、后向边

观察DFS搜索树，我们可以发现有两类节点可以成为割点：

对根节点u，若其有两棵或两棵以上的子树，则该根结点u为割点；

对非叶子节点u（非根节点），若其中的某棵子树的节点均没有指向u的祖先节点的回边，说明删除u之后，根结点与该棵子树的节点不再连通；则节点u为割点。

对于根结点，显然很好处理；但是对于非叶子节点，怎么去判断有没有回边是一个值得深思的问题。

我们用dfn[u]记录节点u在DFS过程中被遍历到的次序号，low[u]记录节点u或u的子树通过非父子边追溯到最早的祖先节点（即DFS次序号最小），那么low[u]的计算过程如下：

week52_5.png

对于给的例子，其求出的dfn和low数组为：

```
id  1 2 3 4 5 6
dfn 1 2 3 4 5 6
low 1 1 1 4 4 4
```

可以发现，对于情况2，当(u,v)为树边且low[v]≥dfn[u]时，节点u才为割点。

而当(u,v)为树边且low[v]>dfn[u]时，表示v节点只能通过该边(u,v)与u连通，那么(u,v)即为割边。

### 输入

第1行：2个正整数，N,M。表示点的数量N，边的数量M。1≤N≤20,000, 1≤M≤100,000

第2..M+1行：2个正整数，u,v。表示存在一条边(u,v)，连接了u,v两台服务器。1≤u<v≤N

保证输入所有点之间至少有一条连通路径。

### 输出

第1行：若干整数，用空格隔开，表示满足要求的服务器编号。从小到大排列。若没有满足要求的点，该行输出Null

第2..k行：每行2个整数，(u,v)表示满足要求的边，u<v。所有边根据u的大小排序，u小的排在前，当u相同时，v小的排在前面。若没有满足要求的边，则不输出

#### 样例输入

```
6 7
1 2
1 3
2 3
3 4
4 5
4 6
5 6
```

#### 样例输出

```
3 4
3 4
```

```c
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;
const int MAXN = 20001;
int vis[MAXN], low[MAXN], dfn[MAXN], parent[MAXN];
vector<int> nodes;
vector<pair<int, int>> edges;
int c = 0;

void Tarjan (int u, vector<vector<int>> G) {
    low[u] = dfn[u] = ++c;
    vis[u] = true;
    int children = 0; // 记录子节点数
    for (int i = 0; i < G[u].size(); i++) {
        int v = G[u][i];
        if (!vis[v]) { // v 还未被访问过，即 (u, v) 为树边
            children++;
            parent[v] = u;
            Tarjan(v, G);
            low[u] = min(low[u], low[v]);
            if (parent[u] == -1 && children > 1) // 对根节点 u ，若其有两棵或两棵以上的子树，则该根结点 u 为割点
                nodes.push_back(u);
            if (parent[u] != -1 && low[v] >= dfn[u]) // 对于非根节点，若 v 通过非父子边向上最多只能追溯到 u ，则 u 为割点
                nodes.push_back(u);
            if (low[v] > dfn[u]) // // 对于非根节点，若 v 通过非父子边向上能追溯到的节点在 u 之后，则 (u, v) 为割边
                edges.push_back(make_pair(u, v));
        } else if (v != parent[u]) { // v 已被访问过，且不是父节点，即 (u, v) 为回边
            low[u] = min(low[u], dfn[v]);
        }
    }
}

bool cmp (pair<int, int> a, pair<int, int> b) {
    if (a.first != b.first)
        return a.first < b.first;
    else
        return a.second < b.second;
}

int main(int argc, const char * argv[]) {

    int n, m, n1, n2;
    cin >> n >> m;
    vector<vector<int>> G(n + 1);
    while (m--) {
        cin >> n1 >> n2;
        G[n1].push_back(n2);
        G[n2].push_back(n1);
    }
    fill(vis, vis + n + 1, false);
    fill(parent, parent + n + 1, -1);
    Tarjan(1, G);
    sort(nodes.begin(), nodes.end());
    sort(edges.begin(), edges.end(), cmp);
    for (auto node : nodes) cout << node << " ";
    cout << endl;
    for (auto edge : edges) cout << edge.first << " " << edge.second << endl;

    return 0;
}
```