# PAT T 1 - 5


## [T1001. Battle Over Cities - Hard Version (35)](https://www.patest.cn/contests/pat-t-practise/1001)

It is vitally important to have all the cities connected by highways in a war. If a city is conquered by the enemy, all the highways from/toward that city will be closed. To keep the rest of the cities connected, we must repair some highways with the minimum cost. On the other hand, if losing a city will cost us too much to rebuild the connection, we must pay more attention to that city.

Given the map of cities which have all the destroyed and remaining highways marked, you are supposed to point out the city to which we must pay the most attention.

**Input Specification:**

Each input file contains one test case. Each case starts with a line containing 2 numbers N (<=500), and M, which are the total number of cities, and the number of highways, respectively. Then M lines follow, each describes a highway by 4 integers:

```
City1 City2 Cost Status
```

where City1 and City2 are the numbers of the cities the highway connects (the cities are numbered from 1 to N), Cost is the effort taken to repair that highway if necessary, and Status is either 0, meaning that highway is destroyed, or 1, meaning that highway is in use.

Note: It is guaranteed that the whole country was connected before the war.

**Output Specification:**

For each test case, just print in a line the city we must protest the most, that is, it will take us the maximum effort to rebuild the connection if that city is conquered by the enemy.

In case there is more than one city to be printed, output them in increasing order of the city numbers, separated by one space, but no extra space at the end of the line. In case there is no need to repair any highway at all, simply output 0.

**Sample Input 1:**

```
4 5
1 2 1 1
1 3 1 1
2 3 1 0
2 4 1 1
3 4 1 0
```

**Sample Output 1:**

```
1 2
```

**Sample Input 2:**

```
4 5
1 2 1 1
1 3 1 1
2 3 1 0
2 4 1 1
3 4 2 1
```

**Sample Output 2:**

```
0
```

思路：最小生成树（Krustal 算法）

从顶点 1 遍历到 n, 每次遍历，求除去该顶点后的剩下的图的最小生成树，并根据边的状态计算cost。根据每次计算的cost，判断该定点是否是最需要注意的顶点。

**未完全通过；`25/35`；[查看提交](https://www.patest.cn/submissions/3671059)**

```c
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;
int n, m;
vector<int> parent;

struct Edge {
	int c1, c2, cost, status;
	Edge (int c1, int c2, int cost, int status): c1(c1), c2(c2), cost(cost), status(status) {};
};

vector<Edge> edges;

bool cmp (Edge e1, Edge e2) {
	if (e1.status != e2.status) return e1.status > e2.status;
	else return e1.cost < e2.cost;
}

void initParent () { for (int i = 1; i < parent.size(); i++) parent[i] = i; }

int findParent (int x) {
	int _x = x;
	while (x != parent[x]) x = parent[x];
	while (_x != parent[_x]) {
		int temp = parent[_x];
		parent[_x] = x;
		_x = temp;
	}
	return x;
}

void Union (int a, int b) {
	int fa = findParent(a);
	int fb = findParent(b);
	if (fa != fb) parent[fb] = fa;
}

int findMinTree (int e) {
	int cost = 0;
	initParent();
	vector<bool> vis(n + 1, false);
	vis[e] = true;
	for (int i = 0; i < edges.size(); i++) {
		if (edges[i].c1 == e || edges[i].c2 == e) continue;
		if (vis[edges[i].c1] && vis[edges[i].c2]) continue;
		Union(edges[i].c1, edges[i].c2);
		vis[edges[i].c1] = true; vis[edges[i].c2] = true;
		if (edges[i].status == 0) {
			cost += edges[i].cost;
		}
	}
	return cost;
}

int main () {

	int c1, c2, cost, status;
	cin >> n >> m;
	parent.resize(n + 1, 0);
	while (m--) {
		cin >> c1 >> c2 >> cost >> status;
		edges.push_back(Edge(c1, c2, cost, status));
	}
	sort(edges.begin(), edges.end(), cmp);

	int max_cost = 0;
	vector<int> ans;
	for (int e = 1; e <= n; e++) {
		int cost = findMinTree(e);
		if (cost > max_cost) { ans.clear(); max_cost = cost; ans.push_back(e); }
		else if (cost > 0 && cost == max_cost) { ans.push_back(e); }
	}

	if (ans.empty()) cout << "0" << endl;
	else {
		for (int i = 0; i < ans.size(); i++) {
			cout << ans[i];
			if (i < ans.size() - 1) cout << " ";
		}
		cout << endl;
	}

	return 0;
}
```


------


## [T1002. Business (35)](https://www.patest.cn/contests/pat-t-practise/1002)

As the manager of your company, you have to carefully consider, for each project, the time taken to finish it, the deadline, and the profit you can gain, in order to decide if your group should take this project. For example, given 3 projects as the following:

- Project[1] takes 3 days, it must be finished in 3 days in order to gain 6 units of profit.
- Project[2] takes 2 days, it must be finished in 2 days in order to gain 3 units of profit.
- Project[3] takes 1 day only, it must be finished in 3 days in order to gain 4 units of profit.

You may take Project[1] to gain 6 units of profit. But if you take Project[2] first, then you will have 1 day left to complete Project[3] just in time, and hence gain 7 units of profit in total. Notice that once you decide to work on a project, you have to do it from beginning to the end without any interruption.

**Input Specification:**

Each input file contains one test case. For each case, the first line gives a positive integer N(<=50), and then followed by N lines of projects, each contains three numbers P, L, and D where P is the profit, L the lasting days of the project, and D the deadline. It is guaranteed that L is never more than D, and all the numbers are non-negative integers.

**Output Specification:**

For each test case, output in a line the maximum profit you can gain.

**Sample Input:**

```
4
7 1 3
10 2 3
6 1 2
5 1 1
```

**Sample Output:**

```
18
```

**如果把问题考虑的简单了，只当做01背包问题（即最大的 deadline 为背包容量，需要的天数为物品重量）考虑时，会忽略一些情况。所以未完全通过；`23/35`；[查看提交](https://www.patest.cn/submissions/3675794)；++因为每个 project 都有 deadline，需要在自己的 deadline 之前做完，而不是在最大的 deadline 之前做完即可。++**

```c
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

struct Proj {
	int profit, need, deadline;
	Proj(int p, int l, int d): profit(p), need(l), deadline(d) {};
};

bool cmp (Proj p1, Proj p2) { return p1.deadline < p2.deadline; }

int main () {

	int n, p, l, d;
	cin >> n;
	vector<Proj> projects;
	for (int i = 0; i < n; i++) {
		cin >> p >> l >> d;
		projects.push_back(Proj(p, l, d));
	}
	sort(projects.begin(), projects.end(), cmp);

	int max_d = projects[projects.size() - 1].deadline;
	vector<int> dp(max_d + 1, 0);
	for (int i = 0; i < n; i++) {
		for (int j = max_d; j >= projects[i].need; j--) {
			dp[j] = max(dp[j], dp[j - projects[i].need] + projects[i].profit);
		}
	}
	cout << dp[max_d] << endl;

	return 0;
}
```

定义：`dp[i][j]`，表示在截止时间为 j 时，前 i 个项目工作安排能够得的最大收益，**这里有一个条件是，前 i 个项目的截止时间都不大于 j**

状态方程：

```c
dp[i][j] = max(dp[i - 1][j], dp[i - 1][t] + p.profit)
```

其中，**t 为在 j 截止时间添加项目 i 到工作安排中时，前 i-1 个项目必须在 t 之前完成**

则 t 满足：

```
t = min(j, p.deadline) - p.need
```

```c
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

struct Proj {
	int profit, need, deadline;
	Proj(int p, int l, int d): profit(p), need(l), deadline(d) {};
};

bool cmp (Proj p1, Proj p2) { return p1.deadline < p2.deadline; }

int main () {

	int n, p, l, d;
	cin >> n;
	vector<Proj> projects;
	for (int i = 0; i < n; i++) {
		cin >> p >> l >> d;
		projects.push_back(Proj(p, l, d));
	}
	sort(projects.begin(), projects.end(), cmp);

	int max_d = projects[projects.size() - 1].deadline;
	vector<vector<int>> dp(n + 1, vector<int>(max_d + 1, 0));
	int t = max_d;
	for (int i = 1; i <= n; i++) {
		Proj p = projects[i - 1];
		for (int j = 1; j <= max_d; j++) {
			int t = min(j, p.deadline) - p.need;
			if (t >= 0)
				dp[i][j] = max(dp[i - 1][j], dp[i - 1][t] + p.profit);
			else
				dp[i][j] = dp[i - 1][j];
		}
	}
	cout << dp[n][max_d] << endl;

	return 0;
}
```


------


## [T1003. Universal Travel Sites (35)](https://www.patest.cn/contests/pat-t-practise/1003)

After finishing her tour around the Earth, CYLL is now planning a universal travel sites development project. After a careful investigation, she has a list of capacities of all the satellite transportation stations in hand. To estimate a budget, she must know the minimum capacity that a planet station must have to guarantee that every space vessel can dock and download its passengers on arrival.

**Input Specification:**

Each input file contains one test case. For each case, the first line contains the names of the source and the destination planets, and a positive integer N (<=500). Then N lines follow, each in the format:

```
sourcei destinationi capacityi
```

where sourcei and destinationi are the names of the satellites and the two involved planets, and capacityi > 0 is the maximum number of passengers that can be transported at one pass from sourcei to destinationi. Each name is a string of 3 uppercase characters chosen from {A-Z}, e.g., ZJU.

Note that the satellite transportation stations have no accommodation facilities for the passengers. Therefore none of the passengers can stay. Such a station will not allow arrivals of space vessels that contain more than its own capacity. It is guaranteed that the list contains neither the routes to the source planet nor that from the destination planet.

**Output Specification:**

For each test case, just print in one line the minimum capacity that a planet station must have to guarantee that every space vessel can dock and download its passengers on arrival.

**Sample Input:**

```
EAR MAR 11
EAR AAA 300
EAR BBB 400
AAA BBB 100
AAA CCC 400
AAA MAR 300
BBB DDD 400
AAA DDD 400
DDD AAA 100
CCC MAR 400
DDD CCC 200
DDD MAR 300
```

**Sample Output:**

```
700
```

**EdmondsKarp 算法：**

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

**Dinic 算法的解法，用时更短**

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


------


## [T1004. To Buy or Not to Buy - Hard Version (35)](https://www.patest.cn/contests/pat-t-practise/1004)

Eva would like to make a string of beads with her favorite colors so she went to a small shop to buy some beads. There were many colorful strings of beads. However the owner of the shop would only sell the strings in whole pieces. Hence in some cases Eva might have to buy several strings to get all the beads she needs. With a hundred strings in the shop, Eva needs your help to tell her whether or not she can get all the beads she needs with the least number of extra beads she has to pay for.

For the sake of simplicity, let's use the characters in the ranges [0-9], [a-z], and [A-Z] to represent the colors. In sample 1, buying the 2nd and the last two strings is the best way since there are only 3 extra beads. In sample 2, buying all the three strings won't help since there are three "R" beads missing.

**Input Specification:**

Each input file contains one test case. Each case first gives in a line the string that Eva wants. Then a positive integer N (<=100) is given in the next line, followed by N lines of strings that belong to the shop. All the strings contain no more than 1000 beads.

**Output Specification:**

For each test case, print your answer in one line. If the answer is "Yes", then also output the least number of extra beads Eva has to buy; or if the answer is "No", then also output the number of beads missing from all the strings. There must be exactly 1 space between the answer and the number.

**Sample Input 1:**

```
RYg5
8
gY5Ybf
8R5
12346789
gRg8h
5Y37
pRgYgbR52
8Y
8g
```

**Sample Output 1:**

```
Yes 3
```

**Sample Input 2:**

```
YrRR8RRrY
3
ppRGrrYB225
8ppGrrB25
Zd6KrY
```

**Sample Output 1:**

```
No 3
```

```c

```
