// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 导入 OpenZeppelin 的 ERC721 实现
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

/**
 * @title MyERC721
 * @dev 一个简单的 ERC721 代币，用于测试目的
 */
contract MyERC721 is ERC721 {
    uint256 private _tokenIds;

    /**
     * @dev 构造函数，初始化代币名称和符号
     */
    constructor() ERC721("TestNFT", "TNFT") {}

    /**
     * @dev 铸造一个新的 ERC721 代币给指定地址
     * @param recipient 接收者的地址
     * @return tokenId 新铸造的代币 ID
     */
    function mint(address recipient) external returns (uint256) {
        _tokenIds += 1;
        uint256 newTokenId = _tokenIds;
        _mint(recipient, newTokenId);
        return newTokenId;
    }
}
