# C++ 运算符重载

```c
返回值类型 operator 运算符名称 (形参表列){
    //TODO:
}
```

```c
#include <cstdio>
#include <iostream>
using namespace std;

class Complex {
private:
	double real, imag;
public:
	Complex (): real(0.0), imag(0.0) {};
	Complex (double a, double b): real(a), imag(b) {};
	Complex operator+ (const Complex &a) {
		return Complex(this->real + a.real, this->imag + a.imag);
	}
	void display () {
		cout << real << " + " << imag << "i" << endl;
	}
};

int main (int argc, const char * argv[]) {

	Complex a(1, 2);
	Complex b(3, 4);
	Complex c = a + b;
	c.display();

	return 0;
}
```

重载 `+` 运算符之后，

```c
Complex c = a + b;
```

这一句，相当于：

```c
Complex c = a.operator+(b);
```

运算符重载函数也可以在类外部声明：

```c
#include <cstdio>
#include <iostream>
using namespace std;

class Complex {
private:
	double real, imag;
public:
	Complex();
	Complex(double a, double b);
	Complex operator + (const Complex &a) const;
	void display();
};

Complex::Complex(): real(0.0), imag(0.0) {};
Complex::Complex(double a, double b): real(a), imag(b) {};
Complex Complex::operator + (const Complex &a) const {
	return Complex(this->real + a.real, this->imag + a.imag);
}
void Complex::display () {
	cout << this->real << " + " << this->imag << "i" << endl;
}

int main (int argc, const char * argv[]) {

	Complex a(1, 2);
	Complex b(3, 4);
	Complex c = a + b;
	c.display();

	return 0;
}
```

**注意**：将运算符重载函数作为全局函数时，二元操作符就需要两个参数，一元操作符需要一个参数，而且**其中必须有一个参数是对象**，好让编译器区分这是程序员自定义的运算符，防止程序员修改用于内置类型的运算符的性质。

例如，下面这样是不对的：

```c
int operator + (int a,int b){
    return (a-b);
}
```


## 在全局范围内重载运算符

运算符重载函数不仅可以作为类的成员函数，还可以作为全局函数

```c
#include <cstdio>
#include <iostream>
using namespace std;

class Complex {
private:
	double real, imag;
public:
	Complex();
	Complex(double a, double b);
	// 声明友元函数
	friend Complex operator + (const Complex &a, const Complex &b);
	void display() const;
};

Complex::Complex(): real(0.0), imag(0.0) {};
Complex::Complex(double a, double b): real(a), imag(b) {};
void Complex::display () const {
	cout << this->real << " + " << this->imag << "i" << endl;
}

// 全局重载运算符
Complex operator + (const Complex &a, const Complex &b) {
	return Complex(a.real + b.real, a.imag + b.imag);
}

int main (int argc, const char * argv[]) {

	Complex a(1, 2);
	Complex b(3, 4);
	Complex c = a + b;
	c.display();

	return 0;
}
```

**注意：运算符重载函数不是 complex 类的成员函数，但是却用到了 complex 类的 private 成员变量，所以必须在 complex 类中将该函数声明为友元函数。**


## 重载>>和<<（输入输出运算符）

```c
#include <cstdio>
#include <iostream>
using namespace std;

class Complex {
private:
	double real, imag;
public:
	Complex();
	Complex(double a, double b);
	// 声明友元函数
	friend Complex operator + (const Complex &a, const Complex &b);
	friend istream & operator >> (istream &in, Complex &a);
	friend ostream & operator << (ostream &out, Complex &a);
};

Complex::Complex(): real(0.0), imag(0.0) {};
Complex::Complex(double a, double b): real(a), imag(b) {};
Complex operator + (const Complex &a, const Complex &b) {
	return Complex(a.real + b.real, a.imag + b.imag);
}
istream & operator >> (istream &in, Complex &a) {
	in >> a.real >> a.imag;
	return in;
}
ostream & operator << (ostream &out, Complex &a) {
	out << a.real << " + " << a.imag << "i" << endl;
	return out;
}

int main (int argc, const char * argv[]) {

	Complex a, b;
	cin >> a >> b;
	Complex c = a + b;
	cout << a  << b  << c;

	return 0;
}
```

只在类内部重载输入输出运算符：

```c
#include <cstdio>
#include <iostream>
using namespace std;

class Complex {
private:
	double real, imag;
public:
	Complex();
	Complex(double a, double b);
	Complex operator + (const Complex &a) const;
	istream & operator >> (istream &in);
	ostream & operator << (ostream &out);
};

Complex::Complex(): real(0.0), imag(0.0) {};
Complex::Complex(double a, double b): real(a), imag(b) {};
Complex Complex::operator + (const Complex &a) const {
	return Complex(this->real + a.real, this->imag + a.imag);
}
istream & Complex::operator >> (istream &in) {
	in >> this->real >> this->imag;
	return in;
};
ostream & Complex::operator << (ostream &out) {
	out << this->real << " + " << this->imag << "i" << endl;
	return out;
};

int main (int argc, const char * argv[]) {

	Complex a, b;
	a.operator>>(cin);
	b.operator>>(cin);
	Complex c = a + b;
	c.operator<<(cout);

	return 0;
}
```