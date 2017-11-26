# C++ 面向对象

## 继承

继承的一般语法为：

```c
class 派生类名:［继承方式］ 基类名 {
    派生类新增加的成员
};
```

继承方式包括 public（公有的）、private（私有的）和 protected（受保护的），此项是可选的，如果不写，那么默认为 private。

继承方式/基类成员 | public成员 | protected成员 | private成员
------------------|------------|---------------|-------------
public继承        | public     | protected     | 不可见
protected继承     | protected  | protected     | 不可见
private继承       | private    | private       | 不可见

**即：基类成员在派生类中的访问权限不得高于继承方式中指定的权限**。也就是说，继承方式中的 public、protected、private 是用来指明基类成员在派生类中的最高访问权限的。

**在派生类中访问基类 private 成员的唯一方法就是借助基类的非 private 成员函数，如果基类没有非 private 成员函数，那么该成员在派生类中将无法访问（除非使用 using 关键字）**

如：

```c
#include <cstdio>
#include <iostream>
#include <string>
using namespace std;

class People {
private:
	string name;
	string id;
public:
	People();
	People(string name, string id); 
	string get_name();
};
People::People (): name("none"), id("null") {};
People::People (string name, string id): name(name), id(id) {};
string People::get_name () {
	return this->name;
}

class Student: public People {
private: 
	string stu_id;
public:
	Student(string name, string id, string stu_id);
};
Student::Student(string name, string id, string stu_id): People(name, id), stu_id(stu_id) {};


int main (int argc, const char * argv[]) {

	Student s("lilydedbb", "1234", "4321");
	cout << s.get_name() << endl;
	cout << s.id << endl; // error C2248: 'id' : cannot access private member declared in class 'People'

	return 0;
}
```


### using 关键字改变访问权限

```c
#include <cstdio>
#include <iostream>
#include <string>
using namespace std;

class People {
protected:
	string name;
	string id;
public:
	People();
	People(string name, string id); 
	string get_name();
};
People::People (): name("none"), id("null") {};
People::People (string name, string id): name(name), id(id) {};
string People::get_name () {
	return this->name;
}

class Student: public People {
private: 
	string stu_id;
public:
	using People::id; // 通过 using 关键字改变访问权限，将 protected 改为 public，否则直接访问 Student::id 报错
	Student(string name, string id, string stu_id);
};
Student::Student(string name, string id, string stu_id): People(name, id), stu_id(stu_id) {};


int main (int argc, const char * argv[]) {

	Student s("lilydedbb", "1234", "4321");
	cout << s.get_name() << endl;
	cout << s.id << endl;

	return 0;
}
```


### C++继承时的名字遮蔽

如果派生类中的成员（包括成员变量和成员函数）和基类中的成员重名，那么就会遮蔽从基类继承过来的成员。所谓遮蔽，就是在派生类中使用该成员（包括在定义派生类时使用，也包括通过派生类对象访问该成员）时，实际上使用的是派生类新增的成员，而不是从基类继承来的。

**基类成员函数和派生类成员函数不构成重载**

基类成员和派生类成员的名字一样时会造成遮蔽，这句话对于成员变量很好理解，对于成员函数要引起注意，不管函数的参数如何，只要名字一样就会造成遮蔽。换句话说，基类成员函数和派生类成员函数不会构成重载，如果派生类有同名函数，那么就会遮蔽基类中的所有同名函数，不管它们的参数是否一样。

如：

```c
#include <cstdio>
#include <iostream>
#include <string>
using namespace std;

class Base {
public:
	void func() { cout << "Base func" << endl; }
	void func(int a) { cout << "Base func(int)" << endl; }
};

class Derived: public Base {
public:
	void func(bool a) { cout << "Derived func" << endl; }
	void func(char a) { cout << "Derived func(int)" << endl; }
};

int main (int argc, const char * argv[]) {

	Derived obj;
	obj.func(); // error C2661: 'func' : no overloaded function takes 0 parameters
	obj.func(1); // error C2668: 'func' : ambiguous call to overloaded function

	return 0;
}
```


### 继承中的析构函数

- 创建派生类对象时，构造函数的执行顺序和继承顺序相同，即先执行基类构造函数，再执行派生类构造函数。
- 而销毁派生类对象时，析构函数的执行顺序和继承顺序相反，即先执行派生类析构函数，再执行基类析构函数。

```c
#include <iostream>
using namespace std;

class A{
public:
    A(){cout<<"A constructor"<<endl;}
    ~A(){cout<<"A destructor"<<endl;}
};
class B: public A{
public:
    B(){cout<<"B constructor"<<endl;}
    ~B(){cout<<"B destructor"<<endl;}
};
class C: public B{
public:
    C(){cout<<"C constructor"<<endl;}
    ~C(){cout<<"C destructor"<<endl;}
};

int main(){
    C test;
    return 0;
}
```

```bash
# output
A constructor
B constructor
C constructor
C destructor
B destructor
A destructor
```


## 多态（Polymorphism）

### 虚函数

**通过基类指针只能访问派生类的成员变量，但是不能访问派生类的成员函数**

**指向派生类的基类指针，访问的成员变量都是基类的，即以指针类型为准**

如果基类中未定义，即使派生类中有定义，也会报错

如：

```c
#include <cstdio>
#include <iostream>
#include <string>
using namespace std;

class Parent {
public:
	string name;
	Parent(): name("parent") {};
	void func() { cout << "Parent func" << endl; }
};

class Child: public Parent {
public:
	string name;
	Child(): name("child") {};
	void func() { cout << "Child func" << endl; }
};

int main (int argc, const char * argv[]) {

	Parent *p = new Child();
	cout << p->name << endl;
	p->func();

	return 0;
}
```

```bash
# output
parent
Parent func
```

又如：

```c
#include <cstdio>
#include <iostream>
#include <string>
using namespace std;

class Parent {
public:
	string name;
	Parent(string name): name(name) {};
	void func() { cout << "I'm Parent. My name is " << name << endl; }
};

class Child: public Parent {
public:
	Child(string name): Parent(name) {};
	void func() { cout << "I'm Child. My name is " << name << endl; }
};

int main (int argc, const char * argv[]) {

	Parent *p = new Parent("a");
	p->func();
	p = new Child("b");
	p->func();

	return 0;
}
```

```bash
# output
I'm Parent. My name is a
I'm Parent. My name is b
```


**通过指针调用普通的成员函数时会根据指针的类型（通过哪个类定义的指针）来判断调用哪个类的成员函数，但这种说法并不适用于虚函数，虚函数是根据指针的指向来调用的，指针指向哪个类的对象就调用哪个类的虚函数**

虚函数只需要在函数声明前面增加 virtual 关键字

有了虚函数，基类指针指向基类对象时就使用基类的成员（包括成员函数和成员变量），指向派生类对象时就使用派生类的成员。换句话说，基类指针可以按照基类的方式来做事，也可以按照派生类的方式来做事，它有多种形态，或者说有多种表现方式，将这种现象称为多态（Polymorphism）

```c
#include <cstdio>
#include <iostream>
#include <string>
using namespace std;

class Parent {
public:
	string name;
	Parent(string name): name(name) {};
	virtual void func() { cout << "I'm Parent. My name is " << name << endl; } // 声明为虚函数
};

class Child: public Parent {
public:
	Child(string name): Parent(name) {};
	virtual void func() { cout << "I'm Child. My name is " << name << endl; } // 声明为虚函数
};

int main (int argc, const char * argv[]) {

	Parent *p = new Parent("a");
	p->func();
	p = new Child("b");
	p->func();

	return 0;
}
```

```bash
# output
I'm Parent. My name is a
I'm Child. My name is b
```

综合例子，参考 [C语言中文网](http://c.biancheng.net/cpp/biancheng/view/2988.html)

```c
#include <iostream>
using namespace std;
//基类Base
class Base{
public:
    virtual void func();
    virtual void func(int);
};
void Base::func(){
    cout<<"void Base::func()"<<endl;
}
void Base::func(int n){
    cout<<"void Base::func(int)"<<endl;
}
//派生类Derived
class Derived: public Base{
public:
    void func();
    void func(char *);
};
void Derived::func(){
    cout<<"void Derived::func()"<<endl;
}
void Derived::func(char *str){
    cout<<"void Derived::func(char *)"<<endl;
}
int main(){
    Base *p = new Derived();
    p -> func();  //输出void Derived::func()
    p -> func(10);  //输出void Base::func(int)
    p -> func("http://c.biancheng.net");  //compile error
    return 0;
}
```

在基类 Base 中我们将void func()声明为虚函数，这样派生类 Derived 中的void func()就会自动成为虚函数。p 是基类 Base 的指针，但是指向了派生类 Derived 的对象。

语句p -> func();调用的是派生类的虚函数，构成了多态。

语句p -> func(10);调用的是基类的虚函数，因为派生类中没有函数遮蔽它。

语句p -> func("http://c.biancheng.net");出现编译错误，因为通过基类的指针只能访问从基类继承过去的成员，不能访问派生类新增的成员。


### 纯虚函数和抽象类

纯虚函数

```c
virtual 返回值类型 函数名 (函数参数) = 0;
```

**最后的=0并不表示函数返回值为0，它只起形式上的作用，告诉编译系统“这是纯虚函数”**

包含纯虚函数的类称为抽象类（Abstract Class）

**抽象类无法实例化**

抽象类通常是作为基类，让派生类去实现纯虚函数。**派生类必须实现++全部++纯虚函数才能被实例化**