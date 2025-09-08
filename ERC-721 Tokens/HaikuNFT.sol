// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract HaikuNFT is ERC721 {
    struct Haiku {
        address author;
        string line1;
        string line2;
        string line3;
    }

    /// @notice public array of Haikus. haikus[0] is a dummy so real IDs start at 1
    Haiku[] public haikus;

    /// @notice address => list of haiku IDs shared with that address
    mapping(address => uint256[]) public sharedHaikus;

    /// @notice used-line tracking to enforce uniqueness across all lines
    mapping(bytes32 => bool) private usedLine;

    /// @notice next id to mint. If 10 haikus minted, counter == 11
    uint256 public counter;

    /// @notice Errors
    error HaikuNotUnique();
    error NotYourHaiku(uint256 haikuId);
    error NoHaikusShared();

    constructor() ERC721("HaikuNFT", "HAIKU") {
        // ensure no haiku gets id 0: push dummy at index 0
        haikus.push(Haiku(address(0), "", "", ""));
        counter = 1; // next id to mint
    }

    /// @dev helper: has this exact line (bytes) been used before?
    function _lineUsed(string memory s) internal view returns (bool) {
        return usedLine[keccak256(abi.encodePacked(s))];
    }

    function _markLineUsed(string memory s) internal {
        usedLine[keccak256(abi.encodePacked(s))] = true;
    }

    /// @notice Mint a unique Haiku NFT. Reverts if any line was used before.
    function mintHaiku(
        string memory line1,
        string memory line2,
        string memory line3
    ) external {
        if (_lineUsed(line1) || _lineUsed(line2) || _lineUsed(line3)) {
            revert HaikuNotUnique();
        }

        uint256 id = counter;

        // mint the token with id == counter
        _mint(msg.sender, id);

        // store Haiku at index == id (we have dummy at 0 so this lines up)
        haikus.push(Haiku(msg.sender, line1, line2, line3));

        // mark lines used
        _markLineUsed(line1);
        _markLineUsed(line2);
        _markLineUsed(line3);

        // increment next-id counter
        unchecked {
            counter = counter + 1;
        }
    }

    /// @notice Share a haiku (by id) with another address. Only owner can share.
    function shareHaiku(uint256 haikuId, address to) public {
        if (ownerOf(haikuId) != msg.sender) revert NotYourHaiku(haikuId);
        sharedHaikus[to].push(haikuId);
    }

    /// @notice Return all haikus shared with msg.sender, or revert if none.
    function getMySharedHaikus() public view returns (Haiku[] memory) {
        uint256[] memory ids = sharedHaikus[msg.sender];
        if (ids.length == 0) revert NoHaikusShared();

        Haiku[] memory out = new Haiku[](ids.length);
        for (uint256 i = 0; i < ids.length; ++i) {
            out[i] = haikus[ids[i]];
        }
        return out;
    }
}

