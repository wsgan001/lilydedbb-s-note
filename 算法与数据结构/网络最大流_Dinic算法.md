# 网络最大流 —— Dinic算法

Dinic算法（又称Dinitz算法）是一个在网络流中计算最大流的强多项式复杂度的算法。

Dinic算法与Edmonds–Karp算法的不同之处在于它每轮算法都选择最短的可行路径进行增广。Dinic算法中采用高度标号（level graph）以及阻塞流（blocking flow）实现其性能。

算法思路，每一步对原图进行分层，然后用DFS求增广路。时间复杂度是 O(V ^ 2 * E)。

1. 根据残量网络计算层次图
2. 在层次图中使用DFS进行增广直到不存在增广路
3. 重复以上步骤直到无法增广

这里以 [PAT T1003. Universal Travel Sites (35)](https://www.patest.cn/contests/pat-t-practise/1003) 为例：

```c
#include <iostream>
#include <string>
#include <queue>
#include <map>
#include <vector>
#include <climits>
#include <algorithm>
using namespace std;
string source, dest;
int n, cnt = 0;
vector<int> level;
vector<vector<int>> G;
map<string, int> name2id;

struct Edge {
	int from, to, cap;
	Edge(int f, int t, int c): from(f), to(t), cap(c) {};
};

vector<Edge> EG;

void addEdge (int from, int to, int cap) {
	EG.push_back(Edge(from, to, cap));
	EG.push_back(Edge(to, from, 0)); // 反向边容量为0
	G[from].push_back(EG.size() - 2);
	G[to].push_back(EG.size() - 1);
	// 正向边下标通过异或就得到反向边下标, 2 ^ 1 == 3 ; 3 ^ 1 == 2
}

bool bfs () {
	queue<int> q;
	q.push(name2id[source]);
	fill(level.begin(), level.end(), -1);
	level[name2id[source]] = 0;
	while (!q.empty()) {
		int node = q.front();
		q.pop();
		for (int i = 0; i < G[node].size(); i++) {
			Edge e = EG[G[node][i]];
			if (level[e.to] == -1 && e.cap > 0) {
				level[e.to] = level[node] + 1;
				q.push(e.to);
			}
		}
	}
	if (level[name2id[dest]] == -1) return false;
	else return true;
}

int dfs (int now, int a) {
	if (now == name2id[dest] || a == 0) return a;
	int flow = 0, f;
	for (int i = 0; i < G[now].size(); i++) {
		Edge &e = EG[G[now][i]];
		if (level[now] + 1 == level[e.to] && (f = dfs(e.to, min(a, e.cap))) > 0) {
			e.cap -= f;
			EG[G[now][i] ^ 1].cap += f; // 正向边下标通过异或就得到反向边下标, 2 ^ 1 == 3 ; 3 ^ 1 == 2
			flow += f;
			a -= f;
			if (a == 0) break;
		}
	}
	return flow;
}

int Dinic () {
	int max_flow = 0;
	while (bfs()) {
		max_flow += dfs(name2id[source], INT_MAX);
	}
	return max_flow;
}

int main () {

	cin >> source >> dest >> n;
	string a, b;
	G.resize(2 * n);
	level.resize(2 * n);
	int c;
	while (n--) {
		cin >> a >> b >> c;
		if (name2id.find(a) == name2id.end()) name2id[a] = cnt++;
		if (name2id.find(b) == name2id.end()) name2id[b] = cnt++;
		addEdge(name2id[a], name2id[b], c);
	}
	cout << Dinic() << endl;

	return 0;
}
```
