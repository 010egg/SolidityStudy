// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 导入 OpenZeppelin 的 Ownable 合约，用于管理合约所有者
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

// 导入 OpenZeppelin 的 IERC20 接口，用于与 ERC20 代币交互
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

// 导入 OpenZeppelin 的 IERC721 接口，用于与 ERC721 代币交互
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";

// 导入 OpenZeppelin 的 IERC721Receiver 接口，以便合约能够接收 ERC721 代币
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";

/**
 * @title Vault
 * @dev 一个简单的存储合约，允许任何人存入 ETH、ERC20 和 ERC721 代币，仅合约所有者可取出并销毁合约
 */
contract Vault is Ownable, IERC721Receiver {
    // 事件，用于记录存款行为
    event Deposited(address indexed sender, uint amount);
    event ERC20Deposited(address indexed sender, address indexed token, uint amount);
    event ERC721Deposited(address indexed sender, address indexed token, uint tokenId);

    // 事件，用于记录取款和销毁行为
    event Withdrawn(
        uint ethAmount,
        address[] erc20Tokens,
        uint[] erc20Amounts,
        address[] erc721Tokens,
        uint[] erc721TokenIds,
        address owner
    );
    /**
     * @dev Vault 合约的构造函数，传递 msg.sender 给 Ownable 构造函数作为初始所有者
     */
    constructor() Ownable(msg.sender) {
        // 你可以在这里添加其他初始化代码，如果需要
    }
    /**
     * @dev 接收 ETH 时触发的函数
     */
    receive() external payable {
        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @dev 存入 ETH 的函数
     */
    function depositETH() external payable {
        require(msg.value > 0, unicode"必须发送 ETH");
        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @dev 存入 ERC20 代币的函数
     * @param token ERC20 代币的合约地址
     * @param amount 转账的代币数量
     */
    function depositERC20(address token, uint amount) external {
        require(amount > 0, unicode"转账数量必须大于 0");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        emit ERC20Deposited(msg.sender, token, amount);
    }

    /**
     * @dev 存入 ERC721 代币的函数
     * @param token ERC721 代币的合约地址
     * @param tokenId 转账的代币 ID
     */
    function depositERC721(address token, uint tokenId) external {
        IERC721(token).safeTransferFrom(msg.sender, address(this), tokenId);
        emit ERC721Deposited(msg.sender, token, tokenId);
    }

    /**
     * @dev 取出所有存入的资产并销毁合约
     * @param erc20Tokens ERC20 代币的合约地址数组
     * @param erc20Amounts 对应 ERC20 代币的取出数量数组
     * @param erc721Tokens ERC721 代币的合约地址数组
     * @param erc721TokenIds 对应 ERC721 代币的 ID 数组
     */
    function withdraw(
        address[] calldata erc20Tokens,
        uint[] calldata erc20Amounts,
        address[] calldata erc721Tokens,
        uint[] calldata erc721TokenIds
    ) external onlyOwner {
        uint ethBalance = address(this).balance;

        // 取出 ETH
        if (ethBalance > 0) {
            payable(owner()).transfer(ethBalance);
        }

        // 验证 ERC20 数组长度
        require(erc20Tokens.length == erc20Amounts.length, unicode"ERC20 数组长度不匹配");

        // 取出 ERC20 代币
        for (uint i = 0; i < erc20Tokens.length; i++) {
            IERC20 token = IERC20(erc20Tokens[i]);
            uint amount = erc20Amounts[i];
            if (amount > 0) {
                require(token.transfer(owner(), amount), unicode"ERC20 转账失败");
            }
        }

        // 验证 ERC721 数组长度
        require(erc721Tokens.length == erc721TokenIds.length,unicode"ERC721 数组长度不匹配");

        // 取出 ERC721 代币
        for (uint i = 0; i < erc721Tokens.length; i++) {
            IERC721 token = IERC721(erc721Tokens[i]);
            uint tokenId = erc721TokenIds[i];
            token.safeTransferFrom(address(this), owner(), tokenId);
        }

        emit Withdrawn(
            ethBalance,
            erc20Tokens,
            erc20Amounts,
            erc721Tokens,
            erc721TokenIds,
            owner()
        );

        // 销毁合约并将剩余 ETH 转给所有者
        selfdestruct(payable(owner()));
    }

    /**
     * @dev 实现 IERC721Receiver 接口，以便合约能够接收 ERC721 代币
     */
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        // 返回 IERC721Receiver.onERC721Received.selector，表示接收成功
        return IERC721Receiver.onERC721Received.selector;
    }
}
