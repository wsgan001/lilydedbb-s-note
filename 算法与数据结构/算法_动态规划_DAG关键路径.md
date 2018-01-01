# 动态规划 —— DAG 关键路径

```c
// n 为顶点数
int DP (int i) {
    if (dp[i] > 0) return dp[i];
    for (int j = 0; j < n; j++) {
        if (G[i][j] != INT_MAX) {
            dp[i] = max(dp[i], dp[j] + G[i][j]);
        }
    }
    return dp[i];
}
```
