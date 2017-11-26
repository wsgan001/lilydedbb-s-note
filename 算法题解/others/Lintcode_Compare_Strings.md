## [【Lintcode】Compare Strings](http://www.lintcode.com/en/problem/compare-strings/)

Compare two strings A and B, determine whether A contains all of the characters in B.

The characters in string A and B are all Upper Case letters.

**Notice**

**The characters of B in A are not necessary continuous or ordered.**

Example

For A = "`ABCD`", B = "`ACD`", return true.

For A = "`ABCD`", B = "`AABC`", return false.

```c
class Solution {
public:
    /**
     * @param A: A string includes Upper Case letters
     * @param B: A string includes Upper Case letter
     * @return:  if string A contains all of the characters in B return true
     *           else return false
     */
    bool compareStrings(string A, string B) {
        // write your code here
        if (A.length() < B.length()) return false;
        int hashmap[26] = {0};
        for (int i = 0; i < A.length(); i++) hashmap[A[i] - 'A']++;
        for (int i = 0; i < B.length(); i++) {
            hashmap[B[i] - 'A']--;
            if (hashmap[B[i] - 'A'] < 0) return false;
        }
        return true;
    }
};
```
