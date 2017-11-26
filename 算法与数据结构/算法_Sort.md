# 排序 —— 排序算法总结


排序方法    | 平均情况  | 最好情况  | 最坏情况  | 辅助空间  | 稳定性
------------|-----------|-----------|-----------|-----------|-----------|
冒泡排序    | O(n^2)    | O(n)      | O(n^2)    | O(1)      | 稳定      |
直接插入排序| O(n^2)    | O(n)      | O(n^2)    | O(1)      | 稳定      |
希尔排序    |O(nlogn~n^2)| O(n^1.3) | O(n^2)    | O(1)      | 不稳定    |
简单选择排序| O(n^2)    | O(n^2)    | O(n^2)    | O(1)      | 稳定      |
堆排序      | O(nlogn)  | O(nlogn)  | O(nlogn)  | O(1)      | 不稳定    |
归并排序    | O(nlogn)  | O(nlogn)  | O(nlogn)  | O(n)      | 稳定      |
快速排序    | O(nlogn)  | O(nlogn)  | O(n^2)    | O(nlogn~n)| 不稳定    |




```c
#include <cstdio>
#include <vector>
using namespace std;

void print (int arr[], int len) {
    for (int i = 1; i < len; i++)
        printf("%d ", arr[i]);
    printf("\n");
}

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

int Partition (int arr[], int low, int high) {
    int pivot = arr[low];
    while (low < high) {
        while (low < high && arr[high] > pivot) high--;
        arr[low] = arr[high];
        while (low < high && arr[low] < pivot) low++;
        arr[high] = arr[low];
    }
    arr[low] = pivot;
    return low;
}

void QuickSort (int arr[], int low, int high) {
    if (low < high) {
        int pivot = Partition(arr, low, high);
        QuickSort(arr, low, pivot - 1);
        QuickSort(arr, pivot + 1, high);
    }
}

int SelectMinIndex (int arr[], int i, int len) {
    int min = arr[i], key = i;
    for (int j = i + 1; j < len; j++) {
        if (arr[j] < min) {
            min = arr[j];
            key = j;
        }
    }
    return key;
}

void SelectSort (int arr[], int len) {
    for (int i = 1; i < len; i++) {
        int j = SelectMinIndex(arr, i, len);
        if (i != j) { int temp = arr[j]; arr[j] = arr[i]; arr[i] = temp; }
    }
}

void HeapAdjust (int arr[], int index, int len) {
    arr[0] = arr[index];
    for (int j = index * 2; j <= len; j *= 2) {
        if ((j + 1 <= len) && (arr[j] < arr[j + 1])) j = j + 1;
        if (arr[0] > arr[j]) break;
        arr[index] = arr[j];
        index = j;
    }
    arr[index] = arr[0];
}

void HeapSort (int arr[], int len) {
    for (int i = len / 2; i >= 1; i--)
        HeapAdjust(arr, i, len);
    for (int i = len - 1; i >= 1; i--) {
        arr[0] = arr[1];
        arr[1] = arr[i];
        arr[i] = arr[0];
        HeapAdjust(arr, 1, i - 1);
    }
}

int main (int argc, const char * argv[]) {
    int arr[11] = { NULL, 0, 4, 8, 1, 3, 9, 5, 7, 2, 6 };
    int delta[3] = { 5, 3, 1 };
    int len = (int) (sizeof(arr) / sizeof(arr[0]));
    int deltaLen = (int) (sizeof(delta) / sizeof(delta[0]));
//    InsertSort(arr, len);
//    BInsertSort(arr, len);
//    ShellSort(arr, len, delta, deltaLen);
//    QuickSort(arr, 1, len - 1);
//    SelectSort(arr, len);
    HeapSort(arr, len);
    print(arr, len);
    return 0;
}
```