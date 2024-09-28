// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

// Make sure EVM version and VM set to Cancun

// Storage - data is stored on the blockchain
// Memory - data is cleared out after a function call
// Transient storage - data is cleared out after a transaction

interface ITest {
    event TestCalled(address caller);  // 定义事件，记录调用者地址
    function val() external view returns (uint256);
    function test() external;
}

contract Callback {
    uint256 public val;
    //如果检测到不存在的函数签名，就让sender实现接口的方法
    fallback() external {
    //调用 Callback 合约时，msg.sender 必须是一个实现了 ITest 接口的合约，否则会出现错误。
     // 使用接口调用 sender 合约的 val() 函数
     // 将 msg.sender 转换为 ITest 类型！！！
     //编译器不会验证 target 实际上是否实现了 ITest 接口。
     //你可以通过接口调用合约的函数，只要该合约实现了接口中的函数。
        val = ITest(msg.sender).val();
    }

    function test(address target) external {
        // 告诉编译器将 target 地址视为实现了 ITest 接口的合约。
        // 并使用接口调用 target 合约的 test() 函数
        ITest(target).test();
    }
}

contract TestStorage {
    uint256 public val;

    function test() public {
        val = 123;
        bytes memory b = "";
        msg.sender.call(b);
    }
}

contract TestTransientStorage {
    bytes32 constant SLOT = 0;

    function test() public {
        assembly {
            tstore(SLOT, 321)
        }
        bytes memory b = "";
        msg.sender.call(b);
    }

    function val() public view returns (uint256 v) {
        assembly {
            v := tload(SLOT)
        }
    }
}

contract ReentrancyGuard {
    bool private locked;

    modifier lock() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    // 35313 gas
    function test() public lock {
        // Ignore call error
        bytes memory b = "";
        msg.sender.call(b);
    }
}

contract ReentrancyGuardTransient {
    bytes32 constant SLOT = 0;

    modifier lock() {
        assembly {
            if tload(SLOT) { revert(0, 0) }
            tstore(SLOT, 1)
        }
        _;
        assembly {
            tstore(SLOT, 0)
        }
    }

    // 21887 gas
    function test() external lock {
        // Ignore call error
        bytes memory b = "";
        msg.sender.call(b);
    }
}