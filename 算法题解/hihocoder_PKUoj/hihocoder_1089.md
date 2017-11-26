## [【hihocoder】1089 : 最短路径·二：Floyd算法](https://hihocoder.com/problemset/problem/1089)

### 输入

每个测试点（输入文件）有且仅有一组测试数据。

在一组测试数据中：

第1行为2个整数N、M，分别表示鬼屋中地点的个数和道路的条数。

接下来的M行，每行描述一条道路：其中的第i行为三个整数u_i, v_i, length_i，表明在编号为u_i的地点和编号为v_i的地点之间有一条长度为length_i的道路。

对于100%的数据，满足N<=10^2，M<=10^3, 1 <= length_i <= 10^3。

对于100%的数据，满足迷宫中任意两个地点都可以互相到达。

### 输出

对于每组测试数据，输出一个N*N的矩阵A，其中第i行第j列表示，从第i个地点到达第j个地点的最短路径的长度，当i=j时这个距离应当为0。

#### 样例输入

```
5 12
1 2 967
2 3 900
3 4 771
4 5 196
2 4 788
3 1 637
1 4 883
2 4 82
5 2 647
1 4 198
2 4 181
5 2 665
```

#### 样例输出

```
0 280 637 198 394
280 0 853 82 278
637 853 0 771 967
198 82 771 0 196
394 278 967 196 0
```

```c
#include <iostream>
#include <vector>
#include <algorithm>
#include <climits>
using namespace std;
vector<vector<int>> dis;

void Floyd (vector<vector<int>> &dis) {
    for (int i = 1; i < dis.size(); i++) {
        for (int j = 1; j < dis.size(); j++) {
            for (int k = 1; k < dis.size(); k++) {
                if (i != j && j != k && i != k &&
                    dis[i][k] < INT_MAX && dis[k][j] < INT_MAX)
                    dis[i][j] = min(dis[i][j], dis[i][k] + dis[k][j]);
            }
        }
    }
}

int main(int argc, const char * argv[]) {

    int n, m;
    int u, v, len;
    cin >> n >> m;
    vector<vector<int>> dis(n + 1, vector<int>(n + 1, INT_MAX));
    for (int i = 0; i < m; i++) {
        cin >> u >> v >> len;
        dis[u][v] = min(dis[u][v], len);
        dis[v][u] = dis[u][v];
    }
    for (int i = 1; i < dis.size(); i++) dis[i][i] = 0;
    Floyd(dis);
    for (int i = 1; i < dis.size(); i++) {
        for (int j = 1; j < dis.size(); j++) {
            cout << dis[i][j] << " ";
        }
        cout << endl;
    }

    return 0;
}
```