## [【hihocoder】1048 : 状态压缩·二](https://hihocoder.com/problemset/problem/1048)

时间限制:10000ms

单点时限:1000ms

内存限制:256MB

### 输入

每个测试点（输入文件）有且仅有一组测试数据。

每组测试数据的第一行为两个正整数N、M，表示小Hi和小Ho拿到的盘子的大小。

对于100%的数据，满足2<=N<=1000, 3<=m<=5。<>

### 输出

考虑到总的方案数可能非常大，只需要输出方案数除以1000000007的余数。



#### 样例输入

```
2 4
```

#### 样例输出

```
5
```

```c
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

bool check(int num) {
    while (num) {
        if (num & 1) {
            if ((num >> 1) & 1)
                num >>= 2;
            else
                return false;
        } else {
            num >>= 1;
        }
    }
    return true;
}

int main(int argc, const char * argv[]) {

    int n, m;
    cin >> n >> m;
    vector<vector<long long>> dp(2, vector<long long>(1 << m));
    vector<bool> full(1 << m, false);
    for (int i = 0; i < (1 << m); i++) {
        if (check(i)) {
            full[i] = true;
            dp[0][i] = 1;
        }
    }
    for (int i = 1; i <= n; i++) {
        fill(dp[i & 1].begin(), dp[i & 1].end(), 0);
        for (int j = 0; j < (1 << m); j++) {
            for (int k = 0; k < (1 << m); k++) {
                if ((j | k) == (1 << m) - 1 || full[j & k]) {
                    dp[i & 1][j] += dp[(i - 1) & 1][k];
                    dp[i & 1][j] %= 1000000007;
                }
            }
        }
    }
    cout << dp[(n-1) & 1][(1 << m) -1] << endl;
    return 0;
}
```