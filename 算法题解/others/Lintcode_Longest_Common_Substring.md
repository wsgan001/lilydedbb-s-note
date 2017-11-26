## [【Lintcode】Longest Common Substring](http://www.lintcode.com/en/problem/longest-common-substring/)

Given two strings, find the longest common substring.

Return the length of it.

**Notice**

**The characters in substring should occur continuously in original string. This is different with subsequence.**

Example

Given A = "`ABCD`", B = "`CBCE`", return `2`.

```c
class Solution {
public:
    /**
     * @param A, B: Two string.
     * @return: the length of the longest common substring.
     */
    int longestCommonSubstring(string &A, string &B) {
        // write your code here
        int lcs = 0, m = 0;
        for (int i = 0; i < A.length(); i++) {
            for (int j = 0; j < B.length(); j++) {
                lcs = 0;
                while (i + lcs < A.length() && j + lcs < B.length() && A[i + lcs] == B[j + lcs])
                    lcs++;
                if (lcs > m) m = lcs;
            }
        }
        return m;
    }
};
```