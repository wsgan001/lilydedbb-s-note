## [【Lintcode】Topological Sorting](http://www.lintcode.com/en/problem/topological-sorting/)

Given an directed graph, a topological order of the graph nodes is defined as follow:

For each directed edge A -> B in graph, A must before B in the order list.

The first node in the order can be any node in the graph with no nodes direct to it.

Find any topological order for the given graph.

**Notice**

**You can assume that there is at least one topological order in the graph.**

Clarification

Learn more about representation of graphs

Example

For graph as follow:

picture

The topological order can be:

```
[0, 1, 2, 3, 4, 5]
[0, 2, 3, 1, 5, 4]
...
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
     * @return: Any topological order for the given graph.
     */
    vector<DirectedGraphNode*> topSort(vector<DirectedGraphNode*> graph) {
        // write your code here

        map<DirectedGraphNode*, int> inDegree;
        for (int i = 0; i < graph.size(); i++) {
            DirectedGraphNode* node = graph[i];
            for (int j = 0; j < node->neighbors.size(); j++) {
                if (inDegree.find(node->neighbors[j]) == inDegree.end()) inDegree[node->neighbors[j]] = 1;
                else inDegree[node->neighbors[j]]++;
            }
        }

        queue<DirectedGraphNode*> q;
        vector<DirectedGraphNode*> result;
        for (int i = 0; i < graph.size(); i++)
            if (inDegree[graph[i]] == 0) { q.push(graph[i]); result.push_back(graph[i]); }
        while (!q.empty()) {
            DirectedGraphNode* cur = q.front();
            q.pop();
            for (int i = 0; i < cur->neighbors.size(); i++) {
                inDegree[cur->neighbors[i]]--;
                if (inDegree[cur->neighbors[i]] == 0) {
                    q.push(cur->neighbors[i]);
                    result.push_back(cur->neighbors[i]);
                }
            }
        }
        return result;
    }
};
```

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
    map<DirectedGraphNode*, int> inDegree;
    /**
     * @param graph: A list of Directed graph node
     * @return: Any topological order for the given graph.
     */
    vector<DirectedGraphNode*> topSort(vector<DirectedGraphNode*> graph) {
        // write your code here
        vector<DirectedGraphNode*> result;
        for (int i = 0; i < graph.size(); i++) {
            for (int j = 0; j < graph[i]->neighbors.size(); j++) {
                DirectedGraphNode* node = graph[i]->neighbors[j];
                if (inDegree.find(node) == inDegree.end()) inDegree[node] = 1;
                else inDegree[node]++;
            }
        }
        for (int i = 0; i < graph.size(); i++) {
            if (inDegree[graph[i]] == 0) dfs(graph[i], result);
        }
        return result;
    }
private:
    void dfs (DirectedGraphNode* node, vector<DirectedGraphNode*> &result) {
        result.push_back(node);
        inDegree[node]--;
        for (int i = 0; i < node->neighbors.size(); i++) {
            inDegree[node->neighbors[i]]--;
            if (inDegree[node->neighbors[i]] == 0)
                dfs(node->neighbors[i], result);
        }
    }
};
```