## [【hihocoder】1015 : KMP算法](https://hihocoder.com/problemset/problem/1015)

时间限制:1000ms

单点时限:1000ms

内存限制:256MB

### 输入

第一行一个整数N，表示测试数据组数。

接下来的N*2行，每两行表示一个测试数据。在每一个测试数据中，第一行为模式串，由不超过10^4个大写字母组成，第二行为原串，由不超过10^6个大写字母组成。

其中N<=20

### 输出

对于每一个测试数据，按照它们在输入中出现的顺序输出一行Ans，表示模式串在原串中出现的次数。

#### 样例输入

```
5
HA
HAHAHA
WQN
WQN
ADA
ADADADA
BABABB
BABABABABABABABABB
DAD
ADDAADAADDAAADAAD
```

#### 样例输出

```
3
1
3
1
0
```

```c
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

vector<int> getNext (string str) {
    str.append(" ");
    vector<int> next(str.length(), 0);
    int j = -1, i = 0;
    next[0] = -1;
    while (i < str.length()) {
        if (j == -1 || str[i] == str[j]) { i++; j++; next[i] = j; }
        else j = next[j];
    }
    return next;
}

int count (string ori, string tar, vector<int> next) {
    int c = 0;
    int i = 0, j = 0;
    while (i < ori.length()) {
        if (j == -1 || ori[i] == tar[j]) { i++; j++; }
        else { j = next[j]; }
        if (j == tar.length()) {
            j = next[j];
            c++;
        }
    }
    return c;
}

int main(int argc, const char * argv[]) {

    int n, c = 0;
    cin >> n;
    string ori, tar;
    for (int i = 0; i < n; i++) {
        cin >> tar >> ori;
        c = 0;
        vector<int> next = getNext(tar);
        cout << count(ori, tar, next) << endl;
    }
    return 0;
}
```