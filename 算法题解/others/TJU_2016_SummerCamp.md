# [【Tianjin University OJ】2016 Summer Camp](http://acm.tju.edu.cn/toj/contest/contest186.html)

## [A. reverse word](http://acm.tju.edu.cn/toj/contest/showp186_A.html)

This summer is hot. So I do some boring things when bored.

It is very simple. Just reverse a word! Get more information from the sample.

Input

The first line a number n indicates the number of cases,1≤n≤20.

Then n lines followed, each line contains a word. The length of each word is large than 1 and less then 100.

Output

For each word, reverse the word after reversing for a line.

Sample Input

```
3
sample
input
word
```

Sample Output

```
elpmas
tupni
drow
```

```c
#include <cstdio>
#include <iostream>
#include <string>
using namespace std;

void reverse_word (string &str) {
	int n = str.length() - 1;
	char temp;
	for (int i = 0; i < n / 2; i++) {
		temp = str[i];
		str[i] = str[n - i];
		str[n - i] = temp;
	}
}

int main () {

	freopen("data1.txt", "r", stdin);
	int n;
	string str;
	scanf("%d", &n);
	for (int i = 0; i < n; i++) {
		cin >> str;
		reverse_word(str);
		printf("%s\n", str.c_str());
	}
 	return 0;
}
```

## [B. number mod](http://acm.tju.edu.cn/toj/contest/showp186_B.html)

There is a nonnegative integer nn, and the length of nn ≤≤ 106106, please output nn;

Input

The first line contains an integer TT (1≤T≤201≤T≤20), denoting the number of test cases.

Each test case contain a integer nn.

Output

Output the answer in a line for each test case .

Sample Input

```
2
1
123
```

Sample Output

```
1
6
```

```c
#include <cstdio>
#include <iostream>
#include <string>
using namespace std;

int main () {

	freopen("data2.txt", "r", stdin);
	int n, sum = 0;
	string s;
	scanf("%d", &n);
	for (int i = 0; i < n; i++) {
		sum = 0;
		cin >> s;
		for (int j = 0; j < s.length(); j++) sum += s[j] - '0';
		printf("%d\n", sum);
	}
	return 0;
}
```

## [C. same picture](http://acm.tju.edu.cn/toj/contest/showp186_C.html)

I have some pictures, some of them are same. And the colors are only black and white.

So I want to make a chanllenge to you. You need to distinguish whether two pictures are same or not.

Note that each picture can be rotated.

Get more information from the sample.

Input

A number n(1≤n≤101≤n≤10) indicate the number of cases.

Then for each case, two matrix stands for the pictures. Each picture is a 5 X 5 matrix only contains 0(black) or 1(white).
Output

Output 'Yes' if the two picture are same or 'No' otherwise.

Sample Input

```
2
11111
00000
00000
00000
00000

10000
10000
10000
10000
10000

10000
10000
10000
10000
10000

00010
00001
00001
00001
00001
```

Sample Output

```
Yes
No
```

```c
#include <cstdio>
#include <iostream>
#include <vector>
#include <string>
using namespace std;

bool isSame (vector<vector<int>> pic1, vector<vector<int>> pic2) {
	vector<vector<int>> rotate(5, vector<int>(5));
	for (int k = 0; k < 3; k++) {
		for (int i = 0; i < 5; i++)
			for (int j = 0; j < 5; j++)
				rotate[i][j] = pic1[j][4 - i];\

		bool flag = true;
		for (int i = 0; i < 5; i++)
			for (int j = 0; j < 5; j++)
				if (rotate[i][j] != pic2[i][j]) flag = false;
		if (flag) return true;

		pic1 = rotate;
	}
	return false;
}

int main () {

	freopen("data3.txt", "r", stdin);
	int n;
	vector<vector<int>> pic1(5, vector<int>(5)), pic2(5, vector<int>(5));
	scanf("%d", &n);
	string row;
	for (int k = 0; k < n; k++) {
		for (int i = 0; i < 5; i++) {
			cin >> row;
			for (int j = 0; j < 5; j++)
				pic1[i][j] = (int)(row[j] - '0');
		}
		for (int i = 0; i < 5; i++) {
			cin >> row;
			for (int j = 0; j < 5; j++)
				pic2[i][j] = (int)(row[j] - '0');
		}
		if (isSame(pic1, pic2)) printf("Yes\n");
		else printf("No\n");
	}
	return 0;
}
```

## [D.game](http://acm.tju.edu.cn/toj/contest/showp186_D.html)

Alice and Bob like game. They often play the game together.

Today, they are playing a card game. At first, there are NN cards on table. Each cards have a number. The rules of this game is follow:

First, Alice choose one card from the first card and the last card.

And then Bob choose one card from the first card and the last card of the remaning N−1N−1 cards.

And then Alice choose one card from the first card and the last card of the remaning N−2N−2 cards.

...end until there is no card.

they can get points from the number on the cards. The winner whose point is most.

For example, there are 3 cards, 3 7 5. First, Alice can choose 3 and 5. Alice choose 5, and then Bob can choose 3 and 7, Bob choose 7, and then Alice choose 3. The point of Alice is 8, and point of Bob is 7. So Alice is winner, and the difference of points is 1.

Now, give you NN cards. We can assume that Alice and Bob are very smart, you need tell us the difference of the point of Alice and Bob.

Input

The input consists of multiple test cases. The first line contains an integer TT, indicating the number of test cases.(1≤T≤10)(1≤T≤10)

Each case contains two lines, the first line contains one integer NN, means the number of cards.(1≤N≤20)(1≤N≤20)

The second contains NN positive numbers means the point on the card. the point on the card is less than 104104

Output

For each case output the difference of points of Alice and Bob

Sample Input

```
3
3
3 10 5
4
3 7 8 5
4
1 1 1 1
```

Sample Output

```
-2
1
0
```

```c
#include <cstdio>
#include <iostream>
#include <vector>
using namespace std;

int main () {
	freopen("data4.txt", "r", stdin);
	int n, m;
	scanf("%d", &n);
	for (int i = 0; i < n; i++) {
		scanf("%d", &m);
		vector<int> cards(m);
		for (int j = 0; j < m; j++)
			scanf("%d", &cards[j]);
		int l = 0, r = m - 1, index;
		int alice = 0, bob = 0;
		bool turn = true;
		while (l <= r) {
			if (cards[l] > cards[r]) { index = l; l++; }
			else { index = r; r--; }
			if (turn) alice += cards[index];
			else bob += cards[index];
			turn = !turn;
		}

		printf("%d\n", alice - bob);
	}
	return 0;
}
```