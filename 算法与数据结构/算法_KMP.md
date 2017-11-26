# 模式匹配 ——KMP算法

未经优化的模式匹配算法：

```c
int Index (string s, string t, int pos) {
    int i = pos, j = 0;
    while (i < s.length() && j < t.length()) {
        if (s[i] == t[j]) {
            i++; j++;
        } else {
            i = i - j + 1;
            j = 0;
        }
    }
    if (j == t.length())
        return i - t.length();
    else
        return -1;
}
```

### KMP算法：

**令 `next[j] = k`，则 `next[j]` 表明当模式中第j个字符与主串中相应自负“失配”时，在模式中需要重新和主串中该字符进行比较的字符的位置**

`next [j] = k`，代表 `j` 之前的字符串中有最大长度为 `k` 的相同前缀后缀

由定义：

```
next[0] = 0;
```

设 `next[j] = k`，则模式串中存在下列关系：

```
p[0] ··· p[k - 1] = p[j - k] ···· p[j - 1]
```

- 若 `p[k] == p[j]`，则表明模式串中：

    ```
    p[0] ··· p[k] == p[j - k] ···· p[j]
    ```

    则 `next[j + 1] = k + 1`，即：

    ```
    next[j + 1] = next[j] + 1
    ```
- 若 `p[k] != p[j]`，则表明模式串中：

    ```
    p[0] ··· p[k] != p[j - k] ···· p[j]
    ```

    若 `next[k] = k' && p[j] = p[k']` 则 `next[j + 1] = k' + 1`，即：

    ```
    next[j + 1] = next[k] + 1
    ```

**获得模式串的 `next` 数组：**

```c
void get_next (string s, int* next) {
    int i = 0, j = -1;
    next[0] = -1;
    while (i < s.length()) {
        if (j == -1 || s[i] == s[j]) { i++; j++; next[i] = j; }
        else j = next[j];
    }
}
```

如 `"abaabc"` 的 next 数组为：`[-1, 0, 0, 1, 1, 2]`


**基于 `next` 数组的模式匹配：**

```c
int Index (string s, string t, int pos) {
    int i = pos, j = 0;
    int t_len = (int)t.length();
    int next[t_len];
    get_next(t, next);
    while (i < (int)s.length() && j < (int)t.length()) {
        if (j == -1 || s[i] == t[j]) {
            i++; j++;
        } else {
            j = next[j];
        }
    }
    if (j == t.length())
        return i - (int)t.length();
    else
        return -1;
}
```

完整示例：

```c
#include<cstdio>
#include<string>
using namespace std;

void get_next (string s, int* next) {
    int i = 0, j = -1;
    next[0] = -1;
    while (i < s.length()) {
        if (j == -1 || s[i] == s[j]) { i++; j++; next[i] = j; }
        else j = next[j];
    }
}

int Index (string s, string t, int pos) {
    int i = pos, j = 0;
    int t_len = (int)t.length();
    int next[t_len];
    get_next(t, next);
    while (i < (int)s.length() && j < (int)t.length()) {
        if (j == -1 || s[i] == t[j]) {
            i++; j++;
        } else {
            j = next[j];
        }
    }
    if (j == t.length())
        return i - (int)t.length();
    else
        return -1;
}

int main () {
    string s = "acabaabaabcacaabc";
    string t = "abaabc";
    printf("%d", Index(s, t, 0)); // 5
    return 0;
}
```


### 改进 `get_next()` 函数

```c
void get_next (string s, int* next) {
    int i = 0, j = -1;
    next[0] = -1;
    while (i < s.length()) {
        if (j == -1 || s[i] == s[j]) {
            i++; j++;
            if (s[i] != s[j]) next[i] = j;
            else next[i] = next[j];
        }
        else j = next[j];
    }
}
```
