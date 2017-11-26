## [【hihocoder】1184 : 连通性二·边的双连通分量](https://hihocoder.com/problemset/problem/1184)

时间限制:10000ms

单点时限:1000ms

内存限制:256MB

### 描述

在基本的网络搭建完成后，学校为了方便管理还需要对所有的服务器进行编组，网络所的老师找到了小Hi和小Ho，希望他俩帮忙。

老师告诉小Hi和小Ho：根据现在网络的情况，我们要将服务器进行分组，对于同一个组的服务器，应当满足：当组内任意一个连接断开之后，不会影响组内服务器的连通性。在满足以上条件下，每个组内的服务器数量越多越好。

比如下面这个例子，一共有6个服务器和7条连接：

week53_1.png

其中包含2个组，分别为{1,2,3},{4,5,6}。对{1,2,3}而言，当1-2断开后，仍然有1-3-2可以连接1和2；当2-3断开后，仍然有2-1-3可以连接2和3；当1-3断开后，仍然有1-2-3可以连接1和3。{4,5,6}这组也是一样。

week53_1_1.png

老师把整个网络的情况告诉了小Hi和小Ho，小Hi和小Ho要计算出每一台服务器的分组信息。


提示：边的双连通分量


### 输入

第1行：2个正整数，N,M。表示点的数量N，边的数量M。1≤N≤20,000, 1≤M≤100,000

第2..M+1行：2个正整数，u,v。表示存在一条边(u,v)，连接了u,v两台服务器。1≤u<v≤N

保证输入所有点之间至少有一条连通路径。

### 输出

第1行：1个整数，表示该网络的服务器组数。

第2行：N个整数，第i个数表示第i个服务器所属组内，编号最小的服务器的编号。比如分为{1,2,3},{4,5,6}，则输出{1,1,1,4,4,4}；若分为{1,4,5},{2,3,6}则输出{1,2,2,1,1,2}

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
2
1 1 1 4 4 4
```

```c
#include <iostream>
#include <vector>
#include <stack>
#include <algorithm>
using namespace std;
const int MAXN = 20001;
int vis[MAXN], low[MAXN], dfn[MAXN], parent[MAXN];
int c = 0, bridge_num = 0;
stack<int> s;

void Tarjan (int u, vector<vector<int>> G) {
    vis[u] = true;
    low[u] = dfn[u] = ++c;
    s.push(u);
    for (int i = 0; i < G[u].size(); i++) {
        int v = G[u][i];
        if (!vis[v]) {
            parent[v] = u;
            Tarjan(v, G);
            low[u] = min(low[u], low[v]);
            if (low[v] > dfn[u]) { // (u, v) 是桥
                bridge_num++;
            }
        } else if (v != parent[u]) {
            low[u] = min(low[u], dfn[v]);
        }
    }
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
    cout << bridge_num + 1 << endl;
    vector<int> v, group(n + 1);
    while (!s.empty()) {
        int top = s.top();
        s.pop();
        v.push_back(top);
        if (low[top] == dfn[top]) {
            int min_index = *min_element(v.begin(), v.end());
            for (int _v : v) group[_v] = min_index;
            v.clear();
        }
    }
    for (int i = 1; i < group.size(); i++)
        cout << group[i] << " ";

    return 0;
}
```