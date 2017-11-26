# 最短路径 —— SPFA算法

代码实现：

```c
void SPFA (vector<vector<int>> G, int start) {
    fill(dis.begin(), dis.end(), INT_MAX);
    fill(inQueue.begin(), inQueue.end(), false);
    queue<int> q;
    q.push(start);
    dis[start] = 0;
    inQueue[start] = true;
    while (!q.empty()) {
        int front = q.front();
        q.pop();
        inQueue[front] = false;
        for (int i = 0; i < G[front].size(); i++) {
            if (G[front][i] < INT_MAX && dis[front] + G[front][i] < dis[i]) {
                dis[i] = dis[front] + G[front][i];
                if (!inQueue[i]) {
                    q.push(i);
                    inQueue[i] = true;
                }
            }
        }
    }
}
```

参考: [SPFA 算法详解( 强大图解，不会都难！)](http://lib.csdn.net/article/datastructure/10344)