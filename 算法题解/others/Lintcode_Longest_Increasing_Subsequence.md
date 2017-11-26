## [【Lintcode】Longest Increasing Subsequence](http://www.lintcode.com/en/problem/longest-increasing-subsequence/)

Given a sequence of integers, find the longest increasing subsequence (LIS).

You code should return the length of the LIS.

Clarification
What's the definition of longest increasing subsequence?

- The longest increasing subsequence problem is to find a subsequence of a given sequence in which the subsequence's elements are in sorted order, lowest to highest, and in which the subsequence is as long as possible. This subsequence is not necessarily contiguous, or unique.

- [https://en.wikipedia.org/wiki/Longest_increasing_subsequence](https://en.wikipedia.org/wiki/Longest_increasing_subsequence)

Example

For `[5, 4, 1, 2, 3]`, the LIS is `[1, 2, 3]`, return `3`

For `[4, 2, 4, 5, 3, 7]`, the LIS is `[2, 4, 5, 7]`, return `4`

**定义：**
`dp[i]` 代表 `nums[0:i]` 的 LIS 长度

**状态转移方程：**

```
dp[i] = max{1 + dp[j]} where j < i, nums[j] < nums[i]},
```

```c
class Solution {
public:
    /**
     * @param nums: The integer array
     * @return: The length of LIS (longest increasing subsequence)
     */
    int longestIncreasingSubsequence(vector<int> nums) {
        // write your code here
        if (nums.empty()) return 0;
        vector<int> dp(nums.size(), 1);
        for (int i = 1; i < nums.size(); i++) {
            for (int j = 0; j < i; j++) {
                if (nums[j] < nums[i] && dp[i] < dp[j] + 1)
                    dp[i] = dp[j] + 1;
            }
        }
        return *max_element(dp.begin(), dp.end()); // 注：最后返回的是 dp 数组的最大值，不是最后一个元素
    }
};
```