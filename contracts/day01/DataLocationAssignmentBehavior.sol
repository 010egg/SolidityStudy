// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

contract C {
    uint[] x;

    // 定义一个事件，用于输出数组的长度
    event ArrayOperation(string description, uint length);

    function f(uint[] memory memoryArray) public {
        x = memoryArray; // 赋值整个数组（memory）给 x(storage)
        emit ArrayOperation("Assigned memoryArray to x, new length:", x.length);

        uint[] storage y = x; // 赋值了指针、也就是引用地址给y（storage）
        y.pop(); // 通过y来修改x，因为x是y的引用传递
        emit ArrayOperation("Called pop on y, new length of x:", x.length);

        delete x; // 清空x的同时，也把y清空了
        emit ArrayOperation("Deleted x, new length:", x.length);

        // 下面的代码是注释掉的，因为它们不工作
        // y = memoryArray;
        // delete y;

        g(x); // 调用g，传递x的引用
        h(x); // 调用h，创建x的一个独立临时拷贝
    }

    function g(uint[] storage) internal pure {}
    function h(uint[] memory) public pure {}
}
