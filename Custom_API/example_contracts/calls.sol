contract Caller {
	address public owner;
	uint public manager;

	constructor(address mgn) public{
		owner = msg.sender;
		manager = 10;
	}

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function ownerCall() public{
        msg.sender.call();
        selfdestruct(msg.sender);
    }

}
