# 排序 —— 插入排序

**代码实现中，`arr[0]` 闲置或用作哨兵单元**


### 直接插入排序

直接插入排序的时间复杂度仍为 O(n^2)

> 从第二个元素开始遍历，检查该元素是否比前一个元素小，如果小，则交换位置并且继续比较前前一个元素，知道找到该元素应该在的位置

```c
void InsertSort (int arr[], int len) {
    for (int i = 2; i < len; i++) {
        if (arr[i] < arr[i - 1]) {
            int j;
            arr[0] = arr[i]; // arr[0] 用作哨兵单元
            arr[i] = arr[i - 1];
            for (j = i - 1; j >= 1 && arr[0] < arr[j - 1]; j--)
                arr[j] = arr[j - 1];
            arr[j] = arr[0];
        }
    }
}
```


### 折半插入排序

直接插入排序的时间复杂度仍为 O(n^2)

> 折半插入排序所需的附加存储空间和直接插入排序相同，从时间上比较，折半插入排序仅减少了关键字间的比较次数，而记录的移动次数不变

```c
void BInsertSort (int arr[], int len) {
    for (int i = 2; i < len; i++) {
        if (arr[i] < arr[i - 1]) {
            int low = 1, high = i - 1;
            arr[0] = arr[i];
            while (low <= high) {
                int mid = (low + high) / 2;
                if (arr[0] < arr[mid]) high = mid - 1;
                else low = mid + 1;
            }
            int j;
            for (j = i - 1; j >= high + 1; j--)
                arr[j + 1] = arr[j];
            arr[high + 1] = arr[0];
        }
    }
}
```


### 希尔排序

```c
void ShellInsert (int arr[], int delta, int len) {
    for (int i = delta + 1; i < len; i += delta) {
        if (arr[i] < arr[i - delta]) {
            arr[0] = arr[i];
            int j;
            for (j = i - delta; j >= 1 && arr[0] < arr[j]; j -= delta)
                arr[j + delta] = arr[j];
            arr[j + delta] = arr[0];
        }
    }
}

void ShellSort (int arr[], int len, int delta[], int t) {
    for (int i = 0; i < t; i++) {
        ShellInsert(arr, delta[i], len);
    }
}
```
```c
int arr[11] = { NULL, 0, 4, 8, 1, 3, 9, 5, 7, 2, 6 };
int delta[3] = { 5, 3, 1 };
int len = (int) (sizeof(arr) / sizeof(arr[0]));
int deltaLen = (int) (sizeof(delta) / sizeof(delta[0]));
ShellSort(arr, len, delta, deltaLen);
```