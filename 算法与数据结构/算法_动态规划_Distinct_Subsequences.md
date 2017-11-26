# 动态规划 —— Distinct Subsequences

## [【leetcode】115. Distinct Subsequences](https://leetcode.com/problems/distinct-subsequences/#/description)

Given a string S and a string T, count the number of distinct subsequences of S which equals T.

A subsequence of a string is a new string which is formed from the original string by deleting some (can be none) of the characters without disturbing the relative positions of the remaining characters. (ie, "`ACE`" is a subsequence of "`ABCDE`" while "`AEC`" is not).

Here is an example:
S = "`rabbbit`", T = "`rabbit`"

Return `3`.

### 定义

`dp[i][j]` 表示 `s[0:i)` 和 `t[0:j)` 的 Distinct Subsequences 数量

### 状态转移方程：

```
dp[i+1][j+1] = dp[i][j+1] + dp[i][j] (if S[i] == T[j])
dp[i+1][j+1] = dp[i][j+1] (if S[i] != T[j])
边界：dp[i][0] = 1;
```

```c
class Solution {
public:
    int numDistinct(string s, string t) {
        if (s.length() < t.length()) return 0;
        if (t.empty()) return 1;

        // dp[i][j] 表示 s[0:i) 和 t[0:j) 的 Distinct Subsequences 数量
        vector<vector<int>> dp(s.length() + 1, vector<int>(t.length() + 1, 0));

        int i = 0, j = 0;
        for (int i = 0; i < s.length(); i++) {
            dp[i][0] = 1;
            for (int j = 0; j < t.length(); j++) {
                if (s[i] == t[j]) {
                    dp[i + 1][j + 1] = dp[i][j + 1] + dp[i][j];
                } else {
                    dp[i + 1][j + 1] = dp[i][j + 1];
                }
            }
        }
        return dp[s.length()][t.length()];
    }
};
```