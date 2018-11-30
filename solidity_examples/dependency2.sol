contract Caller {
    uint public a = 10;
    uint public b = 0;

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

    function readA2() public returns(uint returnA){
        return a;
    }

    function writeA2(uint input) public{
        a = input;
    }

    function readB2() public returns(uint returnA){
        return b;
    }

    function writB2(uint input) public{
        b = input;
    }
}
