# 动态规划（Dynamic Programming）


## 动态规划的递归写法

求 Fibonacci 数列的传统递归写法：

```c
int F (int n) {
    if (n == 0 || n == 1) return 1;
    else return F(n - 1) + F(n - 2);
}
```

但是传统的递归写法，由于没有保存中间计算的结果，实际的时间复杂度达到 `O(2^n)`

动态规划的递归写法：

```c
int F (int n) {
    if (n == 0 || n == 1) return 1;
    if (dp[n] != -1) {
        return dp[n];
    } else {
        dp[n] = F(n - 1) + F(n - 2);
        return dp[n];
    }
}
```


## 动态规划的递推写法

以经典的 [120. Triangle](https://leetcode.com/problems/triangle/#/description) 题目为例：


- 自底向上：（`dp[i][j]` 表示 从 `(i, j)` 到达底部的最小路程）

状态方程：

```
dp[i][j] = min(dp[i + 1][j], dp[i + 1][j + 1]) + triangle[i][j];
```

边界条件：

```
dp[n][j] = triangle[n][j]; (1 <= j <= n)
```

```c
// From Bottom to Top
class Solution {
public:
    int minimumTotal(vector<vector<int>>& triangle) {
        if (triangle.empty()) return -1;
        int n = triangle.size();
        vector<vector<int>> dp(triangle);
        // for (int i = 0; i < n; i++) {
        //     dp[n - 1][i] = triangle[n - 1][i];
        // }
        for (int i = n - 2; i >= 0; i--) {
            for (int j = 0; j <= i; j++) {
                dp[i][j] = min(dp[i + 1][j], dp[i + 1][j + 1]) + triangle[i][j];
            }
        }
        return dp[0][0];
    }
};
```


- 自顶向下：（`dp[i][j]` 表示 从 `(0, 0)` 到达 `(i, j)` 的最小路程）

状态方程：

```
dp[i][j] = min(dp[i - 1][j - 1], dp[i - 1][j]) + triangle[i][j];
```

边界条件：

```
dp[0][0] = triangle[0][0];
```

```c
// From Top to Bottom
class Solution {
public:
    int minimumTotal(vector<vector<int>>& triangle) {
        if (triangle.empty()) return -1;
        int n = triangle.size();
        vector<vector<int>> dp(triangle);
        for (int i = 1; i < n; i++) {
            for (int j = 0; j <= i; j++) {
                if (j == 0) dp[i][j] = dp[i - 1][0];
                else if (j == i) dp[i][j] = dp[i - 1][j - 1];
                else dp[i][j] = min(dp[i - 1][j - 1], dp[i - 1][j]);
                dp[i][j] += triangle[i][j];
            }
        }
        int min = dp[n - 1][0];
        for (int i = 1; i < n; i++) {
            if (min > dp[n - 1][i]) min = dp[n - 1][i];
        }
        return min;
    }
};
```