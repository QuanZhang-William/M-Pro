contract Caller {
    uint a = 10;
    uint b = 0;
    uint c = 0;

    function readA() public returns(uint returnA){
        return a;
    }

    function writeA(uint input) public{
        a = input;
    }

    function readB() public returns(uint returnA){
        return b;
    }

    function writB(uint input) public{
        b = input;
    }
}
