# BST (Binary Sort Tree)

二叉查找树（Binary Search Tree）:

- 若任意节点的左子树不空，则左子树上所有结点的值均小于它的根结点的值
- 若任意节点的右子树不空，则右子树上所有结点的值均大于它的根结点的值
- 任意节点的左、右子树也分别为二叉查找树
- 没有键值相等的节点


在二叉搜索树b中查找x的过程为：

- 若`b`是空树，则搜索失败，否则：
- 若`x`等于`b`的根节点的数据域之值，则查找成功；否则：
- 若`x`小于`b`的根节点的数据域之值，则搜索左子树；否则：
- 查找右子树


向一个二叉搜索树`b`中插入一个节点`s`的算法，过程为：

- 若b是空树，则将`s`所指结点作为根节点插入，否则：
- 若`s->data`等于`b`的根节点的数据域之值，则返回，否则：
- 若`s->data`小于`b`的根节点的数据域之值，则把`s`所指节点插入到左子树中，否则：
- 把`s`所指节点插入到右子树中。（新插入节点总是叶子节点）


在二叉查找树删去一个结点，分三种情况讨论：

- 若`*p`结点为叶子结点，即PL（左子树）和PR（右子树）均为空树。由于删去叶子结点不破坏整棵树的结构，则只需修改其双亲结点的指针即可
- 若`*p`结点只有左子树PL或右子树PR，此时只要令PL或PR直接成为其双亲结点`*f`的左子树（当`*p`是左子树）或右子树（当`*p`是右子树）即可，作此修改也不破坏二叉查找树的特性
- 若`*p`结点的左子树和右子树均不空。在删去`*p`之后，为保持其它元素之间的相对位置不变，可按中序遍历保持有序进行调整，可以有两种做法：
    - 其一是令`*p`的左子树为`*f`的左/右（依`*p`是`*f`的左子树还是右子树而定）子树，`*s`为`*p`左子树的最右下的结点，而`*p`的右子树为`*s`的右子树
    - 其二是令`*p`的直接前驱（in-order predecessor）或直接后继（in-order successor）替代`*p`，然后再从二叉查找树中删去它的直接前驱（或直接后继）

```c
#include <cstdio>
using namespace std;
struct tNode {
    int data;
    tNode *lchild, *rchild;
};

tNode* newNode (int data) {
    tNode *node = new tNode;
    node->data = data;
    node->lchild = node->rchild = NULL;
    return node;
}

void insert (tNode* &root, int v) {
    if (root == NULL) {
        root = newNode(v);
        return;
    }
    if (v < root->data) {
        insert(root->lchild, v);
    } else {
        insert(root->rchild, v);
    }
}

void search (tNode* root, int x) {
    if (root == NULL) { // 空树，即没有找到对应节点
        printf("search failed\n");
        return;
    }
    if (x == root->data) {
        printf("%d\n", root->data);
    } else if (x < root->data) {
        search(root->lchild, x);
    } else {
        search(root->rchild, x);
    }
}

tNode* createBST (vector<int> data) {
    tNode *root = NULL;
    for (int i = 0; i < data.size(); i++) {
        insert(root, data[i]);
    }
    return root;
}

bool Delete (tNode* root) {
    if (root->lchild == NULL && root->rchild == NULL) {
        delete root;
    } else if (root->lchild == NULL) {
        tNode* temp = root->rchild;
        root = root->rchild;
        delete temp;
    } else if (root->rchild == NULL) {
        tNode* temp = root->lchild;
        root = root->lchild;
        delete temp;
    } else {
        tNode* temp = root;
        tNode* pre = root->lchild;
        while (pre->rchild) {
            temp = pre;
            pre = pre->rchild;
        }
        root->data = pre->data; // pre 为root左子树中序遍历的最后一个元素，即root的前驱
        // temp 为root的前驱的父节点
        if (temp != root)
            temp->rchild = pre->lchild; // 重接*temp的右子树
        else
            temp->lchild = pre->lchild; // 重接*temp的左子树
        delete pre;
    }
    return true;
};

bool deleteBST (tNode* root, int x) {
    if (!root) {
        return false;
    } else {
        if (x == root->data) {
            return Delete(root);
        } else if (x < root->data) {
            return deleteBST(root->lchild, x);
        } else {
            return deleteBST(root->rchild, x);
        }
    }
}

int main (int argc, const char * argv[]) {
    int N, v;
    scanf("%d", &N);
    vector<int> data;
    for (int i = 0; i < N; i++) {
        scanf("%d", &v);
        data.push_back(v);
    }

    tNode* root = createBST(data);

    printf("%d\n", root->data);

    return 0;
}
```