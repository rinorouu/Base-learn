// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ControlStructures {
    function fizzBuzz(uint _number) public pure returns (string memory) {
        if (_number % 3 == 0 && _number % 5 == 0) {
            return "FizzBuzz";
        } else if (_number % 3 == 0) {
            return "Fizz";
        } else if (_number % 5 == 0) {
            return "Buzz";
        } else {
            return "Splat";
        }
    }

    error AfterHours(uint time);

    function doNotDisturb(uint _time) public pure returns (string memory) {
        if (_time >= 2400) {
            
            assert(false); // triggers a panic
        } else if (_time > 2200 || _time < 800) {
            
            revert AfterHours(_time);
        } else if (_time >= 1200 && _time <= 1259) {
            revert("At lunch!");
        } else if (_time >= 800 && _time <= 1199) {
            return "Morning!";
        } else if (_time >= 1300 && _time <= 1799) {
            return "Afternoon!";
        } else if (_time >= 1800 && _time <= 2200) {
            return "Evening!";
        }

        return "Unknown";
    }
}
