// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// - 任何人都可以发送金额到合约

// - 只有 owner 可以取款
// - 3 种取钱方式
contract ThreewayGetETH {
    address payable public immutable owner;
        // 定义 Deposit 和 Withdrawal 事件
    event Deposit(address indexed account, uint256 amount);
    event Withdrawal(address indexed account, uint256 amount);
    
    function deposit() public payable {
        require(msg.value > 0,unicode"存入金额需要大于0");
        emit Deposit(msg.sender, msg.value);
    }

     /**
     * @dev Sets the deployer as the initial owner.
     */
    constructor() {
        owner = payable(msg.sender);
    }

    /**
     * @dev Modifier to restrict functions to contract owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function sendWithdraw(uint256 amount) payable external onlyOwner {
        require(address(this).balance >= amount, unicode"余额不足");
        bool success = payable(msg.sender).send(200);
        require(success, "Send Failed");
        emit Withdrawal(msg.sender, amount);
    }

    function transferWithdraw(uint256 amount) payable external onlyOwner {
        require(address(this).balance >= amount, unicode"余额不足");
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function callWithdraw(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, unicode"余额不足");
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Call Failed");
        emit Withdrawal(msg.sender, amount);
    }
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

}
