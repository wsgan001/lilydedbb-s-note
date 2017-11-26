# B树

```c
#include <cstdio>
using namespace std;

#define m 3 // B-树的阶
typedef int KeyType;
typedef struct BTNode {
    int keynum; // 结点中关键字的个数
    struct BTNode *parent; // 指向双亲结点
    KeyType key[m + 1]; // 关键字向量，0单元未用
    struct BTNode *ptr[m + 1]; // 子数指针向量
    Record *recptr[m + 1]; // 记录指针响亮，0单元未用
} BTNode, *BTree;

typedef struct {
    BTNode *pt; // 找到的结点
    int i; // 1...m 在结点中的关键字序号
    int tag; // 1: 查找成功；0: 查找失败
} Result;

int Search(BTree p, int K) {
    // 在 p->key[1..keynum] 中查找
    // i使得：p->key[i] <= k < p->key[i + 1]
    for (int i = 1; i < p->keynum; i++) {
        if (K >= p->key[i] && K < p->key[i + 1])
            return i;
    }
    if (K == p->key[p->keynum])
        return p->keynum;
    else
        return -1;
}

Result SearchBTree (BTree T, KeyType K) {
    BTree p = T;
    BTree q = NULL;
    bool found = false;
    int i = 0;
    while (p && !found) {
        i = Search(p, K); // 在 p->key[1..keynum] 中查找
        // i使得：p->key[i] <= k < p->key[i + 1]
        if (i > 0 && p->key[i] == K) {
            found = true;
        } else {
            q = p;
            p = p->ptr[i];
        }
    }
    if (found) {
        return { p, i, 1 };
    } else {
        return { q, i, 0 };
    }
}
```