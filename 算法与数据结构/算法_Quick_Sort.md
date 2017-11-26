# 排序 —— 快速排序

**代码实现中，`arr[0]` 闲置或用作哨兵单元**

```c
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
```