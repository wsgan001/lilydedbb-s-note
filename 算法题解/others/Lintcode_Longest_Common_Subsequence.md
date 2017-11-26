## [【Lintcode】Longest Common Subsequence](http://www.lintcode.com/en/problem/longest-common-subsequence/)

Given two strings, find the longest common subsequence (LCS).

Your code should return the length of LCS.

Clarification

What's the definition of Longest Common Subsequence?

- [https://en.wikipedia.org/wiki/Longest_common_subsequence_problem](https://en.wikipedia.org/wiki/Longest_common_subsequence_problem)
- [http://baike.baidu.com/view/2020307.htm](http://baike.baidu.com/view/2020307.htm)

Example

For `"ABCD"` and `"EDCA"`, the LCS is `"A"` (or `"D"`, `"C"`), return `1`.

For `"ABCD"` and `"EACB"`, the LCS is `"AC"`, return `2`.

**定义：**

`dp[i][j]` 为 `A[0:i)` 和 `B[0:j)` 的 LCS 长度

**状态方程：**

```
if (A[i] == B[j])
    dp[i + 1][j + 1] = dp[i][j] + 1;
else
    dp[i + 1][j + 1] = max(dp[i + 1][j], dp[i][j + 1]);
```

```c
class Solution {
public:
    /**
     * @param A, B: Two strings.
     * @return: The length of longest common subsequence of A and B.
     */
    int longestCommonSubsequence(string A, string B) {
        // write your code here
        vector<vector<int>> dp(A.length() + 1, vector<int>(B.length() + 1));
        for (int i = 0; i < A.length() + 1; i++) dp[i][0] = 0;
        for (int i = 0; i < B.length() + 1; i++) dp[0][i] = 0;
        for (int i = 0; i < A.length(); i++) {
            for (int j = 0; j < B.length(); j++) {
                if (A[i] == B[j])
                    dp[i + 1][j + 1] = dp[i][j] + 1;
                else
                    dp[i + 1][j + 1] = max(dp[i + 1][j], dp[i][j + 1]);
            }
        }
        return dp[A.length()][B.length()];
    }
};
```
