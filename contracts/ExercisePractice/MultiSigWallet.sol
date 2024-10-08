// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// 多签钱包的功能: 合约有多个 owner，一笔交易发出后，需要多个 owner 确认，确认数达到最低要求数之后，才可以真正的执行。

// ### 1.原理

// - 部署时候传入地址参数和需要的签名数
//   - 多个 owner 地址
//   - 发起交易的最低签名数
// - 有接受 ETH 主币的方法，
// - 除了存款外，其他所有方法都需要 owner 地址才可以触发
// - 发送前需要检测是否获得了足够的签名数
// - 使用发出的交易数量值作为签名的凭据 ID（类似上么）
// - 每次修改状态变量都需要抛出事件
// - 允许批准的交易，在没有真正执行前取消。
// - 足够数量的 approve 后，才允许真正执行。




/**
 * @title MultiSigWallet
 * @dev A multi-signature wallet contract that requires multiple confirmations before executing transactions.
 */
contract MultiSigWallet {
    /* ========== STATE VARIABLES ========== */

    // Array of wallet owners
    address[] public owners;

    // Mapping to check if an address is an owner
    mapping(address => bool) public isOwner;

    // Number of confirmations required
    uint256 public required;

    // Struct representing a transaction
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmationCount;
        bool canceled;
    }

    // Array of all transactions
    Transaction[] public transactions;

    // Mapping from transaction ID => owner => bool (whether the owner has confirmed)
    mapping(uint256 => mapping(address => bool)) public confirmations;

    /* ========== EVENTS ========== */

    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event SubmitTransaction(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint256 value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);
    event CancelTransaction(address indexed owner, uint256 indexed txIndex);
    event RequirementChange(uint256 required);

    /* ========== MODIFIERS ========== */

    /**
     * @dev Throws if called by any account other than an owner.
     */
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    /**
     * @dev Throws if the transaction does not exist.
     * @param _txIndex Transaction index
     */
    modifier txExists(uint256 _txIndex) {
        require(_txIndex < transactions.length, "Transaction does not exist");
        _;
    }

    /**
     * @dev Throws if the transaction has already been executed.
     * @param _txIndex Transaction index
     */
    modifier notExecuted(uint256 _txIndex) {
        require(!transactions[_txIndex].executed, "Transaction already executed");
        _;
    }

    /**
     * @dev Throws if the transaction has been canceled.
     * @param _txIndex Transaction index
     */
    modifier notCanceled(uint256 _txIndex) {
        require(!transactions[_txIndex].canceled, "Transaction has been canceled");
        _;
    }

    /**
     * @dev Throws if the transaction has already been confirmed by the caller.
     * @param _txIndex Transaction index
     */
    modifier notConfirmed(uint256 _txIndex) {
        require(!confirmations[_txIndex][msg.sender], "Transaction already confirmed");
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    /**
     * @dev Initializes the contract with a list of owners and the number of required confirmations.
     * @param _owners List of initial owners
     * @param _required Number of required confirmations
     */
    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "Owners required");
        require(
            _required > 0 && _required <= _owners.length,
            "Invalid number of required confirmations"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;

        emit RequirementChange(_required);
    }

    /* ========== RECEIVE ETHER ========== */
    function deposit() public payable {
        require(msg.value > 0,unicode"存入金额需要大于0");
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    /**
     * @dev Fallback function to receive Ether.
     */
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    /**
     * @dev Allows an owner to submit a transaction.
     * @param _to Recipient address
     * @param _value Amount of Ether to send
     * @param _data Transaction data
     * @return txIndex The index of the submitted transaction
     */
    function submitTransaction(
        address _to,
        uint256 _value,
        bytes memory _data
    ) public onlyOwner returns (uint256 txIndex) {
        txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                confirmationCount: 0,
                canceled: false
            })
        );

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    /**
     * @dev Allows an owner to confirm a transaction.
     * @param _txIndex Transaction index
     */
    function confirmTransaction(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notCanceled(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        confirmations[_txIndex][msg.sender] = true;
        transaction.confirmationCount += 1;

        emit ConfirmTransaction(msg.sender, _txIndex);

        executeTransaction(_txIndex);
    }

    /**
     * @dev Executes a confirmed transaction.
     * @param _txIndex Transaction index
     */
    function executeTransaction(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notCanceled(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        if (transaction.confirmationCount >= required) {
            transaction.executed = true;

            (bool success, ) = transaction.to.call{value: transaction.value}(
                transaction.data
            );
            require(success, "Transaction failed");

            emit ExecuteTransaction(msg.sender, _txIndex);
        }
        
    }

    /**
     * @dev Allows an owner to revoke a confirmation for a transaction.
     * @param _txIndex Transaction index
     */
    function revokeConfirmation(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notCanceled(_txIndex)
    {
        require(confirmations[_txIndex][msg.sender], "Transaction not confirmed");

        Transaction storage transaction = transactions[_txIndex];
        confirmations[_txIndex][msg.sender] = false;
        transaction.confirmationCount -= 1;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    /**
     * @dev Allows an owner to cancel a transaction before it is executed.
     * @param _txIndex Transaction index
     */
    function cancelTransaction(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notCanceled(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.canceled = true;

        emit CancelTransaction(msg.sender, _txIndex);
    }

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @dev Returns the number of transactions.
     * @return Number of transactions
     */
    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }

    /**
     * @dev Returns details of a specific transaction.
     * @param _txIndex Transaction index
     * @return to Recipient address
     * @return value Amount of Ether
     * @return data Transaction data
     * @return executed Whether the transaction has been executed
     * @return confirmationCount Number of confirmations
     * @return canceled Whether the transaction has been canceled
     */
    function getTransaction(uint256 _txIndex)
        public
        view
        returns (
            address to,
            uint256 value,
            bytes memory data,
            bool executed,
            uint256 confirmationCount,
            bool canceled
        )
    {
        Transaction storage transaction = transactions[_txIndex];
        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.confirmationCount,
            transaction.canceled
        );
    }

    /**
     * @dev Returns whether an owner has confirmed a transaction.
     * @param _txIndex Transaction index
     * @param _owner Owner address
     * @return Confirmation status
     */
    function isConfirmed(uint256 _txIndex, address _owner)
        public
        view
        returns (bool)
    {
        return confirmations[_txIndex][_owner];
    }

    /**
     * @dev Returns the list of owners.
     * @return Array of owner addresses
     */
    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    /**
     * @dev Returns the number of required confirmations.
     * @return Number of required confirmations
     */
    function getRequired() public view returns (uint256) {
        return required;
    }
}
