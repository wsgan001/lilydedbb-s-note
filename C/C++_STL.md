# C++ STL (Standard Template Libirary)


## vector

引入头文件：
```c
#include <vector>
using namespace std;
```

定义：
```c
vector<typename> name;
```

**注意：如果typename也是一个`STL`容器，定义的时候要在`>>`之间加上空格，防止一些编译器将其视为移位运算符**

### vector 容器内元素的访问

**1. 通过下标访问**

**2. 通过迭代器访问**

```c
vector<typename>::iterator it;
```

```c
#include <iostream>
#include <vector>
using namespace std;

int main (int argc, const char * argv[]) {

    vector<int> v;
    for (int i = 0; i < 5; i++) {
        v.push_back(i);
    }

    vector<int>::iterator it = v.begin();
    for (int i = 0; i < 5; i++) {
        cout << *(it + i) << " "; // 0 1 2 3 4
    }

    return 0;
}
```

**即 `v[i]` 和 `*(v.begin() + i)` 是等价的**

### vector 常用函数

- `push_back(x)` 即在 vector 后面添加一个元素 x
- `pop_back()` 删除 vector 的尾元素
- `size()` 获得 vector 中元素的个数，返回的是 unsigned 类型
- `clear()` 清空 vector 中所有的元素
- `insert(it, x)` 向 vector 的任意迭代器 it 处插入一个元素 x
- `erase()`：
    - `v.erase(it)` 删除单个元素，即删除迭代器为 it 处的元素
    - `v.erase(first, last)` 删除 `[first, last)` 内的所有元素；`v.erase(v.begin(), v.end())` 等价于 `v.clear()`


## set

引入头文件：
```c
#include <set>
using namespace std;
```

定义：
```c
set<typename> name;
```

**注意：如果typename也是一个`STL`容器，定义的时候要在`>>`之间加上空格，防止一些编译器将其视为移位运算符**

### set 容器内元素的访问

**1. 通过下标访问**

**2. 通过迭代器访问**

```c
set<typename>::iterator it;
```

```c
#include <iostream>
#include <set>
using namespace std;

int main (int argc, const char * argv[]) {

    set<int> s;
    for (int i = 0; i < 5; i++) {
        s.insert(i);
    }

    for (set<int>::iterator it = s.begin(); it != s.end(); it++) {
        cout << *it << " "; // 0 1 2 3 4
    }

    return 0;
}
```

**除了 `vector` 和 `string` 之外的`STL`容器都不支持 `*(it + i)` 的访问方式**

### set 常用函数

- `insert(x)` 将 x 插入 set 容器中，并自动递增排序和去重
- `find(value)` 返回 set 中对应值为 value 的迭代器
- `size()` 获得 set 内元素的个数
- `clear()` 清空 set 内所有的元素
- `erase()`：
    - `s.erase(it)` 删除单个元素，即删除迭代器为 it 处的元素
    - `s.erase(value)` 也是删除单个元素，即删除值 value
    - `s.erase(first, last)` 删除 `[first, last)` 内的所有元素；`s.erase(s.begin(), s.end())` 等价于 `s.clear()`


## string

引入头文件：
```c
#include <string>
using namespace std;
```

定义：
```c
string str = "abcd";
```

### string 中内容的访问

**1. 通过下标访问**

```c
for (int i = 0; i < str.length(); i++) {
    printf("%c", str[i]);
}
```

**要读入或者输出整个字符串，则只能用 `cin` 和 `cout`**

```c
string str;
cin >> str;
cout << str;
```

**如果要使用`printf`输出`string`，则要用 `c_str()` 方法将 `string` 类型换为字符数组进行输出**

```c
string str = "abcd";
printf("%s", str.c_str());
```

**2. 通过迭代器访问**

```c
#include <iostream>
#include <string>
using namespace std;

int main (int argc, const char * argv[]) {

    string str = "abcd";
    for (string::iterator it = str.begin(); it != str.end(); it++) {
        printf("%c", *it); // abcd
    }

    return 0;
}
```

### string 常用函数

- `+=` string 的加法，将两个 string 直接拼起来
- `length()` `size()` 返回 string 的长度
- `clear()` 清空 string 内所有的元素
- `insert()`
    - `str1.insert(pos, str2)` 在 `str[pos]` 处插入 `str2`
    - `str1.insert(it, it1, it2)` 将串`[it1, it2)`插入在it的位置上
- `erase()`：
    - `str.erase(it)` 删除单个元素，即删除迭代器为 it 处的元素
    - `str.erase(first, last)` 删除 `[first, last)` 内的所有元素；`str.erase(str.begin(), str.end())` 等价于 `str.clear()`
    - `str.erase(pos, length)` 删除 `pos` 位置开始，长度为 `length` 的字符个数
- `substr(pos, length)` 返回`pos` 位置开始，长度为 `length` 的字串
- `string::npos` 为 `find()` 函数失配时的返回值
- `find()`：
    - `str1.find(str2)` 返回字串 str2 在 str1 中第一次出现的位置（数值）
    - `str1.find(pos, str2)` 返回字串 str2 在 str1 中从 pos 位置开始，第一次出现的位置（数值）


## map

引入头文件：
```c
#include <map>
using namespace std;
```

定义：
```c
map<typename1, typename2> m;
```

**++`map` 中的键是唯一的++**

**`map` 会以键从小到大的顺序自动排序**

### map 容器内元素的访问

**1. 通过下标访问**

```c
#include <iostream>
#include <map>
using namespace std;

int main (int argc, const char * argv[]) {

    map<char, int> m;
    m['a'] = 1;
    printf("%d", m['a']); // 1

    return 0;
}
```

**2. 通过迭代器访问**

**使用 `it->first` 访问 `键`，`it->second` 访问 `值`**

```c
#include <iostream>
#include <map>
using namespace std;

int main (int argc, const char * argv[]) {

    map<char, int> m;
    m['a'] = 1;
    m['b'] = 2;
    m['c'] = 3;
    for (map<char, int>::iterator it = m.begin(); it != m.end(); it++) {
        cout << it->first << " " << it->second << endl;
    }
    // a 1
    // b 2
    // c 3
    return 0;
}
```

### map 常用函数

- `find(key)` 返回键值为key的映射的迭代器
- `erase()`:
    - `map.erase(it)` it为需要删除的元素的迭代器
    - `map.erase(key)` key为欲删除的映射的键
    - `map.erase(first, last)` 删除区间`[first, last)`内所有元素
- `size()` 获得map中的映射的个数
- `clear()` 清空 map 中所有元素


## queue

引入头文件：
```c
#include <queue>
using namespace std;
```

定义：
```c
queue<typename> name;
```

### queue 容器内元素的访问

**STL 中只能通过：`q.front()` 访问队首元素，`q.back()` 访问队尾元素**

### queue 常用函数

- `push(x)` 将x入队
- `pop()` 令队首元素出队
- `front()` 访问队首元素
- `back()` 访问队尾元素
- `empty()` 检测队列是否为空
- `size()` 返回 queue 内元素的个数


## priority_queue

引入头文件：
```c
#include <queue>
using namespace std;
```

定义：
```c
priority_queue<typename> name;
```

### priority_queue 容器内元素的访问

**优先队列没有 `front()` 和 `back()` 方法，只能通过 `top()` 函数访问队首元素（也称堆顶元素）**

### priority_queue 常用函数

- `push(x)` 将x入队
- `top()` 访问队首元素（也称堆顶元素）
- `pop()` 令队首元素（也称堆顶元素）出队
- `empty()` 检测队列是否为空
- `size()` 返回 priority_queue 内元素的个数

### priority_queue 优先级设置

- 基本数据类型的优先级设置

    默认是数字大的优先级越高，如果是char类型，则是字典序大的优先级高

    下面两种优先队列是等价的：
    ```js
    priority_queue<int> q;
    priority_queue<int, vector<int>, less<int> > q;
    ```
    其中第二个参数`vector<int>`是堆结构容器，第三个参数`less<int>`是对第一个参数的比较类：**`less<int>`表示数字大的优先级越高；`greater<int>`表示数字小的优先级越高**


## stack

引入头文件：
```c
#include <stack>
using namespace std;
```

定义：
```c
stack<typename> name;
```

### stack 容器内元素的访问

**STL 中 stack 只能通过 `top()` 来访问栈顶元素**

### priority_queue 常用函数

- `push(x)` 将x压栈
- `top()` 获得栈顶元素
- `pop()` 弹出栈顶元素
- `empty()` 检测栈是否为空
- `size()` 返回 stack 内元素的个数