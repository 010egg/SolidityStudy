// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入 OpenZeppelin 的 ERC20 实现
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Wrapped ETH (WETH) 合约
 * @dev 将 ETH 包装为 ERC20 代币，使其能够与 ERC20 兼容的去中心化应用和交易所交互。
 */
contract WETH is ERC20 {
    // 定义 Deposit 和 Withdrawal 事件
    event Deposit(address indexed account, uint256 amount);
    event Withdrawal(address indexed account, uint256 amount);

    /**
     * @dev 构造函数，设置代币名称和符号。
     */
    constructor() ERC20("Wrapped ETH", "WETH") {}

    /**
     * @dev 存入 ETH 并铸造等量的 WETH。
     *      用户调用此函数并发送 ETH，合约将根据发送的 ETH 数量铸造相应数量的 WETH。
     */
    function deposit() public  payable {
        require(msg.value > 0, unicode"必须存入至少1 wei的ETH");
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev 销毁指定数量的 WETH 并返还等量的 ETH 给调用者。
     * @param amount 要取出的 WETH 数量（单位：wei）。
     */
    function withdraw(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, unicode"余额不足");
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    /**
     * @dev 接收 ETH 并自动调用 deposit() 函数，将其包装为 WETH。
     */
    receive() external payable {
        deposit();
    }
}
