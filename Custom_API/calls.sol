contract Caller22 {
    struct Voter {
        uint256 aa;
        uint256 bb;
        uint256 cc;
        uint256 dd;
    }

    Voter t;

	uint256 public a = 5;
	uint256[2] public array = [100,200];
	mapping(uint256 => uint256) items;
	uint256 public b = 2;
	address public stored_address;


	function callstoredaddress() public{
        stored_address = 0xE0f5206BBD039e7b0592d8918820024e2a7437b9;
	}

	function setstoredaddress() public{
        a = 4;
	}
}
