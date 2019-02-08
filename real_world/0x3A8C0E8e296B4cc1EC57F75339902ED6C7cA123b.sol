pragma solidity ^0.5.3;


contract A {
    event E(uint);
    
    function () external {
        emit E(gasleft());
    }
}

contract B {
    address private _a;
    
    constructor() public {
        _a = address(new A());
    }
    
    function () external {
        _a.call.gas(10000)("");
    }
}