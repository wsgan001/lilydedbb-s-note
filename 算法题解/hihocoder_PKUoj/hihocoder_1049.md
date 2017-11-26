## [【hihocoder】1049 : 后序遍历](https://hihocoder.com/problemset/problem/1049)

时间限制:10000ms

单点时限:1000ms

内存限制:256MB

### 输入

每个测试点（输入文件）有且仅有一组测试数据。

每组测试数据的第一行为一个由大写英文字母组成的字符串，表示该二叉树的前序遍历的结果。

每组测试数据的第二行为一个由大写英文字母组成的字符串，表示该二叉树的中序遍历的结果。

对于100%的数据，满足二叉树的节点数小于等于26。

### 输出

对于每组测试数据，输出一个由大写英文字母组成的字符串，表示还原出的二叉树的后序遍历的结果。

#### 样例输入

```
AB
BA
```

#### 样例输出

```
BA
```

```c
#include <iostream>
#include <string>
using namespace std;

struct Node {
    char val;
    Node *left, *right;
    Node(char c): val(c), left(NULL), right(NULL) {};
};

Node* buildTree (char *pre, char *in, int len) {
    if (len == 0) return NULL;
    Node* root = new Node(pre[0]);
    int i = 0;
    for ( ; i < len; i++) if (in[i] == pre[0]) break;
    root->left = buildTree(pre + 1, in, i);
    root->right = buildTree(pre + i + 1, in + i + 1, len - i - 1);
    return root;
}

void postOrder (Node* root) {
    if (root->left) postOrder(root->left);
    if (root->right) postOrder(root->right);
    cout << root->val;
}

int main(int argc, const char * argv[]) {

    string line;
    cin >> line;
    int len = line.length();
    char pre[len], in[len];
    for (int i = 0; i < len; i++) pre[i] = line[i];
    cin >> line;
    for (int i = 0; i < len; i++) in[i] = line[i];

    Node* root = buildTree(pre, in, len);
    postOrder(root);

    return 0;
}
```