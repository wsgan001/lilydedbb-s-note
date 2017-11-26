# BFS: Broadth First Search

```c
#include <stack>
using namespace std;

void BFSTraverse (Graph G, Status (* Visit)(int v)) {
    for (int v = 0; v < G.vexnum; ++v) visited[v] = false;
    stack<int> s;
    for (int v = 0; v < G.vexnum; ++v) {
        if (!visited[v]) {
            visited[v] = true;
            Visit(v);
            s.push(v);
            while (!s.empty()) {
                int u = s.top();
                s.pop();
                for (int w = FirstAdjVex(G, u); w >= 0; w = NextAdjVex(G, u, w)) {
                    if (!visited[w]) {
                        visited[w] = true;
                        Visit(w);
                        s.push(w);
                    }
                }
            }
        }
    }
}
```