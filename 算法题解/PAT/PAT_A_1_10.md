# PAT A 1 - 10

## [A1001. A+B Format (20)](https://www.patest.cn/contests/pat-a-practise/1001)

Calculate a + b and output the sum in standard format -- that is, the digits must be separated into groups of three by commas (unless there are less than four digits).

**Input**

Each input file contains one test case. Each case contains a pair of integers a and b where -1000000 <= a, b <= 1000000. The numbers are separated by a space.

**Output**

For each test case, you should output the sum of a and b in one line. The sum must be written in the standard format.

**Sample Input**

```
-1000000 9
```

**Sample Output**

```
-999,991
```

```c
#include <stdio.h>

int main(int argc, const char * argv[]) {

    int num [10];
    int a, b;
    scanf("%d %d", &a, &b);
    int sum = a + b;
    if(sum < 0){
        printf("-");
        sum = -sum;
    }
    int len = 0;
    do{
        num[len++] = sum % 10;
        sum /= 10;
    }while(sum);

    for(int i = len - 1; i >= 0; i--){
        printf("%d", num[i]);
        if(i % 3 == 0 && i > 0)
            printf(",");
    }

    return 0;
}
```

```c
#include <iostream>
#include <stack>
#include <string>
using namespace std;

int main () {

	int a, b, c;
	cin >> a >> b;
	c = a + b;
	stack<int> s;
	if (c < 0) {
		cout << "-";
		c = -c;
	}
	if (c == 0) {
		cout << "0" << endl;
	} else {
		while (c > 0) {
			s.push(c % 1000);
			c = c / 1000;
		}
		bool begin = true;
		while (!s.empty()) {
			int top = s.top();
			s.pop();
			if (begin) { begin = false; printf("%d", top); }
			else { printf("%03d", top); }
			if (!s.empty()) cout << ",";
		}
		cout << endl;
	}

	return 0;
}
```


------


## [A1002. A+B for Polynomials (25)](https://www.patest.cn/contests/pat-a-practise/1002)

This time, you are supposed to find A+B where A and B are two polynomials.

**Input**

Each input file contains one test case. Each case occupies 2 lines, and each line contains the information of a polynomial: K N1 aN1 N2 aN2 ... NK aNK, where K is the number of nonzero terms in the polynomial, Ni and aNi (i=1, 2, ..., K) are the exponents and coefficients, respectively. It is given that 1 <= K <= 10，0 <= NK < ... < N2 < N1 <=1000.

**Output**

For each test case you should output the sum of A and B in one line, with the same format as the input. Notice that there must be NO extra space at the end of each line. Please be accurate to 1 decimal place.

**Sample Input**

```
2 1 2.4 0 3.2
2 2 1.5 1 0.5
```

**Sample Output**

```
3 2 1.5 1 2.9 0 3.2
```

```c
#include <stdio.h>

int main() {

    int K, i, exp, count = 0;
    double coef;
    scanf("%d", &K);
    double a[1001] = {0.0};
    for(i = 0; i < K; i++){
        scanf("%d %lf", &exp, &coef);
        a[exp] += coef;
    }
    scanf("%d", &K);
    for(i = 0; i < K; i++){
        scanf("%d %lf", &exp, &coef);
        a[exp] += coef;
    }

    for(i = 0; i <= 1000; i++)
        if(a[i] != 0) count++;

    printf("%d", count);
    for(i = 1000; i >= 0; i--)
        if(a[i] != 0) printf(" %d %.1lf", i, a[i]);

    return 0;
}
```


------


## [A1003. Emergency (25)](https://www.patest.cn/contests/pat-a-practise/1003)

As an emergency rescue team leader of a city, you are given a special map of your country. The map shows several scattered cities connected by some roads. Amount of rescue teams in each city and the length of each road between any pair of cities are marked on the map. When there is an emergency call to you from some other city, your job is to lead your men to the place as quickly as possible, and at the mean time, call up as many hands on the way as possible.

**Input**

Each input file contains one test case. For each test case, the first line contains 4 positive integers: N (<= 500) - the number of cities (and the cities are numbered from 0 to N-1), M - the number of roads, C1 and C2 - the cities that you are currently in and that you must save, respectively. The next line contains N integers, where the i-th integer is the number of rescue teams in the i-th city. Then M lines follow, each describes a road with three integers c1, c2 and L, which are the pair of cities connected by a road and the length of that road, respectively. It is guaranteed that there exists at least one path from C1 to C2.

**Output**

For each test case, print in one line two numbers: the number of different shortest paths between C1 and C2, and the maximum amount of rescue teams you can possibly gather.
All the numbers in a line must be separated by exactly one space, and there is no extra space allowed at the end of a line.

**Sample Input**

```
5 6 0 2
1 2 1 5 3
0 1 1
0 2 2
0 3 1
1 2 1
2 4 1
3 4 1
```

**Sample Output**

```
2 4
```

**DFS 解法，有一组数据运行超时；[查看提交](https://www.patest.cn/submissions/3542065)**

```c
#include <iostream>
#include <vector>
#include <algorithm>
#include <climits>
using namespace std;
vector<int> city;
vector<vector<int>> G;
vector<bool> vis;
int n, m, start, dest, shortest = INT_MAX, shortest_num = 0, max_team = 0;

void dfs (int now, int dist, int team) {
	if (now == dest) {
		if (dist < shortest) {
			shortest = dist;
			max_team = team;
			shortest_num = 1;
		} else if (dist == shortest) {
			shortest_num++;
			max_team = max(team, max_team);
		}
	}
	for (int i = 0; i < n; i++) {
		if (!vis[i] && G[now][i] != -1) {
			dist += G[now][i];
			team += city[i];
			vis[i] = true;
			dfs(i, dist, team);
			dist -= G[now][i];
			team -= city[i];
			vis[i] = false;
		}
	}
}

int main () {

	int c1, c2, len;
	cin >> n >> m >> start >> dest;
	city.resize(n);
	vis.resize(n, false);
	G.resize(n, vector<int>(n, -1));
	for (int i = 0; i < n; i++) cin >> city[i];
	while (m--) {
		cin >> c1 >> c2 >> len;
		G[c1][c2] = len;
		G[c2][c1] = len;
	}
	dfs(start, 0, city[start]);
	cout << shortest_num << " " << max_team << endl;

	return 0;
}
```

**用 Dijkstra 算法，全部通过**

```c
#include <iostream>
#include <vector>
#include <algorithm>
#include <climits>
using namespace std;
vector<int> city;
vector<int> d, num, team; // d[i] 表示起点到 i 的最短距离，num[i] 表示起点到 i 的最短路径有几条，team[i] 表示起点到 i 的所有最短路径中能够召集最多team数量
vector<vector<int>> G;
vector<bool> vis;
int n, m, start, dest;

void Dijkstra (int s) {
	vis.resize(n, false);
	d.resize(n, INT_MAX);
	num.resize(n, 0);
	team.resize(n, 0);
	d[s] = 0;
	num[s] = 1;
	team[s] = city[s];
	for (int i = 0; i < n; i++) {
		int u = -1, _min = INT_MAX;
		for (int j = 0; j < n; j++) {
			if (!vis[j] && d[j] < _min) {
				_min = d[j];
				u = j;
			}
		}
		if (u == -1) return;
		vis[u] = true;
		for (int v = 0; v < n; v++) {
			if (!vis[v] && G[u][v] != -1) {
				if (d[u] + G[u][v] < d[v]) {
					d[v] = d[u] + G[u][v];
					num[v] = num[u];
					team[v] = team[u] + city[v];
				} else if (d[u] + G[u][v] == d[v]) {
					num[v] += num[u];
					team[v] = max(team[v], team[u] + city[v]);
				}
			}
		}
	}
}

int main () {

	int c1, c2, len;
	cin >> n >> m >> start >> dest;
	city.resize(n);
	G.resize(n, vector<int>(n, -1));
	for (int i = 0; i < n; i++) cin >> city[i];
	while (m--) {
		cin >> c1 >> c2 >> len;
		G[c1][c2] = len;
		G[c2][c1] = len;
	}
	Dijkstra(start);
	cout << num[dest] << " " << team[dest] << endl;

	return 0;
}
```


------


## [A1004. Counting Leaves (30)](https://www.patest.cn/contests/pat-a-practise/1004)

A family hierarchy is usually presented by a pedigree tree. Your job is to count those family members who have no child.

**Input**

Each input file contains one test case. Each case starts with a line containing 0 < N < 100, the number of nodes in a tree, and M (< N), the number of non-leaf nodes. Then M lines follow, each in the format:

```
ID K ID[1] ID[2] ... ID[K]
```

where ID is a two-digit number representing a given non-leaf node, K is the number of its children, followed by a sequence of two-digit ID's of its children. For the sake of simplicity, let us fix the root ID to be 01.

**Output**

For each test case, you are supposed to count those family members who have no child for every seniority level starting from the root. The numbers must be printed in a line, separated by a space, and there must be no extra space at the end of each line.

The sample case represents a tree with only 2 nodes, where 01 is the root and 02 is its only child. Hence on the root 01 level, there is 0 leaf node; and on the next level, there is 1 leaf node. Then we should output "0 1" in a line.

**Sample Input**

```
2 1
01 1 02
```

**Sample Output**

```
0 1
```

DFS 解法：

```c
#include <iostream>
#include <algorithm>
#include <vector>
using namespace std;
const int maxn = 110;
vector<int> G[maxn];
int leaf[maxn] = {0}; // 存放每层的叶子节点数
int max_h = 1;

void DFS (int now, int h) {
    max_h = max(h, max_h);
    if (G[now].size() == 0) {
        leaf[h]++;
        return;
    }
    for (int i = 0; i < G[now].size(); i++) {
        DFS(G[now][i], h + 1);
    }

}
int main (int argc, const char * argv[]) {
    int n, m, parent, child, k;
    cin >> n >> m;
    for (int i = 0; i < m; i++) {
        scanf("%d %d", &parent, &k);
        for (int j = 0; j < k; j++) {
            scanf("%d", &child);
            G[parent].push_back(child);
        }
    }
    DFS(1, 1);
    for (int i = 1; i <= max_h; i++) {
        printf("%d", leaf[i]);
        if (i <= max_h - 1)
            printf(" ");
    }
    return 0;
}
```

BFS 解法：

```c
#include <iostream>
#include <vector>
#include <queue>
using namespace std;
vector<vector<int>> tree;
vector<int> level, ans;
int max_level;

void bfs (int root) {
	level[root] = 0;
	queue<int> q;
	q.push(root);
	while (!q.empty()) {
		int node = q.front();
		q.pop();
		if (tree[node].size() == 0) ans[level[node]]++;
		else {
			for (int i = 0; i < tree[node].size(); i++) {
				level[tree[node][i]] = level[node] + 1;
				max_level = level[tree[node][i]];
				q.push(tree[node][i]);
			}
		}
	}
}

int main () {

	int n, m, id, k, child;
	cin >> n >> m;
	tree.resize(n + 1);
	level.resize(n + 1, -1);
	ans.resize(n + 1, 0);
	while (m--) {
		cin >> id >> k;
		while (k--) {
			cin >> child;
			tree[id].push_back(child);
		}
	}
	bfs(1);
	for (int i = 0; i <= max_level; i++) {
		cout << ans[i];
		if (i < max_level) cout << " ";
	}
	cout << endl;

	return 0;
}
```


------


## [A1005. Spell It Right (20)](https://www.patest.cn/contests/pat-a-practise/1005)

**注意本题用递归法实现倒着打印，而不需要额外的数组**

```c
#include <stdio.h>
#include <string.h>

char digit[10][10] = {"zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"};
int count = 0;

// 递归调用，实现倒着打印数字对应的单词
// hasSpace用来处理是否输出一个空格
void myprint(int number, int hasSpace){
    if(number > 0){
        char* Eng = digit[number % 10];
        number /= 10;
        myprint(number, 1);
        printf("%s", Eng);
        if(hasSpace)
            printf(" ");
        count++;
    }
}

int main(){
    char number[101];
    int result = 0, i;
    scanf("%s", number);
    for(i = 0; i < strlen(number); i++)
        result += (int)(number[i] - '0');
    if(result == 0)
        printf("zero");
    else
        myprint(result, 0);
    return 0;
}
```


------


## [A1006. Sign In and Sign Out (25)](https://www.patest.cn/contests/pat-a-practise/1006)

At the beginning of every day, the first person who signs in the computer room will unlock the door, and the last one who signs out will lock the door. Given the records of signing in's and out's, you are supposed to find the ones who have unlocked and locked the door on that day.

**Input Specification:**

Each input file contains one test case. Each case contains the records for one day. The case starts with a positive integer M, which is the total number of records, followed by M lines, each in the format:

```
ID_number Sign_in_time Sign_out_time
```

where times are given in the format HH:MM:SS, and ID number is a string with no more than 15 characters.

**Output Specification:**

For each test case, output in one line the ID numbers of the persons who have unlocked and locked the door on that day. The two ID numbers must be separated by one space.

Note: It is guaranteed that the records are consistent. That is, the sign in time must be earlier than the sign out time for each person, and there are no two persons sign in or out at the same moment.

**Sample Input:**

```
3
CS301111 15:30:28 17:00:10
SC3021234 08:00:00 11:25:25
CS301133 21:45:00 21:58:40
```

**Sample Output:**

```
SC3021234 CS301133
```

```c
#include <stdio.h>

struct person {
    char id[16];
    int h, m, s;
}tmp, unlock, lock;

int earlier(struct person p1, struct person p2){
    if(p1.h != p2.h)
        return p1.h < p2.h;
    else if(p1.m != p2.m)
        return p1.m < p2.m;
    else
        return p1.s < p2.s;
}

int main(){
    int N;
    scanf("%d", &N);
    unlock.h = 24;
    unlock.m = unlock.s = 60;
    lock.h = lock.m = lock.s = 0;
    for(int i = 0; i < N; i++){
        scanf("%s %d:%d:%d", tmp.id, &tmp.h, &tmp.m, &tmp.s);
        if(earlier(tmp, unlock))
            unlock = tmp;
        scanf("%d:%d:%d", &tmp.h, &tmp.m, &tmp.s);
        if(!earlier(tmp, lock))
            lock = tmp;
    }

    printf("%s %s", unlock.id, lock.id);

    return 0;
}
```


------


## [A1007. Maximum Subsequence Sum (25)](https://www.patest.cn/contests/pat-a-practise/1007)

Given a sequence of K integers { N1, N2, ..., NK }. A continuous subsequence is defined to be { Ni, Ni+1, ..., Nj } where 1 <= i <= j <= K. The Maximum Subsequence is the continuous subsequence which has the largest sum of its elements. For example, given sequence { -2, 11, -4, 13, -5, -2 }, its maximum subsequence is { 11, -4, 13 } with the largest sum being 20.

Now you are supposed to find the largest sum, together with the first and the last numbers of the maximum subsequence.

**Input Specification:**

Each input file contains one test case. Each case occupies two lines. The first line contains a positive integer K (<= 10000). The second line contains K numbers, separated by a space.

**Output Specification:**

For each test case, output in one line the largest sum, together with the first and the last numbers of the maximum subsequence. The numbers must be separated by one space, but there must be no extra space at the end of a line. In case that the maximum subsequence is not unique, output the one with the smallest indices i and j (as shown by the sample case). If all the K numbers are negative, then its maximum sum is defined to be 0, and you are supposed to output the first and the last numbers of the whole sequence.

**Sample Input:**

```
10
-10 1 2 3 4 -5 -23 3 7 -21
```

**Sample Output:**

```
10 1 4
```

动规：状态转移方程：

```
dp[i] = max{ a[i], dp[i - 1] + a[1] }
```

```c
#include <iostream>
#include <vector>
using namespace std;

int main () {

	int n;
	cin >> n;
	bool all_negetive = true;
	vector<int> v(n), dp(n), start(n); // dp[i] 表示以第 i 个元素结尾的连续子序列的最大和，start 表示以第 i 个元素结尾的连续子序列的起始元素
	for (int i = 0; i < n; i++) {
		cin >> v[i];
		if (v[i] >= 0) all_negetive = false;
	}

	if (all_negetive) {
		cout << "0 " << v[0] << " " << v[n - 1] << endl;
	} else {
		dp[0] = v[0]; start[0] = v[0];
		for (int i = 1; i < n; i++) {
			if (v[i] > dp[i - 1] + v[i]) {
				dp[i] = v[i];
				start[i] = v[i];
			} else {
				dp[i] = dp[i - 1] + v[i];
				start[i] = start[i - 1];
			}
		}
		int index = 0, max = dp[0];
		for (int j = 1; j < n; j++)
			if (dp[j] > max) { index = j; max = dp[j]; }
		cout << dp[index] << " " << start[index] << " " << v[index] << endl;
	}

	return 0;
}
```


------


## [A1008. Elevator (20)](https://www.patest.cn/contests/pat-a-practise/1008)

The highest building in our city has only one elevator. A request list is made up with N positive numbers. The numbers denote at which floors the elevator will stop, in specified order. It costs 6 seconds to move the elevator up one floor, and 4 seconds to move down one floor. The elevator will stay for 5 seconds at each stop.

For a given request list, you are to compute the total time spent to fulfill the requests on the list. The elevator is on the 0th floor at the beginning and does not have to return to the ground floor when the requests are fulfilled.

**Input Specification:**

Each input file contains one test case. Each case contains a positive integer N, followed by N positive numbers. All the numbers in the input are less than 100.

**Output Specification:**

For each test case, print the total time on a single line.

**Sample Input:**

```
3 2 3 1
```

**Sample Output:**

```
41
```

```c
#include <iostream>
using namespace std;

int main () {

	int n, sum = 0, prev = 0;
	cin >> n;
	while (cin >> n) {
		if (n - prev > 0) sum += 6 * (n - prev);
		else sum += 4 * (prev - n);
		sum += 5;
		prev = n;
	}
	cout << sum << endl;

	return 0;
}
```


------


## [A1009. Product of Polynomials (25)](https://www.patest.cn/contests/pat-a-practise/1009)

This time, you are supposed to find A*B where A and B are two polynomials.

**Input Specification:**

Each input file contains one test case. Each case occupies 2 lines, and each line contains the information of a polynomial: K N1 aN1 N2 aN2 ... NK aNK, where K is the number of nonzero terms in the polynomial, Ni and aNi (i=1, 2, ..., K) are the exponents and coefficients, respectively. It is given that 1 <= K <= 10, 0 <= NK < ... < N2 < N1 <=1000.

**Output Specification:**

For each test case you should output the product of A and B in one line, with the same format as the input. Notice that there must be NO extra space at the end of each line. Please be accurate up to 1 decimal place.

**Sample Input**

```
2 1 2.4 0 3.2
2 2 1.5 1 0.5
```

**Sample Output**

```
3 3 3.6 2 6.0 1 1.6
```

```c
#include <stdio.h>

int main(){
    int K, i, exp;
    double coef;
    // 输入K
    scanf("%d", &K);
    // key代表指数，value代表系数
    double a[1001] = {0.0}, b[1001] = {0.0}, res[2001] = {0.0}; // res 数组大小要为2001
    // 输入数据
    for(i = 0; i < K; i++){
        scanf("%d %lf", &exp, &coef);
        a[exp] += coef;
    }
    scanf("%d", &K);
    for(i = 0; i < K; i++){
        scanf("%d %lf", &exp, &coef);
        b[exp] += coef;
    }

    // 计算系数
    for(i = 0; i <= 1000; i++){
        for(int j = 0; j <= 1000; j++){
            res[i + j] += a[i] * b[j];
        }
    }

    int count = 0;
    for(i = 0; i <= 2000; i++){
        if (res[i] != 0) {
            count++;
        }
    }
    // 输出结果
    printf("%d", count);
    for(i = 2000; i >= 0; i--){
        if(res[i] != 0)
            printf(" %d %.1lf", i, res[i]);
    }
    return 0;
}
```

更优化的办法就是不必声明第二个数组，在进行第二组输入的时候，就对数据进行处理

```
#include <stdio.h>

int main(){
    int K, i, j, exp, count = 0;;
    double coef;
    // 输入K
    scanf("%d", &K);
    // key代表指数，value代表系数
    double a[1001] = {0.0}, res[2001] = {0.0}; // res 数组大小要为2001
    // 输入第一组数据
    for(i = 0; i < K; i++){
        scanf("%d %lf", &exp, &coef);
        a[exp] += coef;
    }
    // 输入第二组数据，并进行运算
    scanf("%d", &K);
    for(i = 0; i < K; i++){
        scanf("%d %lf", &exp, &coef);
        // 和第一组数据中每一项相乘
        for(j = 0; j <= 1000; j++)
            res[exp + j] += coef * a[j];
    }

    for(int i = 0; i <= 2000; i++){
        if (res[i] != 0)
            count++;
    }
    // 输出结果
    printf("%d", count);
    for(i = 2000; i >= 0; i--){
        if(res[i] != 0)
            printf(" %d %.1lf", i, res[i]);
    }
    return 0;
}
```


------


## [A1010. Radix (25)](https://www.patest.cn/contests/pat-a-practise/1010)

Given a pair of positive integers, for example, 6 and 110, can this equation 6 = 110 be true? The answer is "yes", if 6 is a decimal number and 110 is a binary number.

Now for any pair of positive integers N1 and N2, your task is to find the radix of one number while that of the other is given.

**Input Specification:**

Each input file contains one test case. Each case occupies a line which contains 4 positive integers:

```
N1 N2 tag radix
```

Here N1 and N2 each has no more than 10 digits. A digit is less than its radix and is chosen from the set {0-9, a-z} where 0-9 represent the decimal numbers 0-9, and a-z represent the decimal numbers 10-35. The last number "radix" is the radix of N1 if "tag" is 1, or of N2 if "tag" is 2.

**Output Specification:**

For each test case, print in one line the radix of the other number so that the equation N1 = N2 is true. If the equation is impossible, print "Impossible". If the solution is not unique, output the smallest possible radix.

**Sample Input 1:**

```
6 110 1 10
```

**Sample Output 1:**

```
2
```

**Sample Input 2:**

```
1 ab 1 2
```

**Sample Output 2:**

```
Impossible
```

**未完全通过；`21/25`；[查看提交](https://www.patest.cn/submissions/3540156)**

```c
#include <iostream>
#include <string>
using namespace std;

int char2digit (char c) {
	if ('0' <= c && c <= '9') return c - '0';
	else return c - 'a' + 10;
}

int num2decimal (string num, int radix) {
	int base = 1, decimal = 0;
	for (int i = num.length() - 1; i >= 0; i--) {
		decimal += char2digit(num[i]) * base;
		base *= radix;
	}
	return decimal;
}

int main () {

	string n1, n2;
	int tag, radix, d1 = -1, d2 = -1;
	cin >> n1 >> n2 >> tag >> radix;
	if (tag == 1) {
		d1 = num2decimal(n1, radix);
		int i;
		for (i = 1; d2 < d1; i++)
			d2 = num2decimal(n2, i);
		if (d2 == d1) cout << i - 1 << endl;
		else cout << "Impossible" << endl;
	} else if (tag == 2) {
		d2 = num2decimal(n2, radix);
		int i;
		for (i = 1; d1 < d2; i++)
			d1 = num2decimal(n1, i);
		if (d1 == d2) cout << i - 1 << endl;
		else cout << "Impossible" << endl;
	}

	return 0;
}
```
