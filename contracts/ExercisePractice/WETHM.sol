// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title WETH - Wrapped ETH ERC20 Token with Ownership
 * @dev This contract allows users to wrap ETH into an ERC20 compatible token and unwrap it back to ETH.
 *      It also includes functionality to authorize external accounts to spend the contract's tokens.
 */
contract WETH {
    // ERC20 standard variables
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;
    uint256 private _totalSupply;

    // Mappings for balances and allowances
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Owner of the contract
    address public owner;

    // ERC20 Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    // WETH specific events (optional)
    event Deposit(address indexed account, uint256 amount);
    event Withdrawal(address indexed account, uint256 amount);

    /**
     * @dev Modifier to restrict functions to contract owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "WETH: Caller is not the owner");
        _;
    }

    /**
     * @dev Sets the deployer as the initial owner.
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Returns the total supply of WETH tokens.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the WETH balance of a specific address.
     * @param account The address to query the balance of.
     */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Returns the remaining number of tokens that `spender` is allowed to spend on behalf of `owner`.
     * @param owner_ The address which owns the funds.
     * @param spender The address which will spend the funds.
     */
    function allowance(address owner_, address spender) external view returns (uint256) {
        return _allowances[owner_][spender];
    }

    /**
     * @dev Approves `spender` to spend `amount` on behalf of the caller.
     * Emits an {Approval} event.
     * @param spender The address which will spend the funds.
     * @param amount The number of tokens to be spent.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "WETH: approve to the zero address");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev Transfers `amount` tokens from the caller's account to `recipient`.
     * Emits a {Transfer} event.
     * @param recipient The address to transfer to.
     * @param amount The number of tokens to transfer.
     */
    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev Transfers `amount` tokens from `sender` to `recipient` using the allowance mechanism.
     * `amount` is then deducted from the caller's allowance.
     * Emits a {Transfer} and possibly an {Approval} event.
     * @param sender The address to transfer from.
     * @param recipient The address to transfer to.
     * @param amount The number of tokens to transfer.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "WETH: transfer amount exceeds allowance");
        
        _allowances[sender][msg.sender] = currentAllowance - amount;
        emit Approval(sender, msg.sender, _allowances[sender][msg.sender]);
        
        _transfer(sender, recipient, amount);
        return true;
    }

    /**
     * @dev Internal function to handle transfers between addresses.
     * @param sender The address sending tokens.
     * @param recipient The address receiving tokens.
     * @param amount The number of tokens to transfer.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "WETH: transfer from the zero address");
        require(recipient != address(0), "WETH: transfer to the zero address");
        require(_balances[sender] >= amount, "WETH: transfer amount exceeds balance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Allows users to deposit ETH and mint WETH tokens.
     * The contract must be able to receive ETH, so this function is payable.
     * Emits a {Deposit} and {Transfer} event.
     */
    function deposit() public  payable {
        require(msg.value > 0, "WETH: deposit amount must be greater than zero");

        _balances[msg.sender] += msg.value;
        _totalSupply += msg.value;

        emit Deposit(msg.sender, msg.value);
        emit Transfer(address(0), msg.sender, msg.value);
    }

    /**
     * @dev Allows users to withdraw their WETH tokens and receive ETH.
     * Emits a {Withdrawal} and {Transfer} event.
     * @param amount The number of WETH tokens to withdraw.
     */
    function withdraw(uint256 amount) external {
        require(_balances[msg.sender] >= amount, "WETH: withdraw amount exceeds balance");

        _balances[msg.sender] -= amount;
        _totalSupply -= amount;

        // Transfer ETH back to the user
        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    /**
     * @dev Fallback function to receive ETH. Calls the deposit function.
     */
    receive() external payable {
        deposit();
    }

    /**
     * @dev Allows the contract owner to approve a spender to spend the contract's tokens.
     * @param spender The address which will spend the tokens.
     * @param amount The number of tokens to approve.
     * @return success A boolean indicating if the operation succeeded.
     */
    function approveSpender(address spender, uint256 amount) external onlyOwner returns (bool success) {
        require(spender != address(0), "WETH: approve to the zero address");

        _allowances[address(this)][spender] = amount;
        emit Approval(address(this), spender, amount);
        return true;
    }
}
