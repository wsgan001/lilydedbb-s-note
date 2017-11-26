## [【hihocoder】1066 : 无间道之并查集](https://hihocoder.com/problemset/problem/1066)

时间限制:20000ms

单点时限:1000ms

内存限制:256MB

### 输入

每个测试点（输入文件）有且仅有一组测试数据。

每组测试数据的第1行为一个整数N，表示黑叔叔总共进行的操作次数。

每组测试数据的第2~N+1行，每行分别描述黑叔叔的一次操作，其中第i+1行为一个整数op_i和两个由大小写字母组成的字符串Name1_i, Name2_i，其中op_i只可能为0或1，当op_i=0时，表示黑叔叔判定Name1_i和Name2_i是同一阵营的，当op_i=1时，表示黑叔叔希望知道Name1_i和Name2_i是否为同一阵营的。

对于100%的数据，满足N<=10^5, 且数据中所有涉及的人物中不存在两个名字相同的人（即姓名唯一的确定了一个人），对于所有的i，满足Name1_i和Name2_i是不同的两个人。

### 输出

对于每组测试数据，对于黑叔叔每次op_i=1的操作，输出一行，表示查询的结果：如果根据已知信息（即这次操作之前的所有op_i=0的操作），可以判定询问中的两个人是同一阵营的，则输出yes，否则输出no。

#### 样例输入

```
10
0 Steven David
0 Lcch Dzx
1 Lcch Dzx
1 David Dzx
0 Lcch David
0 Frank Dzx
1 Steven Dzx
1 Frank David
0 Steven Dzx
0 Dzx Frank
```

#### 样例输出

```
yes
no
yes
yes
```

```c
#include <iostream>
#include <string>
#include <map>
using namespace std;

map<string, string> father;

string findFather (string name) {
    string root = name;
    while (root != father[root])
        root = father[root];
    string x = name;
    while (root != father[x]) {
        string f = father[x];
        father[x] = root;
        x = f;
    }
    return root;
}

void Union (string name_1, string name_2) {
    string f1 = findFather(name_1);
    string f2 = findFather(name_2);
    if (f1 != f2)
        father[f2] = f1;
}

int main(int argc, const char * argv[]) {

    int n;
    cin >> n;
    int op;
    string name_1, name_2;
    for (int i = 0; i < n; i++) {
        cin >> op >> name_1 >> name_2;
        if (op == 0) {
            if (father.find(name_1) == father.end()) father[name_1] = name_1;
            if (father.find(name_2) == father.end()) father[name_2] = name_2;
            Union(name_1, name_2);
        } else {
            if (findFather(name_1) == findFather(name_2))
                cout << "yes" << endl;
            else
                cout << "no" << endl;
        }
    }

    return 0;
}
```