## [【Lintcode】Find the Connected Component in the Undirected Graph](http://www.lintcode.com/en/problem/find-the-connected-component-in-the-undirected-graph/)

Find the number connected component in the undirected graph. Each node in the

graph contains a label and a list of its neighbors. (a connected component (or just component) of an undirected graph is a subgraph in which any two vertices are connected to each other by paths, and which is connected to no additional vertices in the supergraph.)

Example

Given graph:

```
·A------B  C
· \     |  |
·  \    |  |
·   \   |  |
·    \  |  |
·      D   E
```

Return `{A,B,D}`, `{C,E}`. Since there are two connected component which is `{A,B,D}`, `{C,E}`

