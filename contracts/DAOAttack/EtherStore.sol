// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;

contract EtherStore {
    uint256 public withdrawalLimit = 1 ether;
    mapping(address => uint256) public lastWithdrawTime;
    mapping(address => uint256) public balances;

    function depositFunds() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawFunds(uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw, unicode"余额不足");
        require(_weiToWithdraw <= withdrawalLimit, unicode"超出提现限额");
        require(block.timestamp >= lastWithdrawTime[msg.sender] + 1 weeks, unicode"提现冷却时间未到");



        (bool success, ) = msg.sender.call{value: _weiToWithdraw}("");
                balances[msg.sender] -= _weiToWithdraw;
        lastWithdrawTime[msg.sender] = block.timestamp;
        require(success, unicode"转账失败");
    }
}
