# C++ map根据value排序

`map`是c++ STL里built-in的数据结构，其元素为`pair`, `pair.first` 为 `map` 的 `key`, `pair.second` 为 `map` 的 `value`

由于 `map` 是集合容器，而非序列容器（像`vector`, `list`, `queue`等），所以并不能直接用stl里的 `sort` 对 `map` 进行排序

## 根据map的key排序

map默认是按照的key的大小进行排序的 （数值或者字典序的升序）:

```c
#include <iostream>
#include <map>
#include <string>
using namespace std;

void printMap(map<string, int> &m){
    map<string, int>::iterator it;
    for (it = m.begin(); it != m.end(); ++it){
        cout << it->first << " : " << it->second << endl;
    }
}

int main(){
    map<string, int> m;
    m["Hello"] = 100;
    m["World"] = 34;
    m["C++"] = 12;
    m.insert(pair<string,int>("Java", 23));
    m.insert(make_pair("Python", 99));
    printMap(m);
    return 0;
}
```

```
C++ : 12
Hello : 100
Java : 23
Python : 99
World : 34
```

若要按照key的降序排序，则只需在声明map的时候使用一个名为 `less` 的 `function object`:

```c
map<string, int, greater<string> > m;
```

```
World : 34
Python : 99
Java : 23
Hello : 100
C++ : 12
```

### Note:

`less` 和 `greater` 的实现：

```c
template <class T> struct less : binary_function <T, T, bool> {
    bool operator() (const T& x, const T& y) const
    { return x < y; }
};
```

```c
template <class T> struct greater : binary_function <T, T, bool> {
    bool operator() (const T& x, const T& y) const
    { return x < y; }
};
```

其中 `less` 和 `greater` 函数也可以自己订制，如：

```c
#include <cstdio>
#include <map>
#include <string>
using namespace std;

template <class T>
class myless {
public:
    bool operator () (const T& x, const T& y) const
    { return x < y; }
};

template <class T>
class mygreater {
public:
    bool operator () (const T& x, const T& y) const
    { return x > y; }
};

void printMap (map<string, int, mygreater<string>> m) {
    for (map<string, int>::iterator it = m.begin(); it != m.end(); it++) {
        printf("%s -> %d", it->first.c_str(), it->second);
    }
}

int main (int argc, const char * argv[]) {
    map<string, int, mygreater<string>> m;
    m["Hello"] = 3;
    m["World"] = 2;
    m["C++"] = 1;
    printMap(m);
    return 0;
}
```

或者用`struct`写也是一样的：

```c
template <class T>
struct myless {
public:
    bool operator() (const T& x, const T& y) const
    { return x < y; }
};

template <class T>
struct mygreater {
public:
    bool operator() (const T& x, const T& y) const
    { return x > y; }
};
```


## 根据value排序

不能用 `sort` 来最 `map` 直接排序，但我们可以把 `map` 序列化，放到 `vector` ，然后进行排序。`sort` 需要制定 `range` 的初始结束位置，以及比较方法:

```c
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace std;

void printVec(vector<pair<string,int> > &vec){
    vector<pair<string, int> >::iterator it;
    for(it = vec.begin(); it!= vec.end(); ++it){
        cout << it->first << " : " << it->second << endl;
    }
}
bool comp_by_value(pair<string, int> &p1, pair<string, int> &p2){
    return p1.second > p2.second;
}
struct CompByValue{
    bool operator()(pair<string, int> &p1, pair<string, int> &p2){
        return p1.second > p2.second;
    }
};
int main(){
    map<string,int> m;
    m["Hello"] = 100;
    m["World"] = 34;
    m["C++"] = 12;
    m.insert(pair<string, int>("Java",23));
    m.insert(make_pair("Python",99));
    //change to a vector
    vector<pair<string, int> > vec (m.begin(), m.end());
    // use compare function
    sort(vec.begin(), vec.end(), comp_by_value);
    // use funcion object
    //sort(vec.begin(),vec.end(),CompByValue());
    printVec(vec);
    return 0;
}
```