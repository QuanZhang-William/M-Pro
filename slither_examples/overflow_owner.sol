contract Caller22 {
    struct Voter {
        uint256 aa;
        uint256 bb;
        uint256 cc;
        uint256 dd;
    }

    Voter t;
	uint256 public a;
	uint256[] public array = [100,200];
	uint256 public b = 2;
	address public stored_address;

	function writing() public{
	    t.aa = 10;

	}
	function writing(uint a) public{
	    t.aa = 10;

	}
	function reading() public returns(uint256 returnA){
        a = t.bb;

	}
}
