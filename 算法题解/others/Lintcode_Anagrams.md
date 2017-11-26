## [【Lintcode】Anagrams](http://www.lintcode.com/en/problem/anagrams/)

Given an array of strings, return all groups of strings that are anagrams.

**Notice**

**All inputs will be in lower-case**

Example

Given `["lint", "intl", "inlt", "code"]`, return `["lint", "inlt", "intl"]`.

Given `["ab", "ba", "cd", "dc", "e"]`, return `["ab", "ba", "cd", "dc"]`.

```c
class Solution {
public:
    /**
     * @param strs: A list of strings
     * @return: A list of strings
     */
    vector<string> anagrams(vector<string> &strs) {
        // write your code here
        map<string, int> hashmap;
        vector<string>result;
        for (int i = 0; i < strs.size(); i++) {
            string str = strs[i];
            sort(str.begin(), str.end());
            hashmap[str]++;
        }
        for (int i = 0; i < strs.size(); i++) {
            string str = strs[i];
            sort(str.begin(), str.end());
            if (hashmap[str] > 1)
                result.push_back(strs[i]);
        }
        return result;
    }
};
```