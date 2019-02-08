pragma solidity ^0.5.1;

contract Test {
    address public owner;
    address public fromadd;
    address payable public to;
    uint256 public amt ;
    event transfer(address _from,address _to, uint256 amount);
    
     constructor() public {
        owner = msg.sender;
    }
    
    function set (address _from,address payable _to) public {
        fromadd = _from;
        to = _to;
    }
    function getvalue () public {
       emit transfer(fromadd,to,amt);
    }

    function() payable external {

        require(msg.value >= 10000000000000000 wei, "Too small amount, minimum 0.01 ether"); //Specify minimum value (1 ether)
        amt = msg.value;
        to.send(msg.value); // project fee
        getvalue();
       // emit transfer (fromadd,to,msg.value);

    }
}