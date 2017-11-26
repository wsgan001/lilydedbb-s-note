## [【Lintcode】Longest Increasing Continuous Subsequence](http://www.lintcode.com/en/problem/longest-increasing-continuous-subsequence/)

Give an integer array，find the longest increasing continuous subsequence in this array.

An increasing continuous subsequence:

- Can be from right to left or from left to right.
- Indices of the integers in the subsequence should be continuous.

**Notice**

**`O(n)` time and `O(1)` extra space.**

Example

For `[5, 4, 2, 1, 3]`, the LICS is `[5, 4, 2, 1]`, return `4`.

For `[5, 1, 2, 3, 4]`, the LICS is `[1, 2, 3, 4]`, return `4`.

`dp[i]` 代表以 `A[i]` 结尾的 `LICS` 长度

```c
class Solution {
public:
    /**
     * @param A an array of Integer
     * @return  an integer
     */
    int longestIncreasingContinuousSubsequence(vector<int>& A) {
        // Write your code here
        if (A.empty()) return 0;
        vector<int> dp(A.size(), 0);
        dp[0] = 1;
        for (int i = 1; i < A.size(); i++) {
            if (dp[i - 1] <= 1) { dp[i] = dp[i - 1] + 1; continue; }
            if ((A[i] > A[i - 1] && A[i - 1] > A[i - 2]) ||
                (A[i] < A[i - 1] && A[i - 1] < A[i - 2]))
                dp[i] = dp[i - 1] + 1;
            else
                dp[i] = 2;
        }
        return *max_element(dp.begin(), dp.end());
    }
};
```
