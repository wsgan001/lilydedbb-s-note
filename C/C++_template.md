# C++ 模版

**值（Value）和类型（Type）是数据的两个主要特征，它们在C++中都可以被参数化**

## 函数模版

> 所谓函数模板，实际上是建立一个通用函数，它所用到的数据的类型（包括返回值类型、形参类型、局部变量类型）可以不具体指定，而是用一个虚拟的类型来代替（实际上是用一个标识符来占位），等发生函数调用时再根据传入的实参来逆推出真正的类型。这个通用函数就称为函数模板（Function Template）。

```
template <typename 类型参数1 , typename 类型参数2 , ...> 返回值类型  函数名(形参列表){
    //在函数体中可以使用类型参数
}
```

**`typename` 关键字也可以使用 `class` 关键字替代，它们没有任何区别**

```c
#include <cstdio>
#include <iostream>
using namespace std;

template<typename T> void swap (T *a, T *b) {
	T temp = *a;
	*a = *b;
	*b = temp;
}

int main (int argc, const char * argv[]) {

	int a = 1, b = 10;
	swap (a, b);
	printf("%d, %d\n", a, b);
	char c1 = 'a', c2 = 'b';
	swap (c1, c2);
	printf("%c, %c\n", c1, c2);
	double c = 6.23, d = 6.24;
	swap (c, d);
	printf("%.2f, %.2f\n", c, d);

	return 0;
}
```

或者用引用实现上述函数：

```c
#include <cstdio>

template<typename T> void swap(T &a, T &b) {
	T temp = a;
	a = b;
	b = temp;
}

int main (int argc, const char * argv[]) {

	int a = 1, b = 10;
	swap (a, b);
	printf("%d, %d\n", a, b);
	char c1 = 'a', c2 = 'b';
	swap (c1, c2);
	printf("%c, %c\n", c1, c2);
	double c = 6.23, d = 6.24;
	swap (c, d);
	printf("%.2f, %.2f\n", c, d);

	return 0;
}
```


## 类模版

```c
template<typename 类型参数1 , typename 类型参数2 , …> class 类名{
    //TODO:
};
```

在类外定义成员函数时仍然需要带上模板头，格式为：

```c
template<typename 类型参数1 , typename 类型参数2 , …>
返回值类型 类名<类型参数1 , 类型参数2, ...>::函数名(形参列表){
    //TODO:
}
```

```c
#include <cstdio>
#include <iostream>
using namespace std;

template<typename T1, typename T2>
class Coord {
private:
	T1 x;
	T2 y;
public:
	Coord(T1 a, T2 b): x(a), y(b) {}
	void set (T1 a, T2 b) {
		x = a;
		y = b;
	}
	pair<T1, T2> get () {
		return make_pair(x, y);
	}
};

int main (int argc, const char * argv[]) {

	Coord<int, int> c1(1, 2);
	pair<int, int> coord1 = c1.get();
	printf("(%d, %d)\n", coord1.first, coord1.second);

	Coord<float, float> c2(1.0, 2.0);
	pair<float, float> coord2 = c2.get();
	printf("(%.2f, %.2f)\n", coord2.first, coord2.second);

	Coord<int, char> c3(1, 'a');
	pair<int, char> coord3 = c3.get();
	printf("(%d, %c)\n", coord3.first, coord3.second);

	// 或者使用 new 关键字
	Coord<int, int> *c = new Coord<int, int> (3, 4);
	pair<int, int> coord4 = c->get();
	printf("(%d, %d)\n", coord4.first, coord4.second);

	return 0;
}
```

或者在类外部声明成员函数：

```c
#include <cstdio>
#include <iostream>
#include <string>
using namespace std;

template<typename T1, typename T2>
class Coord {
private:
	T1 x;
	T2 y;
public:
	void set(pair<T1, T2> p);
	pair<T1, T2> get() const;
	Coord (T1 a, T2 b): x(a), y(b) {};
};

template<typename T1, typename T2> pair<T1, T2> Coord<T1, T2>::get () const {
	return make_pair(x, y);
};

template<typename T1, typename T2> void Coord<T1, T2>::set (pair<T1, T2> p) {
	this->x = p.first;
	this->y = p.second;
};

int main (int argc, const char * argv[]) {

	Coord<int, int> c1(1, 2);
	cout << c1.get().first << ',' << c1.get().second << endl;
	c1.set(make_pair(2, 3));
	cout << c1.get().first << ',' << c1.get().second << endl;

	Coord<float, string> *c2 = new Coord<float, string>(6.23, "6.24");
	cout << c2->get().first << ',' << c2->get().second << endl;


	return 0;
}
```