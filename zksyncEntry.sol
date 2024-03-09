// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title ZkSyncBridge
 * @dev Enables token transfers from the zkSync chain to Ethereum, offering secure and non-reentrant methods for token locking,
 * unlocking, depositing, and withdrawing. Uses low-level calls for ERC20 token transfers to increase gas efficiency.
 */
contract ZkSyncBridgeEntry is ReentrancyGuard {
    IERC20 public token;
    address public owner;
    address public evmContract; // Address of an existing EVM contract for delegation.

    event Locked(address indexed sender, uint256 amount);
    event Unlocked(address indexed recipient, uint256 amount);
    event DepositedToEthereum(address indexed sender, uint256 amount);
    event WithdrawnFromEthereum(address indexed recipient, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "ZkSyncBridge: Only the owner can call this function.");
        _;
    }

    /**
     * @dev Constructor to set initial token and EVM contract address.
     * @param _token ERC20 token to be used for transfers.
     * @param _evmContract External EVM contract address for delegation.
     */
    constructor(IERC20 _token, address _evmContract) {
        owner = msg.sender;
        token = _token;
        evmContract = _evmContract;
    }

    /**
     * @dev Locks tokens for transfer to Ethereum, callable by any token holder.
     * @param amount Amount of tokens to be locked.
     */
    function lockTokens(uint256 amount) external nonReentrant {
        require(token.transferFrom(msg.sender, address(this), amount), "ZkSyncBridge: Transfer failed");
        emit Locked(msg.sender, amount);
    }

    /**
     * @dev Unlocks tokens after transfer completion, callable only by the owner.
     * @param recipient Address to receive the unlocked tokens.
     * @param amount Amount of tokens to be unlocked.
     */
    function unlockTokens(address recipient, uint256 amount) external onlyOwner nonReentrant {
        _safeTransfer(token, recipient, amount);
        emit Unlocked(recipient, amount);
    }

    /**
     * @dev Deposits tokens to Ethereum, callable by any token holder.
     * @param amount Amount of tokens to be deposited.
     */
    function depositToEthereum(uint256 amount) external nonReentrant {
        require(token.transferFrom(msg.sender, address(this), amount), "ZkSyncBridge: Deposit failed");
        emit DepositedToEthereum(msg.sender, amount);
    }

    /**
     * @dev Withdraws tokens from Ethereum, callable only by the owner.
     * @param recipient Address to receive the withdrawn tokens.
     * @param amount Amount of tokens to be withdrawn.
     */
    function withdrawFromEthereum(address recipient, uint256 amount) external onlyOwner nonReentrant {
        _safeTransfer(token, recipient, amount);
        emit WithdrawnFromEthereum(recipient, amount);
    }

    /**
     * @dev Checks the available amount of tokens for withdrawal.
     * @return The available token balance in the contract.
     */
    function checkAvailableWithdrawAmount() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    /**
     * @dev Safely transfers tokens using a low-level call to prevent reentrancy and ensure ERC20 standard compliance.
     * @param _token ERC20 token interface.
     * @param _to Address to transfer tokens to.
     * @param _amount Amount of tokens to transfer.
     */
    function _safeTransfer(IERC20 _token, address _to, uint256 _amount) private {
        (bool success, bytes memory data) = address(_token).call(abi.encodeWithSelector(_token.transfer.selector, _to, _amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "ZkSyncBridge: Safe transfer failed");
    }
}
