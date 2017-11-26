## [【hihocoder】1174 : 拓扑排序·一](https://hihocoder.com/problemset/problem/1174)

时间限制:10000ms

单点时限:1000ms

内存限制:256MB

### 描述

由于今天上课的老师讲的特别无聊，小Hi和小Ho偷偷地聊了起来。

小Ho：小Hi，你这学期有选什么课么？

小Hi：挺多的，比如XXX1,XXX2还有XXX3。本来想选YYY2的，但是好像没有先选过YYY1，不能选YYY2。

小Ho：先修课程真是个麻烦的东西呢。

小Hi：没错呢。好多课程都有先修课程，每次选课之前都得先查查有没有先修。教务公布的先修课程记录都是好多年前的，不但有重复的信息，好像很多都不正确了。

小Ho：课程太多了，教务也没法整理吧。他们也没法一个一个确认有没有写错。

小Hi：这不正是轮到小Ho你出马的时候了么！

小Ho：哎？？

我们都知道大学的课程是可以自己选择的，每一个学期可以自由选择打算学习的课程。唯一限制我们选课是一些课程之间的顺序关系：有的难度很大的课程可能会有一些前置课程的要求。比如课程A是课程B的前置课程，则要求先学习完A课程，才可以选择B课程。大学的教务收集了所有课程的顺序关系，但由于系统故障，可能有一些信息出现了错误。现在小Ho把信息都告诉你，请你帮小Ho判断一下这些信息是否有误。错误的信息主要是指出现了"课程A是课程B的前置课程，同时课程B也是课程A的前置课程"这样的情况。当然"课程A是课程B的前置课程，课程B是课程C的前置课程，课程C是课程A的前置课程"这类也是错误的。

提示：拓扑排序

### 输入

第1行：1个整数T，表示数据的组数T(1 <= T <= 5)
接下来T组数据按照以下格式：
第1行：2个整数，N,M。N表示课程总数量，课程编号为1..N。M表示顺序关系的数量。1 <= N <= 100,000. 1 <= M <= 500,000
第2..M+1行：每行2个整数，A,B。表示课程A是课程B的前置课程。

### 输出

第1..T行：每行1个字符串，若该组信息无误，输出"Correct"，若该组信息有误，输出"Wrong"。

#### 样例输入

```
2
2 2
1 2
2 1
3 2
1 2
1 3
```

#### 样例输出

```
Wrong
Correct
```

```c
#include <iostream>
#include <vector>
#include <queue>
#include <algorithm>
using namespace std;

bool topo_sort (vector<vector<int>> G, vector<int> indegree) {
    int count = 0;
    queue<int> q;
    for (int i = 1; i < indegree.size(); i++)
        if (indegree[i] == 0) q.push(i);
    while (!q.empty()) {
        int front = q.front();
        count++;
        q.pop();
        for (int i = 0; i < G[front].size(); i++) {
            indegree[G[front][i]]--;
            if (indegree[G[front][i]] == 0) q.push(G[front][i]);
        }
    }
    if (count != indegree.size() - 1) return false;
    else return true;
}

int main(int argc, const char * argv[]) {

    int t, n, m, c1, c2;
    cin >> t;
    while (t--) {
        cin >> n >> m;
        vector<vector<int>> course(n + 1);
        vector<int> indegree(n + 1, 0);
        while (m--) {
            cin >> c1 >> c2;
            indegree[c2]++;
            course[c1].push_back(c2);
        }
        if (topo_sort(course, indegree))
            cout << "Correct" << endl;
        else
            cout << "Wrong" << endl;
    }
    return 0;
}
```