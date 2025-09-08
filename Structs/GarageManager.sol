
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GarageManager {

    struct Car {
        string make;
        string model;
        string color;
        uint numberOfDoors;
    }

    mapping(address => Car[]) public garage;

    error BadCarIndex(uint256 index);

    function addCar(
        string calldata make,
        string calldata model,
        string calldata color,
        uint numberOfDoors
    ) external {
        Car memory newCar = Car(make, model, color, numberOfDoors);
        garage[msg.sender].push(newCar);
    }

    function getMyCars() external view returns (Car[] memory) {
        return garage[msg.sender];
    }

    function getUserCars(address user) external view returns (Car[] memory) {
        return garage[user];
    }

    function updateCar(
        uint index,
        string calldata make,
        string calldata model,
        string calldata color,
        uint numberOfDoors
    ) external {
        if (index >= garage[msg.sender].length) {
            revert BadCarIndex(index);
        }
        garage[msg.sender][index] = Car(make, model, color, numberOfDoors);
    }

    function resetMyGarage() external {
        delete garage[msg.sender];
    }
}
