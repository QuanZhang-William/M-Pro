contract Suicide {
    address public owner;

    modifier onlyOwner{
      if(msg.sender != owner) revert();
      _;
    }

    function setOwner() public{
        owner = msg.sender;
    }

    function kill(address addr){
        if(msg.sender != owner) revert();
        selfdestruct(msg.sender);
    }
}
