# 数据结构与算法 (Data Structures and Algorithms)

> 主要依据《数据结构（C语言版）》（严蔚敏著 清华大学出版社）


- data structure 数据结构
- data field 数据域
- ADT: Abstract Data Type 抽象数据类型
- atomic data type 原子类型
- fixed-aggregate data type 固定聚合类型
- variable-aggregate data type 可变聚合类型
- polymorphic data type 多行数据类型
- algorithm 算法
- correctness 正确性
- readability 可读性
- robustness 健壮性
- asymptotic time complexity 渐进时间复杂度（简称时间复杂度）
- space complexity 空间复杂度
- Divide and Conquer 分治


## 线性表 (Linear List)

- static linked list 静态链表
- circular linked list 循环链表
- double linked list 双向链表
- polynomial 多项式


## 栈和队列 (Stack and Queue)

- stack 栈
- top 栈顶
- bottom 栈底
- LIFO: Last In First Out 后进先出
- operand 操作数
- operator 运算符
- delimiter 分隔符
- queue 队列
- FIFO: First In First Out 先进先出
- deque 双端队列
- round-robin queue 循环队列


## 串 (String)

- string 串
- null string 空串
- substring 子串
- blank string 空格串


## 数组和广义表 (Array and General List)

- array 数组
- column major order 以列序为主序
- row major order 以行序为主序
- matrix 矩阵
- sparse matrix 稀疏矩阵
- general list 广义表
- head 表头
- tail 表尾


## 树和二叉树 (Tree and Binary Tree)

- tree 树
- subtree 子树
- degree 结点的度
- leaf 叶子节点
- parent 双亲
- sibling 兄弟
- child 孩子
- level 层次
- depth 深度
- forest 森林
- Binary Tree 二叉树
- traversing binary tree 遍历二叉树
- Threaded Binary Tree 线索二叉树
- Huffman Tree 哈夫曼树


## 图 (Graph)

- vertex 顶点
- edge 边
- arc 弧
- head 弧头
- tail 弧尾
- initial node 起始点
- terminal node 终端点
- digraph 有向图
- undigraph 无向图
- complete graph 完全图
- sparse graph 稀疏图
- dense graph 稠密图
- weight 权
- network 网
- subgraph 子图
- adjacent 邻接点
- incident （边）依附（于顶点）
- degree 度
- indegree 入度
- outdegree 出度
- path 路径
- cycle 回路，环
- connected graph 连通图
- connected component 连通分量
- adjacency list 邻接表
- adjvex 邻接点域
- nextarc 链域
- orthogonal list 十字链表
- tailvex 尾域
- headvex 头域
- adjacency multilist 邻接多重表
- traversing graph 图的遍历
- DFS: Depth First Search 深度优先搜索
- BFS: Broadth First Search 广度优先搜索
- Minimum Cost Spanning Tree 最小生成树
- articulation point 关节点
- biconnected graph 重连通图
- DAG: Directed Acyclic Graph 有向无环图
- Topological Sort 拓扑排序
- partial order 偏序
- Topological Order 拓扑有序
- AOV: Activity On Vertex Network AOV网
- AOE: Activity On Edge Network AOE网
- critical path 关键路径


## 动态存储管理 (Dynamic Storage Management)

- boundary tag method 边界标识法
- buddy system 伙伴系统


## 查找 (Search)

- search table 查找表
- dynamic search table 动态查找表
- primary key 主关键字
- secondary key 次关键字
- static search table 静态查找表
- sequential search 顺序查找
- average search length 平均查找长度
- Binary Search 二分查找
- Static Optimal Search Tree 静态最优查找表
- Nearly Optimal Search Tree 次优查找树
- BST: Binary Search Tree 二叉查找树
- Balanced Binary Tree / Height-balanced Tree 平衡二叉树（AVL树）
- Balance Factor 平衡因子
- Digital Search Trees 键树（数字查找树）
- Hash 哈希
- collision 冲突
- synonym 同义词


## 排序 (Sorting)

- Straight Inserting Sort 直接插入排序
- Shell's Sort 希尔排序
- Diminishing Increment Sort 最小增量排序
- Bubble Sort 冒泡排序
- Quick Sort 快速排序
- Selection Sort 选择排序
- Simple Selection Sort 简单选择排序
- Tree Selection Sort 树形选择排序
- Heap Sort 堆排序
- Merging Sort 并归排序
- Radix Sort 基数排序
- Most Significant Digit First 最高位优先法（MSD法）
- Least Significant Digit First 最低位优先法（LSD法）


## 外部排序 (External Sorting)

- seek time 寻查时间
- latency time 等待时间
- transmission time 传输时间
- segment 段
- Tree of Loser 败者树
- Replacement-Selection Sorting 置换-选择排序


## 文件 (File)

- Sequential File 顺序文件
- ISAM: Index Sequential Access Method 索引顺序存取方法
- VSAM: Virtual Storage Access Method 虚拟存储存取方法
- control range 控制区域
- multilist file 多重表文件