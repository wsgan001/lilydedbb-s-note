# 指针和引用

**引用和指针的区别：**

1. **引用必须初始化，指定对哪个对象的引用，指针不需要**

    ```
    Node *a; // 无错
    Node &b; // 报错：Declaration of reference variable 'c' requires an initializer
    ```

2. **引用不能为空，即不存在对空对象的引用；指针可以为空，指向空对象**

    ```c
    Node *c = NULL; // 无错
    Node &d = NULL; // 报错：Non-const lvalue reference to type 'Node' cannot bind to a temporary of type 'long'
    ```

3. **引用初始化后不能改变，指针可以改变所指对象的值**

    引用一旦声明后，就不可以改变指向；但是指针可以，如++操作符，指针则指向下一个对象，而引用则改变的是指向对象的内容

    ```c
    int i = 1, j = 2;
    int *b = &i;
    cout << *b << endl; // 1
    b = &j; // 无错
    cout << *b << endl; // 2
    int &a = i;
    cout << a << endl; // 1
    &a = j; // 报错：Expression is not assignable
    ```

4. **引用访问对象是直接访问，指针访问对象是间接访问**
5. **引用的大小是所引用对象的大小，指针的大小，是指针本身大小，通常是4字节**
6. **引用没有const，指针有const**


如果向函数传递的是普通变量，因为是“值传递”，所以无法改变实参的值

```c
#include <cstdio>
#include <iostream>
using namespace std;

struct Node {
    int val;
    Node* next;
};

void func (Node node) {
    node.val = 10;
    cout << node.val << endl;
}

int main (int argc, const char * argv[]) {
    Node a;
    a.val = 1;
    func(a);
    cout << a.val << endl;
    return 0;
}
```

```
# output
10
1
```


若向函数传递的是指针，则函数内的操作会改变指针指向的变量，所以实参的值会发生改变：

```c
#include <cstdio>
#include <iostream>
using namespace std;

struct Node {
    int val;
    Node* next;
};

void func (Node *node) {
    node->val = 10;
    cout << node->val << endl;
}

int main (int argc, const char * argv[]) {
    Node *a = new Node;
    a->val = 1;
    func(a);
    cout << a->val << endl;
    return 0;
}
```

```
# output
10
10
```


如果传递的是引用，也可以达到同样的效果：

```c
#include <cstdio>
#include <iostream>
using namespace std;

struct Node {
    int val;
    Node* next;
};

void func (Node &node) {
    node.val = 10;
    cout << node.val << endl;
}

int main (int argc, const char * argv[]) {
    Node a;
    a.val = 1;
    func(a);
    cout << a.val << endl;
    return 0;
}
```

```
# output
10
10
```


也可以传递指针类型变量的引用：

```c
#include <cstdio>
#include <iostream>
using namespace std;

struct Node {
    int val;
    Node* next;
};

void func (Node* &node) {
    node->val = 10;
    cout << node->val << endl;
}

int main (int argc, const char * argv[]) {
    Node *a = new Node;
    a->val = 1;
    func(a);
    cout << a->val << endl;
    return 0;
}
```

```
# output
10
10
```