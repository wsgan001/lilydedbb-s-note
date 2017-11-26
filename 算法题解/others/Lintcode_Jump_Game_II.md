## [【Lintcode】Jump Game II](http://www.lintcode.com/en/problem/jump-game-ii/)

Given an array of non-negative integers, you are initially positioned at the first index of the array.

Each element in the array represents your maximum jump length at that position.

Your goal is to reach the last index in the minimum number of jumps.

Example

Given array A = `[2,3,1,1,4]`

The minimum number of jumps to reach the last index is 2. (Jump 1 step from index 0 to 1, then 3 steps to the last index.)

**解法一：自顶向下-动态规划**

定义：`dp[i]` 从起点跳到这个位置最少需要多少步

状态转移方程:

```
dp[i] = min{dp[j] + 1, j < i && j + A[j] >= i}
```

下面代码部分数据超时，只通过77%的数据

```c
// 自顶向下-动态规划
class Solution {
public:
    /**
     * @param A: A list of lists of integers
     * @return: An integer
     */
    int jump(vector<int> A) {
        // wirte your code here
        vector<int> dp(A.size(), INT_MAX);
        dp[0] = 0;
        for (int i = 1; i < A.size(); i++) {
            for (int j = 0; j < i; j++) {
                if (dp[j] != INT_MAX && j + A[j] >= i) {
                    dp[i] = dp[j] + 1;
                    break;
                }
            }
        }
        return dp[A.size() - 1];
    }
};
```

**解法二：贪心法-自底向上**

```c
class Solution {
public:
    /**
     * @param A: A list of lists of integers
     * @return: An integer
     */
    int jump(vector<int> A) {
        // wirte your code here
        int farthest = 0, start = 0, end = 0;
        int jump = 0;
        while (end < A.size() - 1) {
            for (int i = start; i <= end; i++)
                if (i + A[i] > farthest) farthest = i + A[i];
            if (end < farthest) {
                jump++;
                start = end + 1;
                end = farthest;
            } else {
                return -1;
            }
        }
        return jump;
    }
};
```