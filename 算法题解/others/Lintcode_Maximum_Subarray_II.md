## [【Lintcode】Maximum Subarray II](http://www.lintcode.com/en/problem/maximum-subarray-ii/)

Given an array of integers, find two non-overlapping subarrays which have the largest sum.

The number in each subarray should be contiguous.
Return the largest sum.

**Notice**

**The subarray should contain at least one number**

Example

For given `[1, 3, -1, 2, -1, 2]`, the two subarrays are `[1, 3]` and `[2, -1, 2]` or `[1, 3, -1, 2]` and `[2]`, they both have the largest sum `7`.

既然已经求出了单一子数组的最大和，那么使用**隔板法**将数组一分为二，分别求这两段的最大子数组和，求相加后的最大值即为最终结果。隔板前半部分的最大子数组和很容易求得；是后半部分采用从后往前的方式进行遍历

```c
class Solution {
public:
    /**
     * @param nums: A list of integers
     * @return: An integer denotes the sum of max two non-overlapping subarrays
     */
    int maxTwoSubArrays(vector<int> nums) {
        // write your code here
        if (nums.size() <= 1) return 0;
        vector<int> max_front(nums.size(), INT_MIN), max_back(nums.size(), INT_MIN);
        int max_sum = INT_MIN, sum = 0;
        for (int i = 0; i < nums.size(); i++) {
            sum = max(sum, 0);
            sum += nums[i];
            max_sum = max(sum, max_sum);
            max_front[i] = max_sum;
        }
        max_sum = INT_MIN, sum = 0;
        for (int i = nums.size() - 1; i >= 0; i--) {
            sum = max(sum, 0);
            sum += nums[i];
            max_sum = max(sum, max_sum);
            max_back[i] = max_sum;
        }
        max_sum = INT_MIN;
        for (int i = 0; i < nums.size() - 1; i++) {
            max_sum = max(max_sum, max_front[i] + max_back[i + 1]);
        }
        return max_sum;
    }
};
```