## [【Lintcode】Reverse Words in a String](http://www.lintcode.com/en/problem/reverse-words-in-a-string/#)

Given an input string, reverse the string word by word.

For example,

Given s = "`the sky is blue`",

return "`blue is sky the`".

Clarification

- What constitutes a word?
    A sequence of non-space characters constitutes a word.
- Could the input string contain leading or trailing spaces?
    Yes. However, your reversed string should not contain leading or trailing spaces.
- How about multiple spaces between two words?
    Reduce them to a single space in the reversed string.

```c
class Solution {
public:
    /**
     * @param s : A string
     * @return : A string
     */
    string reverseWords(string s) {
        // write your code here
        if (s.empty()) return s;
        string rev_s;
        removeLeadingSpace(s);
        int pos = s.find(" "), last_pos = -1;
        while (pos != string::npos) {
            reverse(s, last_pos + 1, pos - 1);
            last_pos = pos;
            pos = s.find(" ", pos + 1);
        }
        reverse(s, last_pos + 1, s.length() - 1);
        reverse(s, 0, s.length() - 1);
        removeLeadingSpace(s);
        return s;
    }
private:
    void reverse (string &str, int start, int end) {
        while (start < end) {
            char temp = str[start];
            str[start] = str[end];
            str[end] = temp;
            start++; end--;
        }
    }
    void removeLeadingSpace (string &str) {
        int pos = str.find(" ");
        while (pos == 0) {
            str = str.erase(0, 1);
            pos = str.find(" ");
        }
    }
};
```