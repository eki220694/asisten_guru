/**
 * QuickSort Implementation in JavaScript
 * Time Complexity: O(n log n) average, O(n²) worst case
 * Space Complexity: O(log n) average
 */

/**
 * Partitions the array around a pivot element
 * @param {Array} arr - The array to partition
 * @param {number} low - Starting index
 * @param {number} high - Ending index
 * @returns {number} - The pivot index
 */
function partition(arr, low, high) {
    // Choose the rightmost element as pivot
    const pivot = arr[high];
    
    // Index of smaller element
    let i = low - 1;
    
    // Compare each element with pivot
    for (let j = low; j < high; j++) {
        // If current element is smaller than or equal to pivot
        if (arr[j] <= pivot) {
            i++; // Increment index of smaller element
            [arr[i], arr[j]] = [arr[j], arr[i]]; // Swap elements
        }
    }
    
    // Place pivot in correct position
    [arr[i + 1], arr[high]] = [arr[high], arr[i + 1]];
    
    return i + 1;
}

/**
 * Main quicksort function
 * @param {Array} arr - The array to sort
 * @param {number} low - Starting index (default: 0)
 * @param {number} high - Ending index (default: arr.length - 1)
 * @returns {Array} - The sorted array
 */
function quickSort(arr, low = 0, high = arr.length - 1) {
    if (low < high) {
        // Find pivot element
        const pivotIndex = partition(arr, low, high);
        
        // Recursively sort elements before and after pivot
        quickSort(arr, low, pivotIndex - 1);
        quickSort(arr, pivotIndex + 1, high);
    }
    
    return arr;
}

/**
 * Alternative quicksort implementation using functional programming approach
 * @param {Array} arr - The array to sort
 * @returns {Array} - The sorted array
 */
function quickSortFunctional(arr) {
    if (arr.length <= 1) {
        return arr;
    }
    
    const pivot = arr[Math.floor(arr.length / 2)];
    const left = arr.filter(x => x < pivot);
    const middle = arr.filter(x => x === pivot);
    const right = arr.filter(x => x > pivot);
    
    return [...quickSortFunctional(left), ...middle, ...quickSortFunctional(right)];
}

/**
 * Quicksort with custom comparator function
 * @param {Array} arr - The array to sort
 * @param {Function} compareFn - Comparison function (a, b) => number
 * @returns {Array} - The sorted array
 */
function quickSortWithComparator(arr, compareFn = (a, b) => a - b) {
    if (arr.length <= 1) {
        return arr;
    }
    
    const pivot = arr[Math.floor(arr.length / 2)];
    const left = arr.filter(x => compareFn(x, pivot) < 0);
    const middle = arr.filter(x => compareFn(x, pivot) === 0);
    const right = arr.filter(x => compareFn(x, pivot) > 0);
    
    return [...quickSortWithComparator(left, compareFn), ...middle, ...quickSortWithComparator(right, compareFn)];
}

// Example usage and testing
function runExamples() {
    console.log("=== QuickSort Examples ===\n");
    
    // Example 1: Basic sorting
    const arr1 = [64, 34, 25, 12, 22, 11, 90];
    console.log("Original array:", arr1);
    const sorted1 = quickSort([...arr1]);
    console.log("Sorted array:", sorted1);
    console.log();
    
    // Example 2: Array with duplicates
    const arr2 = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5];
    console.log("Array with duplicates:", arr2);
    const sorted2 = quickSort([...arr2]);
    console.log("Sorted array:", sorted2);
    console.log();
    
    // Example 3: Functional approach
    const arr3 = [9, 8, 7, 6, 5, 4, 3, 2, 1];
    console.log("Reverse sorted array:", arr3);
    const sorted3 = quickSortFunctional([...arr3]);
    console.log("Sorted using functional approach:", sorted3);
    console.log();
    
    // Example 4: Custom comparator (sort strings by length)
    const arr4 = ["apple", "banana", "cherry", "date", "elderberry"];
    console.log("String array:", arr4);
    const sorted4 = quickSortWithComparator([...arr4], (a, b) => a.length - b.length);
    console.log("Sorted by length:", sorted4);
    console.log();
    
    // Example 5: Performance test
    const largeArray = Array.from({length: 10000}, () => Math.floor(Math.random() * 1000));
    console.log("Large array (10,000 elements)");
    
    const start = performance.now();
    quickSort([...largeArray]);
    const end = performance.now();
    
    console.log(`Sorting time: ${(end - start).toFixed(2)}ms`);
}

// Export functions for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        quickSort,
        quickSortFunctional,
        quickSortWithComparator,
        partition
    };
}

// Run examples if this file is executed directly
if (typeof window === 'undefined' && require.main === module) {
    runExamples();
}
