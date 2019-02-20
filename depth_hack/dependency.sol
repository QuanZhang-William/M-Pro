contract Caller {
    uint public a = 0;
    uint public b = 0;
    uint public c = 0;
    uint public d = 0;
    uint public e = 0;

    function readA() public returns(uint returnA){
        return a;
    }

    function writeA(uint input) public{
        a = 10;
    }

    function readB() public returns(uint returnA){
        return b;
    }

    function writB(uint input) public{
        b = 10;
    }

    function readC() public returns(uint returnA){
        return c;
    }

    function writC(uint input) public{
        c = 10;
    }

    function readD() public returns(uint returnA){
        return d;
    }

    function writD(uint input) public{
        d = 10;
    }

    function readE() public returns(uint returnA){
        return e;
    }

    function writE(uint input) public{
        e = 10;
    }

    function suicide(address payable addr) public{
        if (a == 10 && b == 10 && c == 10 && d == 10 && e == 10){
            selfdestruct(addr);
        }
    }
}
