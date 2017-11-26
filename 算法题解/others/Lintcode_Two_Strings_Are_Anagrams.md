## [【Lintcode】Two Strings Are Anagrams](http://www.lintcode.com/en/problem/two-strings-are-anagrams/)

Write a method `anagram(s,t)` to decide if two strings are anagrams or not.

Clarification
What is Anagram?

- Two strings are anagram if they can be the same after change the order of characters.

Example

Given s = "`abcd`", t = "`dcab`", return `true`.

Given s = "`ab`", t = "`ab`", return `true`.

Given s = "`ab`", t = "`ac`", return `false`.

解法一：统计字频

```c
class Solution {
public:
    /**
     * @param s: The first string
     * @param b: The second string
     * @return true or false
     */
    bool anagram(string s, string t) {
        if (s.length() != t.length()) return false;
        int letter_count[256] = {0};
        for (int i = 0; i < s.length(); i++) {
            letter_count[s[i]]++;
            letter_count[t[i]]--;
        }
        for (int i = 0; i < 256; i++)
            if (letter_count[i] != 0) return false;
        return true;
    }
};
```

解法二：排序字符串

```c
class Solution {
public:
    /**
     * @param s: The first string
     * @param b: The second string
     * @return true or false
     */
    bool anagram(string s, string t) {
        if (s.length() != t.length()) return false;
        sort(s.begin(), s.end());
        sort(t.begin(), t.end());
        for (int i = 0; i < s.length(); i++) {
            if (s[i] != t[i]) return false;
        }
        return true;
    }
};
```