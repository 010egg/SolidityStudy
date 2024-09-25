// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Loop {
    uint256[] public arr= [0];
    function loop() public returns (uint256[] memory){
        // for loop
        for (uint256 i = 0; i < 10; i++) {
            if (i == 3) {
                // Skip to next iteration with continue
                continue;
            }

            if (i == 5) {
                // Exit loop with break
                break;
            }
             arr.push(i);
        }

        // while loop
        uint256 j;
        while (j < 10) {
            j++;
            arr.push(j);
        }
    return arr;
    }
}