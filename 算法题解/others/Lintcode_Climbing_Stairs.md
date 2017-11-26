## [【Lintcode】Climbing Stairs](http://www.lintcode.com/en/problem/climbing-stairs/)

You are climbing a stair case. It takes n steps to reach to the top.

Each time you can either climb 1 or 2 steps. In how many distinct ways can you climb to the top?

Example

Given an example `n=3` , `1+1+1=2+1=1+2=3`

return `3`

```c
class Solution {
public:
    /**
     * @param n: An integer
     * @return: An integer
     */
    int climbStairs(int n) {
        // write your code here
        vector<int> dp(n + 1, 1);
        for (int i = 2; i <= n; i++) {
            dp[i] = dp[i - 1] + dp[i - 2];
        }
        return dp[n];
    }
};
```