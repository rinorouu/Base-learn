
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EmployeeStorage {
    uint256 public idNumber;
    uint32 private salary;
    uint16 private shares;
    string public name;

    constructor(uint16 _shares, string memory _name, uint32 _salary, uint256 _idNumber) {
        shares = _shares;
        name = _name;
        salary = _salary;
        idNumber = _idNumber;
    }

    function viewSalary() public view returns (uint32) {
        return salary;
    }

    function viewShares() public view returns (uint16) {
        return shares;
    }

    error TooManyShares(uint16 totalShares);

    function grantShares(uint16 _newShares) external {
        require(_newShares <= 5000, "Too many shares");

        uint16 totalShares = shares + _newShares;

        if (totalShares > 5000) {
            revert TooManyShares(totalShares);
        }

        shares = totalShares;
    }
    function checkForPacking(uint _slot) public view returns (uint r) {
        assembly {
            r := sload(_slot)
        }
    }

    function debugResetShares() public {
        shares = 1000;
    }
}
