// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 导入 OpenZeppelin 的 ERC20 实现
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

/**
 * @title MyERC20
 * @dev 一个简单的 ERC20 代币，用于测试目的
 */
contract MyERC20 is ERC20 {
    /**
     * @dev 构造函数，初始化代币名称、符号和总供应量
     * @param initialSupply 初始供应量，以最小单位计（如 18 位小数）
     */
    constructor(uint256 initialSupply) ERC20("TestToken", "TTK") {
        _mint(msg.sender, initialSupply);
    }
}
