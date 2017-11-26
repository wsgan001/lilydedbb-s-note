# OJ 中 I/O 与各数据结构的转换

## OJ 中 I/O 与链表的转换

```c
#include <string>
using namespace std;

struct ListNode {
    int val;
    ListNode *next;
    ListNode(int x) : val(x), next(NULL) {}
};

ListNode* str2list (string str) {
    ListNode* head = new ListNode(0);
    ListNode* node = head;
    int pos = str.find("[");
    str.erase(0, pos + 1);
    pos = str.find(",");
    while (pos != string::npos) {
        string s = str.substr(0, pos);
        node->next = new ListNode(atoi(s.c_str()));
        str.erase(0, pos + 1);
        node = node->next;
        pos = str.find(",");
        if (pos == string::npos) pos = str.find("]");
    }
    return head->next;
}

string list2str (ListNode* head) {
    ListNode* cur = head;
    string str = "[";
    while (cur) {
        str += to_string(cur->val);
        if (cur->next) str += ", ";
        cur = cur->next;
    }
    str += "]";
    return str;
}
```

## OJ 中 I/O 与二叉树的转换

```c
#include <string>
#include <queue>
using namespace std;

struct TreeNode {
    int val;
    TreeNode *left;
    TreeNode *right;
    TreeNode(int x) : val(x), left(NULL), right(NULL) {}
};

void removeSpace (string &s) {
    int pos = s.find(" ");
    while (pos != string::npos) {
        s.erase(pos, 1);
        pos = s.find(" ");
    }
}

TreeNode* str2tree (string str) {
    TreeNode* root = new TreeNode(0);
    TreeNode* null_node = NULL;
    queue<TreeNode*> q;
    queue<TreeNode*> q_parent;
    q.push(root);
    int pos = str.find("[");
    str.erase(0, pos + 1);
    pos = str.find(",");
    bool isLeft = true;
    while (pos != string::npos) {
        string s = str.substr(0, pos);
        removeSpace(s);
        TreeNode* node = q.front();
        q.pop();
        if (s == "null") {
            node = null_node;
        } else {
            if (node) node->val = atoi(s.c_str());
            else node = new TreeNode(atoi(s.c_str()));
            q.push(node->left);
            q.push(node->right);
        }
        if (!q_parent.empty()) {
            TreeNode* parent = q_parent.front();
            if (isLeft) { parent->left = node; isLeft = false; }
            else { parent->right = node; q_parent.pop(); isLeft = true; }
        }
        if (node) q_parent.push(node);
        str.erase(0, pos + 1);
        pos = str.find(",");
        if (pos == string::npos) pos = str.find("]");
    }
    return root;
}

string tree2str (TreeNode* root) {
    string str = "[";
    queue<TreeNode*> q;
    q.push(root);
    int null_num = 0;
    while (!q.empty()) {
        TreeNode* node = q.front();
        if (node) {
            while (null_num > 0) { str += "null, "; null_num--; }
            str += to_string(node->val);
        } else {
            null_num++;
        }
        q.pop();
        if (node) {
            if (node->left) q.push(node->left);
            else q.push(NULL);
            if (node->right) q.push(node->right);
            else q.push(NULL);
            if (!q.empty()) str += ", ";
        }
    }
    str.erase(str.length() - 2, 2);
    str += "]";
    return str;
}
```