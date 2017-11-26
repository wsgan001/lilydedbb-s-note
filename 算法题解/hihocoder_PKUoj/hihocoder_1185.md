## [【hihocoder】1185 : 连通性·三](https://hihocoder.com/problemset/problem/1185)

时间限制:10000ms

单点时限:1000ms

内存限制:256MB

### 描述

暑假到了!!小Hi和小Ho为了体验生活，来到了住在大草原的约翰家。今天一大早，约翰因为有事要出去，就拜托小Hi和小Ho忙帮放牧。

约翰家一共有N个草场，每个草场有容量为W[i]的牧草，N个草场之间有M条单向的路径。

小Hi和小Ho需要将牛羊群赶到草场上，当他们吃完一个草场牧草后，继续前往其他草场。当没有可以到达的草场或是能够到达的草场都已经被吃光了之后，小hi和小Ho就把牛羊群赶回家。

一开始小Hi和小Ho在1号草场，在回家之前，牛羊群最多能吃掉多少牧草？

举个例子：

week54_1.png

图中每个点表示一个草场，上部分数字表示编号，下部分表示草场的牧草数量w。

在1吃完草之后，小Hi和小Ho可以选择把牛羊群赶到2或者3，假设小Hi和小Ho把牛羊群赶到2：

吃完草场2之后，只能到草场4，当4吃完后没有可以到达的草场，所以小Hi和小Ho就把牛羊群赶回家。

若选择从1到3，则可以到达5，6：

选择5的话，吃完之后只能直接回家。若选择6，还可以再通过6回到3，再到5。

所以该图可以选择的路线有3条：

1->2->4 		total: 11
1->3->5 		total: 9
1->3->6->3->5: 		total: 13

所以最多能够吃到的牧草数量为13。

本题改编自USACO月赛金组

提示：强连通分量

### 输入

第1行：2个正整数，N,M。表示点的数量N，边的数量M。1≤N≤20,000, 1≤M≤100,000

第2行：N个正整数，第i个整数表示第i个牧场的草量w[i]。1≤w[i]≤100,000

第3..M+2行：2个正整数，u,v。表示存在一条从u到v的单向路径。1≤u,v≤N

### 输出

第1行：1个整数，最多能够吃到的牧草数量。

#### 样例输入

```
6 6
2 4 3 5 4 4
1 2
2 4
1 3
3 5
3 6
6 3
```

#### 样例输出

```
13
```

```c
#include <iostream>
#include <vector>
#include <climits>
#include <algorithm>
using namespace std;
const int MAXN = 20001;
int vis[MAXN], low[MAXN], dfn[MAXN], old2new[MAXN], w[MAXN], new_w[MAXN];
// old2new 保存原有的 index 到 新的index 的映射
// w 保存原图节点对应的权重；new_w 保存新图节点对应的权重
int counter = 0, new_index = 0;
vector<int> dfs_stack;

void Tarjan (int u, vector<vector<int>> G) {
    vis[u] = true;
    low[u] = dfn[u] = ++counter;
    dfs_stack.push_back(u);
    for (int i = 0; i < G[u].size(); i++) {
        int v = G[u][i];
        if (!vis[v]) {
            Tarjan(v, G);
            low[u] = min(low[u], low[v]);
        } else if (find(dfs_stack.begin(), dfs_stack.end(), v) != dfs_stack.end()) {
            low[u] = min(low[u], dfn[v]);
        }
    }
    if (low[u] == dfn[u]) {
        new_index++;
        while (!dfs_stack.empty()) {
            int j = dfs_stack[dfs_stack.size() - 1];
            dfs_stack.pop_back();
            old2new[j] = new_index;
            new_w[new_index] += w[j];
            if (j == u) break;
        }
    }
}

// 重新构建图
vector<vector<int>> regraph (vector<vector<int>> G) {
    vector<vector<int>> new_G(G.size());
    for (int i = 1; i < G.size(); i++) {
        for (int j = 0; j < G[i].size(); j++) {
            int u = old2new[i], v = old2new[G[i][j]];
            if (u == -1 || v == -1) continue;
            if (u != v) new_G[u].push_back(v);
        }
    }
    return new_G;
}

void dfs (int u, vector<vector<int>> G, int sum, int &max_sum) {
    vis[u] = true;
    sum += new_w[u];
    if (sum > max_sum) max_sum = sum;
    for (int i = 0; i < G[u].size(); i++) {
        int v = G[u][i];
        if (!vis[v]) {
            dfs(v, G, sum, max_sum);
        }
    }
}

int main(int argc, const char * argv[]) {

    int n, m, n1, n2, _w;
    cin >> n >> m;
    vector<vector<int>> G(n + 1);
    for (int i = 1; i <= n; i++){
        cin >> _w;
        w[i] =_w;
    }
    while (m--) {
        cin >> n1 >> n2;
        G[n1].push_back(n2);
    }

    fill(vis, vis + n + 1, false);
    fill(old2new, old2new + MAXN, -1);
    Tarjan(1, G);

    vector<vector<int>> new_G = regraph(G);
    fill(vis, vis + n + 1, false);
    int sum = 0, max_sum = INT_MIN;
    dfs(old2new[1], new_G, sum, max_sum);
    cout << max_sum << endl;

    return 0;
}
```