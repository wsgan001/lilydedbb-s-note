## [【hihocoder】1041 : 国庆出游](https://hihocoder.com/problemset/problem/1041)

时间限制:1000ms

单点时限:1000ms

内存限制:256MB

### 描述

小Hi和小Ho准备国庆期间去A国旅游。A国的城际交通比较有特色：它共有n座城市(编号1-n)；城市之间恰好有n-1条公路相连，形成一个树形公路网。小Hi计划从A国首都(1号城市)出发，自驾遍历所有城市，并且经过每一条公路恰好两次——来回各一次——这样公路两旁的景色都不会错过。

令小Hi苦恼的是他的小伙伴小Ho希望能以某种特定的顺序游历其中m个城市。例如按3-2-5的顺序游历这3座城市。(具体来讲是要求：第一次到达3号城市比第一次到达2号城市早，并且第一次到达2号城市比第一次到达5号城市早)。

小Hi想知道是否有一种自驾顺序满足小Ho的要求。

### 输入

输入第一行是一个整数T(1<=T<=20)，代表测试数据的数量。

每组数据第一行是一个整数n(1 <= n <= 100)，代表城市数目。

之后n-1行每行两个整数a和b (1 <= a, b <= n)，表示ab之间有公路相连。

之后一行包含一个整数m (1 <= m <= n)

最后一行包含m个整数，表示小Ho希望的游历顺序。

### 输出

YES或者NO，表示是否有一种自驾顺序满足小Ho的要求。

#### 样例输入

```
2
7
1 2
1 3
2 4
2 5
3 6
3 7
3
3 7 2
7
1 2
1 3
2 4
2 5
3 6
3 7
3
3 2 7
```

#### 样例输出

```
YES
NO
```

### 思路

> 把题目中的序列称作S，树称作T。那么对于S中的任意节点x，x的子孙节点如果在S出现的话，那么这个子孙节点的位置是有一定要求的：x的所有子孙节点在S中的位置都恰好紧跟在x的后面，没有被其他节点隔开。 设x的子孙节点是abcd，那么--xabcd--, --xbcda-- 等等是合法的，--xab-cd--, --axbcd--, --x--abcd--, 都是不合法的('-'指其他节点)。对于S中每个节点都做如上判断，如果有不合法的就输出NO，如果都合法就输出YES。

```c
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;
const int MAXN = 101;
vector<bool> vis(MAXN, false);

int getIndex (int n, vector<int> v) {
    for (int i = 0; i < v.size(); i++)
        if (v[i] == n) return i;
    return -1;
}

bool check (int curIndex, vector<int> children, vector<int> s) {
    vector<int> childIndex;
    for (int i = 0; i < children.size(); i++) {
        int ci = getIndex(children[i], s);
        if (ci != -1 && !vis[children[i]]) childIndex.push_back(ci);
    }
    if (childIndex.size() == 0) return true;
    sort(childIndex.begin(), childIndex.end());
    for (int i = 0; i < childIndex.size(); i++) {
        curIndex++;
        if (childIndex[i] != curIndex) return false;
    }
    return true;
}

bool dfs (int c, vector<vector<int>> G, vector<int> s) {
    int curIndex = getIndex(c, s);
    if (curIndex != -1)
        if (!check(curIndex, G[c], s)) return false;
    for (int i = 0; i < G[c].size(); i++) {
        if (!vis[G[c][i]]) {
            vis[G[c][i]] = true;
            if (!dfs(G[c][i], G, s))
                return false;
        }
    }
    return true;
}


int main(int argc, const char * argv[]) {

    int t, n, m, c, c1, c2;
    cin >> t;
    while (t--) {
        cin >> n;
        vector<vector<int>> G(n + 1);
        while (--n) {
            cin >> c1 >> c2;
            G[c1].push_back(c2);
            G[c2].push_back(c1);
        }
        cin >> m;
        vector<int> s;
        while (m--) {
            cin >> c;
            s.push_back(c);
        }
        fill(vis.begin(), vis.end(), false);
        vis[1] = true;
        if (dfs(1, G, s))
            cout << "YES" << endl;
        else
            cout << "NO" << endl;
    }
    return 0;
}
```