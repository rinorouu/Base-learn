
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// --- Library ---
library SillyStringUtils {
    struct Haiku {
        string line1;
        string line2;
        string line3;
    }

    function shruggie(string memory _input) internal pure returns (string memory) {
        return string.concat(_input, unicode" 🤷");
    }
}

// --- Main Contract ---
contract ImportsExercise {
    // Public instance of Haiku
    SillyStringUtils.Haiku public haiku;

    // --- Save Haiku ---
    function saveHaiku(
        string calldata _line1, 
        string calldata _line2, 
        string calldata _line3
    ) public {
        haiku = SillyStringUtils.Haiku({
            line1: _line1,
            line2: _line2,
            line3: _line3
        });
    }

    // --- Get Haiku ---
    function getHaiku() public view returns (SillyStringUtils.Haiku memory) {
        return haiku;
    }

    // --- Shruggie Haiku ---
    function shruggieHaiku() public view returns (SillyStringUtils.Haiku memory) {
        SillyStringUtils.Haiku memory modified = haiku;
        modified.line3 = SillyStringUtils.shruggie(modified.line3);
        return modified;
    }
}
