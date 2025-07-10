// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStorage {
    // Declare a public integer variable to store the value
    int public storedValue;

    // Constructor to initialize storedValue (optional)
    constructor() {
        storedValue = 0;
    }

    // Function to increment the stored value by 1
    function increment() public {
        storedValue += 1;
    }

    // Function to decrement the stored value by 1
    function decrement() public {
        storedValue -= 1;
    }

    // Optional: getter function (not needed since variable is public)
    function getValue() public view returns (int) {
        return storedValue;
    }
}
