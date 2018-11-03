pragma solidity ^0.4.17;


contract Caller {

    //0x379bf63c
	address public fixed_address;

	uint256 statevar;
	uint256 temp;

	function Caller(address addr) {
		fixed_address = addr;
	}

    //0xe11f493e
	function reentrancy(uint256 a) public {
	    fixed_address.call();
	    if(a > 0){

	    }else{
            statevar = 0;
	    }
	}

    //0x4fa519fa
	function setValue() private {

	}

}
