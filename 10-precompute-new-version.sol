contract TestContract {
    address public owner;
    uint256 public foo;

    constructor(address _owner, uint256 _foo) payable {
        owner = _owner;
        foo = _foo;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Factory {
    // Returns the address of the newly deployed contract
    function deploy(address _owner, uint256 _foo, bytes32 _salt)
        public
        payable
        returns (address)
    {
        // This syntax is a newer way to invoke create2 without assembly, you just need to pass salt
        // https://docs.soliditylang.org/en/latest/control-structures.html#salted-contract-creations-create2
        return address(new TestContract{salt: _salt}(_owner, _foo));
    }
}
