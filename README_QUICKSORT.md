# QuickSort Implementation in JavaScript

## Overview
This repository contains a comprehensive implementation of the QuickSort algorithm in JavaScript with multiple approaches and optimizations.

## Features

### 1. **Classic QuickSort** (`quickSort`)
- **Time Complexity**: O(n log n) average, O(n²) worst case
- **Space Complexity**: O(log n) average
- **In-place sorting** algorithm
- **Pivot selection**: Rightmost element
- **Partitioning**: Lomuto partition scheme

### 2. **Functional QuickSort** (`quickSortFunctional`)
- **Pure function** approach
- **Immutable** - doesn't modify original array
- **Easy to understand** and reason about
- **Suitable for functional programming** paradigms

### 3. **Custom Comparator QuickSort** (`quickSortWithComparator`)
- **Flexible sorting** with custom comparison functions
- **Supports complex objects** and custom sorting logic
- **Maintains stability** for equal elements

## Algorithm Details

### Partition Function
```javascript
function partition(arr, low, high) {
    const pivot = arr[high];
    let i = low - 1;
    
    for (let j = low; j < high; j++) {
        if (arr[j] <= pivot) {
            i++;
            [arr[i], arr[j]] = [arr[j], arr[i]];
        }
    }
    
    [arr[i + 1], arr[high]] = [arr[high], arr[i + 1]];
    return i + 1;
}
```

### Main QuickSort Function
```javascript
function quickSort(arr, low = 0, high = arr.length - 1) {
    if (low < high) {
        const pivotIndex = partition(arr, low, high);
        quickSort(arr, low, pivotIndex - 1);
        quickSort(arr, pivotIndex + 1, high);
    }
    return arr;
}
```

## Usage Examples

### Basic Sorting
```javascript
const arr = [64, 34, 25, 12, 22, 11, 90];
const sorted = quickSort([...arr]);
console.log(sorted); // [11, 12, 22, 25, 34, 64, 90]
```

### Custom Comparator
```javascript
const strings = ["apple", "banana", "cherry", "date"];
const sortedByLength = quickSortWithComparator(
    [...strings], 
    (a, b) => a.length - b.length
);
console.log(sortedByLength); // ["date", "apple", "banana", "cherry"]
```

### Functional Approach
```javascript
const arr = [9, 8, 7, 6, 5, 4, 3, 2, 1];
const sorted = quickSortFunctional([...arr]);
console.log(sorted); // [1, 2, 3, 4, 5, 6, 7, 8, 9]
```

## Performance Characteristics

| Scenario | Time Complexity | Space Complexity |
|----------|----------------|------------------|
| **Best Case** | O(n log n) | O(log n) |
| **Average Case** | O(n log n) | O(log n) |
| **Worst Case** | O(n²) | O(n) |
| **Already Sorted** | O(n²) | O(n) |
| **Reverse Sorted** | O(n²) | O(n) |

## Optimizations

### 1. **Pivot Selection**
- **Current**: Rightmost element (simple but can be suboptimal)
- **Potential improvements**: 
  - Median-of-three
  - Random pivot selection
  - Ninther method for large arrays

### 2. **Small Array Handling**
- **Current**: Recursive until base case
- **Potential improvement**: Use insertion sort for arrays < 10 elements

### 3. **Duplicate Handling**
- **Current**: Basic partitioning
- **Potential improvement**: Three-way partitioning for many duplicates

## Testing

Run the examples:
```bash
node quicksort.js
```

Expected output:
```
=== QuickSort Examples ===

Original array: [64, 34, 25, 12, 22, 11, 90]
Sorted array: [11, 12, 22, 25, 34, 64, 90]

Array with duplicates: [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
Sorted array: [1, 1, 2, 3, 3, 4, 5, 5, 5, 6, 9]

Reverse sorted array: [9, 8, 7, 6, 5, 4, 3, 2, 1]
Sorted using functional approach: [1, 2, 3, 4, 5, 6, 7, 8, 9]

String array: ["apple", "banana", "cherry", "date", "elderberry"]
Sorted by length: ["date", "apple", "banana", "cherry", "elderberry"]

Large array (10,000 elements)
Sorting time: XX.XXms
```

## Comparison with Built-in Sort

```javascript
// JavaScript built-in sort
const arr = [64, 34, 25, 12, 22, 11, 90];
arr.sort((a, b) => a - b);

// Our quicksort
const sorted = quickSort([...arr]);
```

**Advantages of our implementation:**
- **Educational value** - understand the algorithm
- **Customizable** - modify for specific needs
- **Predictable** - know exactly what's happening

**Advantages of built-in sort:**
- **Optimized** - highly tuned by JavaScript engines
- **Stable** - maintains order of equal elements
- **Maintained** - updated with engine improvements

## Future Improvements

1. **Hybrid approach** - combine with insertion sort for small arrays
2. **Random pivot selection** - improve worst-case performance
3. **Three-way partitioning** - better handling of duplicates
4. **Tail call optimization** - reduce stack space usage
5. **Parallel processing** - utilize multiple cores for large arrays

## License
This implementation is provided for educational purposes. Feel free to use and modify as needed.
