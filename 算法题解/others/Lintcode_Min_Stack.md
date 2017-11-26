## [Min Stack](http://www.lintcode.com/en/problem/min-stack/)

Implement a stack with `min()` function, which will return the smallest number in the stack.

It should support push, pop and min operation all in `O(1)` cost.

**Notice**

min operation will never be called if there is no number in the stack.

Example

```
push(1)
pop()   // return 1
push(2)
push(3)
min()   // return 2
push(1)
min()   // return 1
```

```c
class MinStack {
    stack<int> s1;
    stack<int> s2;
public:
    MinStack() {
        // do initialization if necessary
    }

    void push(int number) {
        // write your code here
        s1.push(number);
        if (s2.empty()) {
            s2.push(number);
        } else {
            s2.push((number < s2.top()) ? number : s2.top());
        }
    }

    int pop() {
        // write your code here
        int top = s1.top();
        s1.pop();
        if (top == s2.top()) s2.pop();
        return top;
    }

    int min() {
        // write your code here
        return s2.top();
    }
};
```