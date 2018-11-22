contract Caller {
	address public stored_address = 0xE0F7e56e62b4267062172495D7506087205A4229;

	function callstoredaddress() {
	    stored_address.call();
	}

	function setstoredaddress(address addr) {
	    stored_address = addr;
	}

}
