//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// uint[][5] ; Is a size fixed array of uint[], the length is 5. Its zero-based index are between 0-4.
// uint[2][7]; To access the eighth uint in the third dynamic array.

// bytes and string are special arrays.
// bytes is similar to byte1[] but packed tighter in calldata and memory.
// string is equal to bytes but not allow legth or index access.


contract BytesExpanding{
    bytes x = "012345678901234567890123456789";
    bytes1 the_last_byte = x[31];
    
    function AddByteToX() external{
        x.push('0');
        the_last_byte = x[31];
    } 
}