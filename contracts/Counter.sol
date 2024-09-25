// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;
// Here is a simple contract that you can get, increment and decrement the count store in this contract.
contract Counter {
    int256 public cnt = 0;
    function getcnt() public view  returns (int256){
        return cnt;

    }
    function inccnt() public returns (int256){
       return  cnt+=1;
    }
    function deccnt() public  returns (int256){
        return cnt-=1;
    }

}