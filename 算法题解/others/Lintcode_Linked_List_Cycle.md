## [【Lintcode】Linked List Cycle](http://www.lintcode.com/en/problem/linked-list-cycle/)

Given a linked list, determine if it has a cycle in it.

Example

Given `-21->10->4->5`, tail connects to node index 1, return `true`

**Follow up:**

**Can you solve it without using extra space?**

```c
/**
 * Definition of ListNode
 * class ListNode {
 * public:
 *     int val;
 *     ListNode *next;
 *     ListNode(int val) {
 *         this->val = val;
 *         this->next = NULL;
 *     }
 * }
 */
class Solution {
public:
    /**
     * @param head: The first node of linked list.
     * @return: True if it has a cycle, or false
     */
    bool hasCycle(ListNode *head) {
        // write your code here
        if (!head || !head->next) return false;
        ListNode *slow = head, *fast= head;
        while (slow->next && fast->next && fast->next->next) {
            slow = slow->next;
            fast = fast->next->next;
            if (slow == fast) return true;
        }
        return false;
    }
};
```