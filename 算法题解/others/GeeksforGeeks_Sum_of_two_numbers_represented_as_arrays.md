## [【GeeksforGeeks】Sum of two numbers represented as arrays](http://practice.geeksforgeeks.org/problems/sum-of-two-numbers-represented-as-arrays/0)

Given two numbers represented by two arrays, write a function that returns sum array. The sum array is an array representation of addition of two input arrays. It is not allowed to modify the arrays.

**Input:**

The first line of input contains an integer T denoting the number of test cases.

The first line of each test case contains two integers M and N separated by a space. M is the size of arr1 and N is the size of arr2.

The second line of each test case contains M integers which is the input for arr1.

The third line of each test case contains N integers which is the input for arr2.

**Output:**

Print the sum list.

Constraints:

1 ≤ T ≤ 100

1 ≤ N ≤ M ≤ 1000

0 ≤ arr1[i],arr2[i]≤ 9

Example:

Input:

```
2
3 3
5 6 3
8 4 2
16 4
2 2 7 5 3 3 7 3 3 6 8 3 0 5 0 6
4 3 3 8
```

Output:

```
1 4 0 5
2 2 7 5 3 3 7 3 3 6 8 3 4 8 4 4
```

**For More Examples Use Expected Output**


```c
#include <iostream>
#include <stack>
#include <algorithm>
#include <cstdio>
using namespace std;

int main() {
    int T, N, M;
    cin >> T;
    int num;
    for (int i = 0; i < T; i++) {
        stack<int> num1, num2, result;
        cin >> M >> N;
        for (int j = 0; j < M; j++) { cin >> num; num1.push(num); }
        for (int j = 0; j < N; j++) { cin >> num; num2.push(num); }
        int c = 0;
        while (!num1.empty() && !num2.empty()) {
            int n1 = num1.top(); num1.pop();
            int n2 = num2.top(); num2.pop();
            int n3 = n1 + n2 + c;
            c = n3 / 10;
            n3 %= 10;
            result.push(n3);
        }
        while (!num1.empty()) {
            int n = num1.top(); num1.pop();
            n = n + c;
            c = n / 10;
            n %= 10;
            result.push(n);
        }
        while (!num2.empty()) {
            int n = num2.top(); num2.pop();
            n = n + c;
            c = n / 10;
            n %= 10;
            result.push(n);
        }
        if (c) result.push(c);
        while (!result.empty()) {
            cout << result.top() << " ";
            result.pop();
        }
        cout << endl;
    }
    return 0;
}
```