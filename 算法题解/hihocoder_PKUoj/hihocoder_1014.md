## [【hihocoder】1014 : Trie树](https://hihocoder.com/problemset/problem/1014)

时间限制:10000ms

单点时限:1000ms

内存限制:256MB

### 输入

输入的第一行为一个正整数n，表示词典的大小，其后n行，每一行一个单词（不保证是英文单词，也有可能是火星文单词哦），单词由不超过10个的小写英文字母组成，可能存在相同的单词，此时应将其视作不同的单词。接下来的一行为一个正整数m，表示小Hi询问的次数，其后m行，每一行一个字符串，该字符串由不超过10个的小写英文字母组成，表示小Hi的一个询问。

在20%的数据中n, m<=10，词典的字母表大小<=2.

在60%的数据中n, m<=1000，词典的字母表大小<=5.

在100%的数据中n, m<=100000，词典的字母表大小<=26.

本题按通过的数据量排名哦～

### 输出

对于小Hi的每一个询问，输出一个整数Ans,表示词典中以小Hi给出的字符串为前缀的单词的个数。

#### 样例输入

```
5
babaab
babbbaaaa
abba
aaaaabaa
babaababb
5
babb
baabaaa
bab
bb
bbabbaab
```

#### 样例输出

```
1
0
3
0
0
```

```c
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

struct Node {
    char val;
    int word_num;
    vector<Node*> children;
    Node(): val(NULL), word_num(1) {};
    Node(char c): val(c), word_num(1) {};
};

int get_index_of_child (Node* node, Node* child) {
    for (int i = 0; i < node->children.size(); i++)
        if (node->children[i]->val == child->val) return i;
    return -1;
}

int main(int argc, const char * argv[]) {

    int n, m;
    string word;
    cin >> n;
    Node* trie = new Node();
    Node* cur;
    int child;
    for (int i = 0; i < n; i++) {
        cin >> word;
        cur = trie;
        for (int j = 0; j < word.length(); j++) {
            char c = word[j];
            Node *n = new Node(c);
            child = get_index_of_child(cur, n);
            if (child == -1) {
                cur->children.push_back(n);
                cur = cur->children[cur->children.size() - 1];
            } else {
                cur = cur->children[child];
                cur->word_num++;
            }
        }
    }
    cin >> m;
    for (int i = 0; i < m; i++) {
        cin >> word;
        cur = trie;
        int j = 0;
        for (j = 0; j < word.length(); j++) {
            char c = word[j];
            Node *n = new Node(c);
            child = get_index_of_child(cur, n);
            if (child == -1) {
                break;
            } else {
                cur = cur->children[child];
            }
        }
        if (j < word.length())
            cout << "0" << endl;
        else
            cout << cur->word_num << endl;
    }
    return 0;
}
```