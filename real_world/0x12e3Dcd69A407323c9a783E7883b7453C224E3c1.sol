pragma solidity ^0.5.2;
contract hackfuck {
   address owner;
   
   constructor() public {
        owner = msg.sender;
    }
    
    mapping(address => uint256) balances;
function () payable external {
    balances[msg.sender] += msg.value;
} 
    
    
    function withdraw(address payable recp) public  {
        require(owner == msg.sender);
    recp.transfer(address(this).balance);
  
    
}
    function transferOwnership(address newOwner) public  {
    require(owner == msg.sender);
    owner = newOwner;
  }
  
}