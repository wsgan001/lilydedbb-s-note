# 哈夫曼树 (Huffman Tree)

```c
#include <cstdio>
#include <stdlib.h>
#include <string.h>
using namespace std;
typedef struct {
    unsigned int weight;
    unsigned int parent, lchild, rchild;
} HTNode, *HuffmanTree;
typedef char* *HuffmanCode;

void Select(HuffmanTree *HT, int n, int &s1, int &s2) {
    // 在 HT[1...i-1] 选择 parent 为 0 且 weight 最小的两个节点，其序号分别为 s1 和 s2
    unsigned int min = HT[1]->weight;
    s1 = 0; s2 = 0;
    for (int i = 1; i <= n; i++) {
        if (HT[i]->weight < min) {
            s2 = s1;
            s1 = i;
        }
    }
}

void HuffmanCoding (HuffmanTree &HT, HuffmanCode &HC, int *w, int n) {
    // w 存放 n 个字符的权值
    if (n <= 1) return;
    int m = 2 * n - 1;
    HT = (HuffmanTree)malloc((m + 1) * sizeof(HTNode)); // 0单元未用
    HuffmanTree p;
    int i;
    for (p = HT, i = 1; i <= n; ++i, ++p, ++w) *p = { *(w + i), 0, 0, 0 };
    for ( ; i <= m; ++i, ++p) *p = { 0, 0, 0, 0 };
    for (i = n + 1; i <= m; ++i) { // 创建哈夫曼树
        // 在 HT[1...i-1] 选择 parent 为 0 且 weight 最小的两个节点，其序号分别为 s1 和 s2
        int s1, s2;
        Select(HT, i - 1, s1, s2);
        HT[s1].parent = i; HT[s2].parent = i;
        HT[i].lchild = s1; HT[i].rchild = s2;
        HT[i].weight = HT[s1].weight + HT[s2].weight;
    }
    HC = (HuffmanCode)malloc((n + 1) * sizeof(char *));
    char *cd = (char *)malloc(n * sizeof(char));
    cd[n - 1] = '\0';
    for (i = 1; i <= n; i++) { // 逐个字符求哈夫曼编码
        int start = n - 1;
        for (int c = i, f = HT[i].parent; f != 0; c = f, f = HT[f].parent) { // 自底向上求哈夫曼编码
            if (HT[f].lchild == c) cd[--start] = '0';
            else cd[--start] = '1';
        }
        HC[i] = (char *)malloc((n - start) * sizeof(char));
        strcpy(HC[i], &cd[start]);
    }
    delete cd;
}
```