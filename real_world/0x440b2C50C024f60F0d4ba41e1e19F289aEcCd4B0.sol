pragma solidity ^0.5.3;


contract A {
    event E(uint);
    
    function () external payable {
        emit E(gasleft());
    }
}

contract B {
    address payable private _a;
    
    constructor(address payable a) public {
        _a = a;
    }
    
    function () external payable {
        (bool r, bytes memory b) = _a.call.value(msg.value).gas(1000)("");
        require(r);
    }
}