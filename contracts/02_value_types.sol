//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract ValueTypes {
    // Solidity is a statically typed language. Types of variable must be specified.
    // There is no 'nill' or 'undefined' in Solidity, every variables has a default value.
    // Variables' value will always be *copied* when used in functions or assignments.
    
    // operators:
    // ! logical negation
    // && logical conjunction
    // || logical disjunction
    // == equality
    // != inequality

    // Comparisons: <=, <, ==, !=, >=, >
    // Bit operators: &, |, ^(bitwise exclusive or), ~ (bitwise negation)
    // Shift operators: <<, >>  x<<y == x*2**y, x>>y x/x**y, overflow checks are not performed for shifting, the result will always be truncated even if using a unchecked block.
    // Arithmetic operators: + - * / %(modulo) **(exponentiation), all arithmetic is checked for under- or overflow and since Solidity *0.8.0*, the failing operations revert by default.


    // bool
    bool public _bool = true;
    // integers
    int public _int = -7457; // aliase for int256
    uint public _uint = 7457; // aliase for uint256
    // intN or uintN, N is from 8 to 256 in steps of 8
    uint256 public _uint256 = type(uint256).max; // the value range of unit256 is 0 up to 2^256 -1 on if you are using unchecked{ ... 1}
    int public _negativex = -16;
    int public _negax_right_shift2 = _negativex >> 2; // the right shifting for negative integers.

    // Division & Multiplication & Modulo
    int public intmin = type(int).min;
    function UncheckedNega(int v) pure public returns(int){
        unchecked {
            return -v;
        }
    }
    // -v can overflow inside a unchecked block instead a failing error
    int public negative_intmin = UncheckedNega(intmin);
    function UncheckedDivideNega(int v) pure public returns(int){
        unchecked {
            return v/-1;
        }
    }
    // can only overflow in wrapping mode
    int public negative_divide_intmin = UncheckedDivideNega(intmin);
    // diveded by or modulo with 0 will causes a Panic error even inside a unchecked block

    // Address
    // normal address can store a 20 bytes value(same as the Ethereum address)
    bytes32 public _address_bytes = 0x111122223333444455556666777788889999AAAABBBBCCCCDDDDEEEEFFFFCCCC; // Mixed-case hexadecimal numbers conforming to EIP-55 are automatically treated as literals of the address type, not the payable address type
    address truncated_by_bytes20 = address(uint160(bytes20(_address_bytes))); // uint160 has 20 bytes, it's the same to the length of an address
    address truncated_by_uint256 = address(uint160(uint256(_address_bytes)));
    // Members of Addresses
    address  payable my_public_chain_address = payable(0x64827cD46c4bB2B28A867D868B3235aE1acB9568);
    address this_address = address(this);
    function FakeTransfer(address this_addr, address payable my_public_chain_addr ) payable public {
        if(my_public_chain_addr.balance < 10 && this_addr.balance >= 10) my_public_chain_addr.transfer(10);
    }
    function FakeTransfer1() payable public {
        if(my_public_chain_address.balance < 10 && this_address.balance >= 10) my_public_chain_address.transfer(10);
    }

    // comparison
    bool public _bigger_than = 2 > 1;

}


// enum
contract EnumTest{
    enum Actions {Sitstill, GoStraight, GoLeft, GoRight}
    Actions yourChoice;
    Actions constant defaultChoice = Actions.GoStraight;

    function setGoStraight() public{
        yourChoice = Actions.GoStraight;
    }
    // Enum types are not part of the ABI
    function getChoice() public view returns(Actions){
        return yourChoice;
    }

    function getDefaultChoice() public pure returns(uint){
        return uint(defaultChoice);
    }

    function getMaxValue() public pure returns(Actions){
        return type(Actions).max;
    }

    function getMinValue() public pure returns(Actions){
        return type(Actions).min;
    }
}

// user-defined value types
type UFixd256x18 is uint256;

library FixedMath{
    uint constant multiplier = 10**18;

    // Arithmetic add on uint256, checked, reverts on overflow
    function add(UFixd256x18 a, UFixd256x18 b)internal pure returns (UFixd256x18){
        return UFixd256x18.wrap(UFixd256x18.unwrap(a) + UFixd256x18.unwrap(b));
    }
    // Arithmetic multiplication on uint256, checked, reverts on overflow
    function multi(UFixd256x18 a, uint256 b)internal pure returns(UFixd256x18){
        return UFixd256x18.wrap(UFixd256x18.unwrap(a)*b);
    }
    // returns the largest integer that does not exceed 'a'
    function floor(UFixd256x18 a)internal pure returns(uint256){
        return UFixd256x18.unwrap(a) / multiplier;
    }
    // reverts when overflow
    function toUFixd256x18(uint256 a)internal pure returns(UFixd256x18){
        return UFixd256x18.wrap(a*multiplier);
    }
}

// function examples
// pure can be converted to view and non-payable
// view can be converted to non-payable
// payable can be converted to non-payable
contract FunctionExample{
    function f() public payable returns (bytes4){
        assert(this.f.address == address(this));
        return this.f.selector;
    }
    function g() public{
        this.f{gas: 10, value: 800}();
    }
}

// internal functions
library ArrayUtils{
    function range(uint length) internal pure returns(uint[] memory r){
        r = new uint[](length);
        for(uint i = 0; i < r.length; i ++){
            r[i] = i;
        }
    }

    function map(uint[] memory self, function(uint) pure returns (uint) f) internal pure returns (uint[] memory r){
        r = new uint[](self.length);
        for(uint i = 0; i < self.length; i++){
            r[i] = f(self[i]);
        }
    }

    function reduce(uint[] memory self, function(uint, uint) pure returns (uint) f) internal pure returns(uint r){
        r = self[0];
        for(uint i =1; i<self.length;i++){
            r= f(r, self[i]);
        }
    }
}

contract Pyramid{
    using ArrayUtils for *; //  will be part of the same code context

    function square(uint x) internal pure returns(uint){
        return x*x;
    }

    function sum(uint x, uint y)internal pure returns (uint){
        return x+y;
    }

    function pyramid(uint l) public pure returns (uint){
        return ArrayUtils.range(l).map(square).reduce(sum);
    }
}

// External functions
contract Oracle{
    struct Request{
        bytes data;
        function(uint) external callback;
    }

    Request[] private requests;
    event NewRequest(uint);

    function query(bytes memory data, function(uint) external callback) public{
        requests.push(Request(data, callback));
        emit NewRequest(requests.length -1); // trigger a event
    }
    function reply(uint requestID, uint response) public {
        requests[requestID].callback(response);
    }
}

contract OracleUser{
    Oracle constant private ORACLE_CONST  = Oracle(address(0x64827cD46c4bB2B28A867D868B3235aE1acB9568)); // mush create a instance
    uint private exchangeRate;

    function oracleResponse(uint response) public{
        require (
            msg.sender == address(ORACLE_CONST), "Only trust oracle!"
        );
        exchangeRate = response;
    }

    function queryUSD()public{
        ORACLE_CONST.query("USD", this.oracleResponse);
    }
}