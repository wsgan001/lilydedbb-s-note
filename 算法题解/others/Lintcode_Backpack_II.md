## [【Lintcode】Backpack II](http://www.lintcode.com/en/problem/backpack-ii/)

Given n items with size Ai and value Vi, and a backpack with size m. What's the maximum value can you put into the backpack?

**Notice**

**You cannot divide item into small pieces and the total size of items you choose should smaller or equal to m.**

Example

Given `4` items with size `[2, 3, 5, 7]` and value `[1, 5, 2, 4]`, and a backpack with size `10`. The maximum value is `9`.

```c
class Solution {
public:
    /**
     * @param m: An integer m denotes the size of a backpack
     * @param A & V: Given n items with size A[i] and value V[i]
     * @return: The maximum value
     */
    int backPackII(int m, vector<int> A, vector<int> V) {
        // write your code here
        if (A.empty() || V.empty() || m == 0) return 0;
        vector<vector<int>> dp;
        int n = A.size();
        dp.resize(n + 1);
        for (int i = 0; i < n + 1; i++) {
            dp[i].resize(m + 1);
            fill(dp[i].begin(), dp[i].end(), 0);
        }
        for (int i = 0; i < n; i++) {
            for (int j = 1; j <= m; j++) {
                if (A[i] > j) {
                    dp[i + 1][j] = dp[i][j];
                } else {
                    dp[i + 1][j] = max(dp[i][j], dp[i][j - A[i]] + V[i]);
                }
            }
        }
        return dp[n][m];
    }
};
```