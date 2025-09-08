// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FavoriteRecords {

    mapping(string => bool) public approvedRecords;
    mapping(address => mapping(string => bool)) public userFavorites;

    string[] private approvedList;
    mapping(address => string[]) private userFavoritesList; 

    error NotApproved(string albumName);

    constructor() {
        string[9] memory albums = [
            "Thriller",
            "Back in Black",
            "The Bodyguard",
            "The Dark Side of the Moon",
            "Their Greatest Hits (1971-1975)",
            "Hotel California",
            "Come On Over",
            "Rumours",
            "Saturday Night Fever"
        ];

        for (uint i = 0; i < albums.length; i++) {
            approvedRecords[albums[i]] = true;
            approvedList.push(albums[i]);
        }
    }

    function getApprovedRecords() external view returns (string[] memory) {
        return approvedList;
    }

    function addRecord(string calldata albumName) external {
        if (!approvedRecords[albumName]) {
            revert NotApproved(albumName);
        }

        if (!userFavorites[msg.sender][albumName]) {
            userFavorites[msg.sender][albumName] = true;
            userFavoritesList[msg.sender].push(albumName);
        }
    }

    function getUserFavorites(address user) external view returns (string[] memory) {
        return userFavoritesList[user];
    }

    function resetUserFavorites() external {
        string[] storage favs = userFavoritesList[msg.sender];
        for (uint i = 0; i < favs.length; i++) {
            userFavorites[msg.sender][favs[i]] = false;
        }
        delete userFavoritesList[msg.sender];
    }
}
