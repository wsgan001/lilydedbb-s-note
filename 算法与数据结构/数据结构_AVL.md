# AVL树

> 在计算机科学中，AVL树是最先发明的自平衡二叉查找树。在AVL树中任何节点的两个子树的高度最大差别为一，所以它也被称为高度平衡树。查找、插入和删除在平均和最坏情况下都是O（log n）。增加和删除可能需要通过一次或多次树旋转来重新平衡这个树。

### 左旋

```
·    A                A                       B             B
·   / \              / |                    /  |           / \
·  /   \            /  |                  /    |          /   \
· C     B    -->   C   |  B      -->    A      |  -->    A     E
·      / \             | / \           / \     |        / \
·     /   \            |/   \         /   \    |       /   \
·    D     E           D     E       C     D   E      C     D
```

### 右旋

```
·      A              A           B                B
·     / \             |\         | \              / \
·    /   \            | \        |   \           /   \
·   B     C -->    B  |  C -->   |     A    --> D     A
·  / \            / \ |          |    / \            / \
· /   \          /   \|          |   /   \          /   \
·D     E        D     E          D  E     C        E     C
```

### 插入节点

插入节点时，节点的平衡因子的绝对值，即左右子树的高度差可能会超过1，即出现不平衡的现象，此时分为四种情况，通过左右旋转可将其转变为平衡

1. LL型

```
·        A                   B
·       / \     Right       / \
·      B   D    Rotate     /   \
·     / \      -------->  C     A
·    C   E               / \   / \
·   / \                 /   \ /   \
·  F   G               F     GE    D
```

2. RR型

```
·   A                       B
·  / \        Left         / \
· D   B       Rotate      /   \
·    / \     --------->  A     C
·   E   C               / \   / \
·      / \             /   \ /   \
·     F   G           D     EF    G
```

3. LR型

```
·   LR型                LL型
·    A                   A                   C
·   / \    Left         / \      Right      / \
·  B   D   Rotate      C   D     Rotate    /   \
· / \     -------->   / \       --------> B     A
·E   C               B   G               / \   / \
·   / \             / \                 /   \ /   \
·  F   G           E   F               E     FG    D
```

4. RL型

```
·   RL型               RR型
·    A                   A                     C
·   / \      Right      / \        Left       / \
·  D   B     Rotate    D   C      Rotate     /   \
·     / \   -------->     / \    -------->  A     B
·    C   E               F   B             / \   / \
·   / \                     / \           /   \ /   \
·  F   G                   G   E         D     FG    E
```


```c
#include <cstdio>
using namespace std;
struct tNode {
    int data, height;
    tNode *lchild, *rchild;
};

tNode* newNode (int data) {
    tNode *node = new tNode;
    node->data = data;
    node->height = 1;
    node->lchild = node->rchild = NULL;
    return node;
}

// 获得节点所在子树的高度
int getHeight (tNode* root) {
    if (root == NULL)
        return 0;
    return root->height;
}

// 更新节点高度
void updateHeight (tNode* root) {
    root->height = max(getHeight(root->lchild), getHeight(root->rchild)) + 1;
}

// 获得节点的平衡因子：即左子树高度减去右子树高度
int getBalanceFactor (tNode* root) {
    return getHeight(root->lchild) - getHeight(root->rchild);
}

// 左旋
void leftRotation (tNode* &root) {
    tNode* temp = root->rchild;
    root->rchild = temp->lchild;
    temp->lchild = root;
    updateHeight(root);
    updateHeight(temp);
    root = temp;
}

// 右旋
void rightRotation (tNode* &root) {
    tNode* temp = root->lchild;
    root->lchild = temp->rchild;
    temp->rchild = root;
    updateHeight(root);
    updateHeight(temp);
    root = temp;
}

void insert (tNode* &root, int v) {
    if (root == NULL) {
        root = newNode(v);
        return;
    }
    if (v < root->data) {
        insert(root->lchild, v);
        updateHeight(root);
        if (getBalanceFactor(root) == 2) {
            if (getBalanceFactor(root->lchild) == 1) { // LL
                rightRotation(root);
            } else if (getBalanceFactor(root->lchild) == -1) { // LR
                leftRotation(root->lchild);
                rightRotation(root);
            }
        }
    } else {
        insert(root->rchild, v);
        updateHeight(root);
        if (getBalanceFactor(root) == -2) {
            if (getBalanceFactor(root->rchild) == -1) { // RR
                leftRotation(root);
            } else if (getBalanceFactor(root->rchild) == 1) { // RL
                rightRotation(root->rchild);
                leftRotation(root);
            }
        }
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

tNode* createAVLTree (vector<int> data) {
    tNode *root = NULL;
    for (int i = 0; i < data.size(); i++) {
        insert(root, data[i]);
    }
    return root;
}

int main (int argc, const char * argv[]) {
    int N, v;
    scanf("%d", &N);
    vector<int> data;
    for (int i = 0; i < N; i++) {
        scanf("%d", &v);
        data.push_back(v);
    }

    tNode* root = createAVLTree(data);

    printf("%d\n", root->data);

    return 0;
}
```