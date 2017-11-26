# 排序 —— 选择排序

**代码实现中，arr[0] 闲置或用作哨兵单元**


### 简单选择排序

```c
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
```


### 堆排序

数据结构（严蔚敏）中的代码实现如下：
```c
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
```


《算法》一书中，对于堆排序的实现如下 **（这里数组从0开始计数）**：

```c
// 堆排序辅助方法————下沉（小元素下沉）
void sink(int *arr, int index, int len){
    int i;
    // index 的子节点为 (2 * index + 1) 和 (2 * index + 2)
    while(2 * index + 1 <= len - 1){
        i = 2 * index + 1;
        // 和最大的子节点交换
        if((i + 1 <= len - 1) && (arr[i] <= arr[i + 1]))
            i++;
        if(arr[index] >= arr[i])
            break;
        exchange(arr, index, i);
        index = i;
    }
}

// 堆排序辅助方法————上升（大元素上升）
void swim(int *arr, int index, int len){
    int i;
    while (index > 0) {
        i = (index % 2 == 0) ? ((index - 1) / 2) : (index / 2); // 父节点
        if(arr[index] <= arr[i])
            break;
        exchange(arr, index, i);
        index = i;
    }
}

// 堆排序
void heapSort(int *arr, int len){
    // sink构建最大堆
    for(int i = len / 2 - 1; i >= 0; i--)
        sink(arr, i, len);

    // // swim构建最大堆
    // for(int i = 1; i < len; i++)
    //    swim(arr, i, len);

    // 下沉排序
    for(int i = len - 1; i >= 0; i--){
        exchange(arr, 0, i); // 交换堆顶和最后一位，最后一位即为最大数
        sink(arr, 0, i); // 将堆的大小减一，然后将换到堆顶的数”沉“下去
    }
}
```