// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// OpenZeppelin imports
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyFullERC20 is ERC20, ERC20Burnable, ERC20Pausable, Ownable {
    uint256 public maxSupply;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_,
        uint256 maxSupply_
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        require(initialSupply_ <= maxSupply_, "Initial exceeds max supply");
        maxSupply = maxSupply_;
        _mint(msg.sender, initialSupply_);
    }

    // Mint new tokens (only owner)
    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= maxSupply, "Exceeds max supply");
        _mint(to, amount);
    }

    // Pause all transfers (only owner)
    function pause() public onlyOwner {
        _pause();
    }

    // Resume transfers (only owner)
    function unpause() public onlyOwner {
        _unpause();
    }

    // Internal hook for Pausable + ERC20
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Pausable) {
        super._update(from, to, value);
    }
}
