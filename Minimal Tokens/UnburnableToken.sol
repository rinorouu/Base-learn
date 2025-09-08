// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract UnburnableToken {
    // Storage variables
    mapping(address => uint256) public balances;
    uint256 public totalSupply;
    uint256 public totalClaimed;
    mapping(address => bool) public hasClaimed;

    // Constants
    uint256 public constant CLAIM_AMOUNT = 1000; // Without decimals

    // Errors
    error TokensClaimed();
    error AllTokensClaimed();
    error UnsafeTransfer(address recipient);

    // Constructor - sets total supply to 100,000,000 (without decimals)
    constructor() {
        totalSupply = 100_000_000; // Without decimals
    }

    // Claim function - user can claim exactly once
    function claim() public {
        // Check if wallet has already claimed
        if (hasClaimed[msg.sender]) {
            revert TokensClaimed();
        }

        // Check if all tokens have been claimed
        if (totalClaimed + CLAIM_AMOUNT > totalSupply) {
            revert AllTokensClaimed();
        }

        // Update balances and state
        balances[msg.sender] += CLAIM_AMOUNT;
        totalClaimed += CLAIM_AMOUNT;
        hasClaimed[msg.sender] = true; // Mark as claimed
    }

    // Safe Transfer function
    function safeTransfer(address _to, uint256 _amount) public {
        // Check for zero address
        if (_to == address(0)) {
            revert UnsafeTransfer(_to);
        }

        // Check if recipient has balance > 0 Base Sepolia Eth
        if (_to.balance == 0) {
            revert UnsafeTransfer(_to);
        }

        // Check if sender has enough tokens
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        // Perform transfer
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }

    // Helper function to check if an address has claimed
    function hasAddressClaimed(address _address) public view returns (bool) {
        return hasClaimed[_address];
    }

    // Helper function to get remaining claimable tokens
    function getRemainingTokens() public view returns (uint256) {
        return totalSupply - totalClaimed;
    }
}
