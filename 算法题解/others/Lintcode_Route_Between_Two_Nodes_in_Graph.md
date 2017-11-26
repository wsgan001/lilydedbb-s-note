## [【Lintcode】Route Between Two Nodes in Graph](http://www.lintcode.com/en/problem/route-between-two-nodes-in-graph/)

Given a directed graph, design an algorithm to find out whether there is a route between two nodes.

Example

Given graph:

```
A----->B----->C
 \     |
  \    |
   \   |
    \  v
     ->D----->E
```

for `s = B` and `t = E`, return `true`

for `s = D` and `t = C`, return `false`

**DFS:**

```c
/**
 * Definition for Directed graph.
 * struct DirectedGraphNode {
 *     int label;
 *     vector<DirectedGraphNode *> neighbors;
 *     DirectedGraphNode(int x) : label(x) {};
 * };
 */
class Solution {
public:
    /**
     * @param graph: A list of Directed graph node
     * @param s: the starting Directed graph node
     * @param t: the terminal Directed graph node
     * @return: a boolean value
     */
    bool hasRoute(vector<DirectedGraphNode*> graph,
                  DirectedGraphNode* s, DirectedGraphNode* t) {
        // write your code here
        set<DirectedGraphNode*> vis;
        return dfs(s, t, vis);
    }
private:
    bool dfs (DirectedGraphNode* s, DirectedGraphNode* t, set<DirectedGraphNode*> &vis) {
        vis.insert(s);
        bool flag = false;
        if (s == t) {
            return true;
        } else {
            for (int i = 0; i < s->neighbors.size(); i++) {
                if (vis.find(t) == vis.end())
                    flag = flag || dfs(s->neighbors[i], t, vis);
            }
        }
        return flag;
    }
};
```

**BFS:**

```c
/**
 * Definition for Directed graph.
 * struct DirectedGraphNode {
 *     int label;
 *     vector<DirectedGraphNode *> neighbors;
 *     DirectedGraphNode(int x) : label(x) {};
 * };
 */
class Solution {
public:
    /**
     * @param graph: A list of Directed graph node
     * @param s: the starting Directed graph node
     * @param t: the terminal Directed graph node
     * @return: a boolean value
     */
    bool hasRoute(vector<DirectedGraphNode*> graph,
                  DirectedGraphNode* s, DirectedGraphNode* t) {
        // write your code here
        set<DirectedGraphNode*> vis;
        queue<DirectedGraphNode*> q;
        q.push(s);
        while (!q.empty()) {
            DirectedGraphNode* cur = q.front();
            q.pop();
            vis.insert(cur);
            if (cur == t) return true;
            for (int i = 0; i < cur->neighbors.size(); i++)
                if (vis.find(cur->neighbors[i]) == vis.end()) q.push(cur->neighbors[i]);
        }
        return false;
    }
};
```