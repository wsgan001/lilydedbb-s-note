## [【hihocoder】1037 : 数字三角形](https://hihocoder.com/problemset/problem/1037)

时间限制:10000ms

单点时限:1000ms

内存限制:256MB

### 输入

每个测试点（输入文件）有且仅有一组测试数据。

每组测试数据的第一行为一个正整数n,表示这个迷宫的层数。

接下来的n行描述这个迷宫中每个房间的奖券数，其中第i行的第j个数代表着迷宫第i层的编号为j的房间中的奖券数量。

测试数据保证，有100%的数据满足n不超过100

对于100%的数据，迷宫的层数n不超过100

对于100%的数据，每个房间中的奖券数不超过1000

对于50%的数据，迷宫的层数不超过15（小Ho表示2^15才3万多呢，也就是说……）

对于10%的数据，迷宫的层数不超过1（小Hi很好奇你的边界情况处理的如何？~）

对于10%的数据，迷宫的构造满足：对于90%以上的结点，左边道路通向的房间中的奖券数比右边道路通向的房间中的奖券数要多。

对于10%的数据，迷宫的构造满足：对于90%以上的结点，左边道路通向的房间中的奖券数比右边道路通向的房间中的奖券数要少。

### 输出

对于每组测试数据，输出一个整数Ans，表示小Ho可以获得的最多奖券数。

#### 样例输入

```
5
2
6 4
1 2 8
4 0 9 6
6 5 5 3 6
```

#### 样例输出

```
28
```

```c
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main(int argc, const char * argv[]) {

    int n, reward;
    cin >> n;
    vector<vector<int>> dp(n, vector<int>(n));
    for (int i = 0; i < n; i++) {
        for (int j = 0; j <= i; j++) {
            cin >> reward;
            if (i > 0) {
                if (j == 0)
                    dp[i][j] = dp[i - 1][j] + reward;
                else if (j == i)
                    dp[i][j] = dp[i - 1][j - 1] + reward;
                else
                    dp[i][j] = max(dp[i - 1][j - 1], dp[i - 1][j]) + reward;
            } else {
                dp[i][j] = reward;
            }
        }
    }
    cout << *max_element(dp[n - 1].begin(), dp[n - 1].end()) << endl;
    return 0;
}
```