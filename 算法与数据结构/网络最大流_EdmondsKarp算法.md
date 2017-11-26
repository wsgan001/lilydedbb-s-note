# 网络最大流 —— EdmondsKarp算法

算法复杂度：`O(V * E^2)`

**网络流中的一些定义：**

- V 表示整个图中的所有结点的集合
- E 表示整个图中所有边的集合
- G = (V, E)，表示整个图
- s 表示网络的源点，t 表示网络的汇点
- 对于每条边 (u, v)，有一个容量 c(u, v)   (c(u, v) >= 0)，如果 c(u, v) = 0，则表示 (u,v) 不存在在网络中。同理，如果原网络中不存在边(u, v)，则令 c(u, v) = 0
- 对于每条边 (u, v)，有一个流量 f(u, v)

网络流的三个性质：

1. 容量限制: `f[u, v] <= c[u, v]`
2. 反对称性：`f[u, v] = -f[v, u]`
3. 流量平衡:  对于不是源点也不是汇点的任意结点，流入该结点的流量和等于流出该结点的流量和

**EdmondsKarp算法（增广路算法）**

**残量网络**

为了更方便算法的实现，一般根据原网络定义一个残量网络。其中 r(u, v) 为残量网络的容量。

```
r(u, v) = c(u, v) – f(u, v)
```

通俗地讲：就是对于某一条边（也称弧），还能再有多少流量经过

**增广路定义**：在残量网络中的一条从s通往t的路径，其中任意一条弧(u,v)，都有r[u,v]>0。

**增广路算法**：每次用BFS找一条最短的增广路径，然后沿着这条路径修改流量值（实际修改的是残量网络的边权）。当没有增广路时，算法停止，此时的流就是最大流。

**++从本质上说，后向弧为算法纠正自己所犯的错误提供了可能性，它允许算法取消先前的错误的行为++**

这里以 [PAT T1003. Universal Travel Sites (35)](https://www.patest.cn/contests/pat-t-practise/1003) 为例：

```c
#include <iostream>
#include <string>
#include <map>
#include <vector>
#include <queue>
#include <climits>
#include <algorithm>
using namespace std;
string source, dest;
int n, cnt = 0;
vector<vector<int>> G;
vector<int> pre;
map<string, int> name2id;

bool bfs () { // 探寻是否还有增广路
	queue<int> q;
	q.push(name2id[source]);
	fill(pre.begin(), pre.end(), -1);
	while (!q.empty()) {
		int node = q.front();
		q.pop();
		for (int i = 0; i < cnt; i++) {
			if (G[node][i] != 0 && pre[i] == -1) {
				pre[i] = node;
				if (i == name2id[dest]) return true;
				q.push(i);
			}
		}
	}
	return false;
}

int EdmondsKarp () { // 网络最大流
	int max_flow = 0;
	while (bfs()) {
		int min_flow = INT_MAX;
		for (int i = name2id[dest]; i != name2id[source]; i = pre[i])
			min_flow = min(min_flow, G[pre[i]][i]);
		for (int i = name2id[dest]; i != name2id[source]; i = pre[i]) {
			G[pre[i]][i] -= min_flow;
			G[i][pre[i]] += min_flow;
		}
		max_flow += min_flow;
	}
	return max_flow;
}

int main () {

	string a, b;
	int c;
	cin >> source >> dest >> n;
	G.resize(2 * n, vector<int>(2 * n, 0)); // 顶点数最多为边数的两倍
	pre.resize(2 * n, -1);
	while (n--) {
		cin >> a >> b >> c;
		if (name2id.find(a) == name2id.end()) name2id[a] = cnt++;
		if (name2id.find(b) == name2id.end()) name2id[b] = cnt++;
		G[name2id[a]][name2id[b]] = c;
	}
	cout << EdmondsKarp() << endl;

	return 0;
}
```
