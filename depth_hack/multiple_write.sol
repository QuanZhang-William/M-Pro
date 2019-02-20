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

    function writB(uint input) public{
        a = 10;
    }

    function writC(uint input) public{
        a = 10;
    }

    function writD(uint input) public{
        a = 10;
    }

    function writE(uint input) public{
        a = 10;
    }

    function suicide(address payable addr) public{
        if (a == 10 && b == 10 && c == 10 && d == 10 && e == 10){
            selfdestruct(addr);
        }
    }
}
