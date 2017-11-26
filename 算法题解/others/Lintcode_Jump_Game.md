## [【Lintcode】Jump Game](http://www.lintcode.com/en/problem/jump-game/)

Given an array of non-negative integers, you are initially positioned at the first index of the array.

Each element in the array represents your maximum jump length at that position.

Determine if you are able to reach the last index.

**Notice**

**This problem have two method which is Greedy and Dynamic Programming.**

**The time complexity of Greedy method is O(n).**

**The time complexity of Dynamic Programming method is O(n^2).**

**We manually set the small data set to allow you pass the test in both ways. This is just to let you learn how to use this problem in dynamic programming ways. If you finish it in dynamic programming ways, you can try greedy method to make it accept again.**

Example

A = `[2,3,1,1,4]`, return `true`.

A = `[3,2,1,0,4]`, return `false`.

**自底向上（动态规划）**

定义：`dp[i]` 从起点出发能否达到 `i`

状态方程：

```
dp[i] = dp[j] && j < i && j + A[j] >= i
```

边界条件：`dp[0] = true;`

数据大时会超时

```c
class Solution {
public:
    /**
     * @param A: A list of integers
     * @return: The boolean answer
     */
    bool canJump(vector<int> A) {
        // write you code here
        if (A.empty()) return true;
        int n = A.size();
        vector<bool> dp(n, false);
        dp[0] = true;
        for (int i = 1; i < n; i++) {
            for (int j = i - 1; j >= 0; j--) {
                if (dp[j] && j + A[j] >= i) {
                    dp[i] = true;
                    break;
                }
            }
        }
        return dp[n - 1];
    }
};
```

**自顶向下（贪心）**

```c
class Solution {
public:
    /**
     * @param A: A list of integers
     * @return: The boolean answer
     */
    bool canJump(vector<int> A) {
        // write you code here
        if (A.empty()) return true;
        int index_canJump = A.size() - 1;
        for (int i = A.size() - 1; i >= 0; i--) {
            if (i + A[i] >= index_canJump)
                index_canJump = i;
        }
        return index_canJump == 0;
    }
};
```