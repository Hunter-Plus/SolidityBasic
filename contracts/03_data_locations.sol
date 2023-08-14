//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// memory (whose lifetime is limited to an external function call)

// storage (the location where the state variables are stored, where the lifetime is limited to the lifetime of a contract)

// calldata (special data location that contains the function arguments).
// non-modifiable, non-persistent, cannot allocate, avoid copies


// Assignment Behaviour
// storage <---> memory, calldata : create an copy
// memory <---> memory : create references
// storage ---> local storage : create references

contract DataLocations{
    uint[] x; // data location is storage and the "storage" label has been omitted

    function g(uint[] storage) internal pure{}
    function h(uint[] memory) public pure{}

    function f(uint[] memory memoryArray) public {
        // memoryArray's data location is memory
        x = memoryArray; // memory ---> storgae, create a copy
        uint[] storage y = x; // y is a pointer and the data location is storage, this is a local storage case
        y[7];
        y.pop();
        delete x;
        // y = memoryArray; Wrong, y is a pointer, there is no y in the storage
        // delete y; Wrong, no sensible location y could point to after delete

        // g(memoryArray); Worng, must be a storage object or storage pointer.
        g(x); // Handling over a reference to x, a storage pointer.
        h(memoryArray); // using reference
        h(x); // create a temporary copy in memory
    }
}

