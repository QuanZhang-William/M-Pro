pragma solidity ^0.4.17;


contract Caller {
	address public stored_address;

	function callstoredaddress() {
	    stored_address.call();
	}

	function setstoredaddress(address addr) {
	    stored_address = addr;
	}

}
