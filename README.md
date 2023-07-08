# world

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


### Min Heap (priority queue)

### Code

```cpp
class Solution {
public:
    int findKthLargest(vector<int>& nums, int k)
    {
        // min heap
        priority_queue<int, vector<int>, greater<int>> pq;
        int i = 0, n = nums.size();
        while (i < n) {
            pq.push(nums[i]);
            i++;
            if (pq.size() > k)
                pq.pop();
        }
        return pq.top();
    }
};
```
