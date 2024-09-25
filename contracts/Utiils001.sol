// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Utils
 * @dev 提供实用的数学函数，例如对多个数组求和
 */
contract Utils {
    /**
     * @dev 计算多个 `uint` 数组中所有元素的总和。
     * @param arrays 一个包含多个 `uint[]` 数组的二维数组。
     * @return totalSum 所有数组中所有元素的总和。
     */
    function sum(uint[][] calldata arrays) external pure returns (uint totalSum) {
        // 遍历每一个传入的数组
        for (uint i = 0; i < arrays.length; i++) {
            uint[] calldata currentArray = arrays[i];
            // 遍历当前数组中的每一个元素并累加到 totalSum
            for (uint j = 0; j < currentArray.length; j++) {
                totalSum += currentArray[j];
            }
        }
    }
}
