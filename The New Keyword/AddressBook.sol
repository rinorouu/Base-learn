
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title AddressBook
/// @notice Address book that only the owner can modify
contract AddressBook is Ownable {
    struct Contact {
        uint256 id;
        string firstName;
        string lastName;
        uint256[] phoneNumbers;
        bool exists;
    }

    mapping(uint256 => Contact) private contacts;
    uint256[] private contactIds;

    error ContactNotFound(uint256 id);

    /// @notice Constructor, set owner saat dibuat (dipanggil dari factory)
    constructor(address _owner) Ownable(_owner) {}

    /// @notice Add a new contact (only owner can add)
    function addContact(
        uint256 _id,
        string memory _firstName,
        string memory _lastName,
        uint256[] memory _phoneNumbers
    ) external onlyOwner {
        require(!contacts[_id].exists, "Contact already exists");

        contacts[_id] = Contact({
            id: _id,
            firstName: _firstName,
            lastName: _lastName,
            phoneNumbers: _phoneNumbers,
            exists: true
        });

        contactIds.push(_id);
    }

    /// @notice Delete a contact by ID (only owner)
    function deleteContact(uint256 _id) external onlyOwner {
        if (!contacts[_id].exists) {
            revert ContactNotFound(_id);
        }

        delete contacts[_id];

        // hapus dari array id
        for (uint256 i = 0; i < contactIds.length; i++) {
            if (contactIds[i] == _id) {
                contactIds[i] = contactIds[contactIds.length - 1];
                contactIds.pop();
                break;
            }
        }
    }

    /// @notice Get a contact by ID
    function getContact(uint256 _id) external view returns (
        uint256 id,
        string memory firstName,
        string memory lastName,
        uint256[] memory phoneNumbers
    ) {
        if (!contacts[_id].exists) {
            revert ContactNotFound(_id);
        }

        Contact storage c = contacts[_id];
        return (c.id, c.firstName, c.lastName, c.phoneNumbers);
    }

    /// @notice Get all contacts
    function getAllContacts() external view returns (Contact[] memory) {
        Contact[] memory allContacts = new Contact[](contactIds.length);

        for (uint256 i = 0; i < contactIds.length; i++) {
            allContacts[i] = contacts[contactIds[i]];
        }

        return allContacts;
    }
}

/// @title AddressBookFactory
/// @notice Deploys new AddressBook contracts
contract AddressBookFactory {
    event AddressBookDeployed(address indexed owner, address addressBook);

    function deploy() external returns (address) {
        AddressBook newBook = new AddressBook(msg.sender);
        emit AddressBookDeployed(msg.sender, address(newBook));
        return address(newBook);
    }
}
