pragma solidity ^0.5.0;


contract Greeter {

  string public greeting;

  constructor() public {
  }

  function setGreeting(string memory _greeting) public {
    greeting = _greeting;
  }
  
  function greet() public returns (string memory) {
    return greeting;
  }

}