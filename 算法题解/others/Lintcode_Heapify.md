## [【Lintcode】Heapify](http://www.lintcode.com/en/problem/heapify/)

Given an integer array, heapify it into a min-heap array.

For a heap array `A`, `A[0]` is the root of heap, and for each `A[i]`, `A[i * 2 + 1]` is the left child of `A[i]` and `A[i * 2 + 2]` is the right child of `A[i]`.

Clarification

What is heap?

Heap is a data structure, which usually have three methods: push, pop and top. where "push" add a new element the heap, "pop" delete the minimum/maximum element in the heap, "top" return the minimum/maximum element.

What is heapify?

Convert an unordered integer array into a heap array. If it is min-heap, for each element `A[i]`, we will get `A[i * 2 + 1] >= A[i]` and `A[i * 2 + 2] >= A[i]`.

What if there is a lot of solutions?

Return any of them.

Example

Given `[3,2,1,4,5]`, return `[1,2,3,4,5]` or any legal heap array.


```c
class Solution {
public:
    /**
     * @param A: Given an integer array
     * @return: void
     */
    void heapify(vector<int> &A) {
        // write your code here
        for (int i = A.size() / 2; i >= 0; i--) {
            sink(A, i);
        }
    }
private:
    void sink (vector<int> &A, int i) {
        int size = A.size();
        while ((2 * i + 1 < size && A[i] > A[2 * i + 1]) || (2 * i + 2 < size && A[i] > A[2 * i + 2])) {
            int index = 2 * i + 1;
            if (2 * i + 2 < size && A[2 * i + 2] < A[2 * i + 1]) index = 2 * i + 2;
            swap(A, i, index);
            i = index;
        }
    }
    void swap (vector<int> &A, int i, int j) {
        int temp = A[i];
        A[i] = A[j];
        A[j] = temp;
    }
};
```