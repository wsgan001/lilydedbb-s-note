## [【Lintcode】Backpack](http://www.lintcode.com/en/problem/backpack/)

Given n items with size Ai, an integer m denotes the size of a backpack. How full you can fill this backpack?

**Notice**

**You can not divide any item into small pieces.**

Example:

If we have `4` items with size `[2, 3, 5, 7]`, the backpack size is 11, we can select `[2, 3, 5]`, so that the max size we can fill this backpack is `10`. If the backpack size is `12`. we can select `[2, 3, 7]` so that we can fulfill the backpack.

You function should return the max size we can fill in the given backpack.

```c
class Solution {
public:
    /**
     * @param m: An integer m denotes the size of a backpack
     * @param A: Given n items with size A[i]
     * @return: The maximum size
     */
    int backPack(int m, vector<int> A) {
        // write your code here
        int n = A.size();
        vector<vector<int>> dp;
        dp.resize(n + 1);
        for (int i = 0; i < n + 1; i++) {
            dp[i].resize(m + 1);
            fill(dp[i].begin(), dp[i].end(), 0);
        }
        for (int i = 0; i < n; i++) {
            for (int j = 0; j <= m; j++) {
                if (A[i] > j) {
                    dp[i + 1][j] = dp[i][j];
                } else {
                    dp[i + 1][j] = max(dp[i][j], dp[i][j - A[i]] + A[i]);
                }
            }
        }
        return dp[n][m];
    }
};
```