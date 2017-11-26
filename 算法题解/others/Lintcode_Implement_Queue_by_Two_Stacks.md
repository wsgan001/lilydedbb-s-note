## [【Lintcode】Implement Queue by Two Stacks](http://www.lintcode.com/en/problem/implement-queue-by-two-stacks/)

As the title described, you should only use two stacks to implement a queue's actions.

The queue should support `push(element)`, `pop()` and `top()` where pop is pop the first(a.k.a front) element in the queue.

Both pop and top methods should return the value of first element.

Example

```
push(1)
pop()     // return 1
push(2)
push(3)
top()     // return 2
pop()     // return 2
```

```c
class MyQueue {
public:
    stack<int> stack1;
    stack<int> stack2;

    MyQueue() {
        // do intialization if necessary
    }

    void push(int element) {
        // write your code here
        stack1.push(element);
    }

    int pop() {
        // write your code here
        adjust();
        int top = stack2.top();
        stack2.pop();
        return top;
    }

    int top() {
        // write your code here
        adjust();
        return stack2.top();
    }

private:
    void adjust () {
        if (stack2.empty()) {
            while (!stack1.empty()) {
                stack2.push(stack1.top());
                stack1.pop();
            }
        }
    }
};
```