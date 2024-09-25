// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Utils {

    function sum(uint[][] calldata arrays) external pure  returns (uint totol_sum) {
        for (uint i = 0; i< arrays.length; i++){
            uint[] calldata arrays_current = arrays[i];

            for (uint j = 0; j< arrays_current.length; j++){
                totol_sum += arrays_current[j];

            }

        }

        // return totol_sum;
    }
}