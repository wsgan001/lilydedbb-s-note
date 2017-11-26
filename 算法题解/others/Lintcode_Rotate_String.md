## [【Lintcode】Rotate String](http://www.lintcode.com/en/problem/rotate-string/)

Given a string and an offset, rotate string by offset. (rotate from left to right)

Example

Given "`abcdefg`".

offset=0 => "`abcdefg`"

offset=1 => "`gabcdef`"

offset=2 => "`fgabcde`"

offset=3 => "`efgabcd`"


```c
class Solution {
public:
    /**
     * @param str: a string
     * @param offset: an integer
     * @return: nothing
     */
    void rotateString(string &str,int offset){
        //wirte your code here
        if (str.empty()) return;
        int len = str.length();
        offset %= len;
        reverse(str, len - offset, len - 1);
        reverse(str, 0, len - offset - 1);
        reverse(str, 0, len - 1);
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
};
```