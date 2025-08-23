// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/proxy/Clones.sol";

/*
 * Implementation (Logic) contract
 * Yeh asal business logic rakhta hai
 */
contract TestImplementation {
    uint256 public value;

    function setValue(uint256 _value) external {
        value = _value;
    }
}

/*
 * Minimal Proxy (Clone) Factory
 * Clones library ke zariye EIP-1167 proxy deploy karta hai
 */
contract MinimalProxyFactory {
    using Clones for address;

    event ProxyDeployed(address proxy);

    address public implementation;

    constructor(address _implementation) {
        implementation = _implementation;
    }

    // Simple clone
    function createClone() external returns (address proxy) {
        proxy = implementation.clone(); // minimal proxy create
        emit ProxyDeployed(proxy);
    }

    // Deterministic clone (CREATE2 ke sath)
    function createCloneDeterministic(bytes32 salt) external returns (address proxy) {
        proxy = implementation.cloneDeterministic(salt);
        emit ProxyDeployed(proxy);
    }

    // Precompute deterministic address
    function predictDeterministicAddress(bytes32 salt) external view returns (address) {
        return implementation.predictDeterministicAddress(salt, address(this));
    }
}
