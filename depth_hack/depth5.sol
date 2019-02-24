contract Caller {
    uint public a = 0;
    uint public b = 0;
    uint public c = 0;
    uint public d = 0;

    function writeA(uint input) public{
        a = 10;
    }

    function writB(uint input) public{
        b = 10;
    }

    function writC(uint input) public{
        c = 10;
    }

    function writD(uint input) public{
        d = 10;
    }

    function RABC(address payable addr) public{
    if (a == 10 && c == 10 && b == 10 && d == 10){
        selfdestruct(addr);
    }
}
}
