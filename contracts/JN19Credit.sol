// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title JN19Credit
/// @notice Fake hackathon AI compute-credit token. It is an ERC-20 token named JN-19.
/// @dev For a real product, AI credits may need to be non-transferable/internal. This is a demo token only.
contract JN19Credit is ERC20, Ownable {
    mapping(address => bool) public claimed;

    constructor(address owner_) ERC20("JN-19 AI Credit", "JN19") Ownable(owner_) {
        _mint(owner_, 1_000_000 ether);
    }

    /// @notice Lets any demo user claim 1,000 fake JN19 credits once.
    function claim() external {
        require(!claimed[msg.sender], "Already claimed");
        claimed[msg.sender] = true;
        _mint(msg.sender, 1_000 ether);
    }

    /// @notice Demo action: spend credits on a fake AI request.
    function burnForAiUsage(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
