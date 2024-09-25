// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract DataLocations {
    uint256[] public arr;
    mapping(uint256 => address) map;

    struct MyStruct {
        uint256 foo;
        string bar;

    }

    mapping(uint256 => MyStruct) myStructs;
      // 事件声明
    event ElementAdded(uint256 index, uint256 value);
    event ElementRemoved(uint256 index, uint256 value);
    event StructUpdated(uint256 id, uint256 newFoo, string newBar);
    event MappingUpdated(uint256 key, address newValue);
        // 修改结构体的内容
    function updateStruct(uint256 id, uint256 newFoo, string memory newBar) public {
        MyStruct storage myStruct = myStructs[id];
        myStruct.foo = newFoo;
        myStruct.bar = newBar;
        emit StructUpdated(id, newFoo, newBar);
    }
    function addToArray(uint256 value) public {
        arr.push(value);
        emit ElementAdded(arr.length - 1, value);
    }
    function removeFromArray(uint256 index) public {
        require(index < arr.length, "Index out of bounds");
        uint256 value = arr[index];
        arr[index] = arr[arr.length - 1];
        arr.pop();
        emit ElementRemoved(index, value);
    }

    // 更新映射
    function updateMapping(uint256 key, address newValue) public {
        map[key] = newValue;
        emit MappingUpdated(key, newValue);
    }

    // 获取结构体信息
    function getStruct(uint256 id) public view returns (uint256, string memory) {
        MyStruct storage myStruct = myStructs[id];
        return (myStruct.foo, myStruct.bar);
    }

    // 传递 memory 数组进行操作
    function processMemoryArray(uint256[] memory _arr) public pure returns (uint256 sum) {
        for (uint256 i = 0; i < _arr.length; i++) {
            sum += _arr[i];
        }
                return sum;

    }

    // 接收 calldata 数组进行只读操作
    function processCalldataArray(uint256[] calldata _arr) public  pure returns (uint256 sum) {
        for (uint256 i = 0; i < _arr.length; i++) {
            sum += _arr[i];
        }
        return sum;
    }



    function f() public {
        // call _f with state variables
        _f(arr, map, myStructs[1]);
        // 获取结构体并修改
        MyStruct storage myStruct = myStructs[1];
        myStruct.foo = 10;
        myStruct.bar = "Hello";

        // 创建 memory 结构体并修改，不会持久化到连上
        MyStruct memory myMemStruct = MyStruct(20, "Memory Struct");
    }

    function _f (
        uint256[] storage _arr,
        mapping(uint256 => address) storage _map,
        MyStruct storage _myStruct
    ) internal {
        // do something with storage variables
        _arr.push(100);
        _map[100] = msg.sender;
        _myStruct.foo = 100;
        _myStruct.bar = "Updated";
    }

    // You can return memory variables
    function g(uint256[] memory _arr) public pure returns (uint256[] memory) {
    // do something with memory array
        for (uint256 i = 0; i < _arr.length; i++) {
            _arr[i] *= 2;
        }
        return _arr;
    }

    function h(uint256[] calldata _arr) external pure returns (uint256){
        // do something with calldata array
        return processCalldataArray(_arr);

    }
}