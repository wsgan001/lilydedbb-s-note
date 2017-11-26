## [【Lintcode】Longest Words](http://www.lintcode.com/en/problem/longest-words/)

Given a dictionary, find all of the longest words in the dictionary.

Example

Given

```
{
  "dog",
  "google",
  "facebook",
  "internationalization",
  "blabla"
}
```

the longest words are(is) `["internationalization"]`.

Given

```
{
  "like",
  "love",
  "hate",
  "yes"
}
```

the longest words are `["like", "love", "hate"]`.

```c
class Solution {
public:
    /**
     * @param dictionary: a vector of strings
     * @return: a vector of strings
     */
    vector<string> longestWords(vector<string> &dictionary) {
        // write your code here
        vector<string> result;
        stack<string> s;
        for (int i = 0; i < dictionary.size(); i++) {
            if (s.empty() || dictionary[i].length() > s.top().length()) {
                while (!s.empty()) s.pop();
            } else if (dictionary[i].length() < s.top().length()) { continue; }
            s.push(dictionary[i]);
        }
        while (!s.empty()) {
            result.push_back(s.top());
            s.pop();
        }
        return result;
    }
};
```