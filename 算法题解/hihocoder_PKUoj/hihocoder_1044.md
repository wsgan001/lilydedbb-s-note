## [【hihocoder】1044 : 状态压缩·一](https://hihocoder.com/problemset/problem/1044)

时间限制:10000ms

单点时限:1000ms

内存限制:256MB

### 输入

每个测试点（输入文件）有且仅有一组测试数据。

每组测试数据的第一行为三个正整数N、M和Q，意义如前文所述。

每组测试数据的第二行为N个整数，分别为W1到WN，代表每一个位置上的垃圾数目。

对于100%的数据，满足N<=1000, 2<=M<=10,1<=Q<=M, Wi<=100

### 输出

对于每组测试数据，输出一个整数Ans，表示在不发生口角的情况下，乘务员最多可以清扫的垃圾数目。

#### 样例输入

```
5 2 1
36 9 80 69 85
```

#### 样例输出

```
201
```

```c
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int countOne (int n) {
    int c = 0;
    while (n > 0) {
        if (n % 2 == 1) c++;
        n /= 2;
    }
    return c;
}

int main(int argc, const char * argv[]) {

    int n, m, q, t;
    cin >> n >> m >> q;
    vector<int> trash;
    for (int i = 0; i < n; i++) {
        cin >> t;
        trash.push_back(t);
    }
    int len = 1 << m;
    vector<vector<int>> dp(n + 1, vector<int>(len, 0));
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < len; j++) {
            int k = (j & (len / 2 - 1)) << 1; // 不选 trash[i]
            if (countOne(k) <= q)
                dp[i + 1][k] = max(dp[i + 1][k], dp[i][j]);
            k++; // 选 trash[i]
            if (countOne(k) <= q)
                dp[i + 1][k] = max(dp[i + 1][k], dp[i][j] + trash[i]);
        }
    }
    cout << *max_element(dp[n].begin(), dp[n].end()) << endl;
    return 0;
}
```