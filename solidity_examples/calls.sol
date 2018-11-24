contract Caller {
	address stored_address;

	function callstoredaddress(address addr, uint a) public returns(address test){
	    if(a > 10){
	        return stored_address;
	    }
	}

	function setstoredaddress(address addr) public{
	    stored_address = addr;
	}

}
