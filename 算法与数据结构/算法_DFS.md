# DFS: Depth First Search

```c
bool visited[MAX];
Status (*VisitFunc)(int v);

void DFS (Graph G, int v) {
    visited[v] = true;
    VisitFunc(v);
    for (int w = FirstAdjVex(G, v); w >= 0; w = NextAdjVex(G, v, w))
        if (!visited[w]) DFS(G, w);
}

void DFSTraverse (Graph G, Status (* Visit)(int v)) {
    VisitFunc = Visit;
    for (int v = 0; v < G.vexnum; ++v) visited[v] = false;
    for (int v = 0; v < G.vexnum; ++v)
        if (!visited[v]) DFS(G, v);
}
```