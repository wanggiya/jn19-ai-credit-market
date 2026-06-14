// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title MockUSDC
/// @notice Fake hackathon stablecoin. Not real USDC/USDT. For local/testnet demos only.
contract MockUSDC is ERC20, Ownable {
    mapping(address => bool) public claimed;

    constructor(address owner_) ERC20("Mock USD Coin", "mUSDC") Ownable(owner_) {
        _mint(owner_, 1_000_000 ether);
    }

    /// @notice Keeps 18 decimals to make the hackathon frontend simpler.
    /// Real USDC uses 6 decimals, but this mock token is just for demo.
    function claim() external {
        require(!claimed[msg.sender], "Already claimed");
        claimed[msg.sender] = true;
        _mint(msg.sender, 1_000 ether);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
