contract Caller {
    uint public a = 0;
    uint public b = 0;

    function readA() public returns(uint returnA){
        return a;
    }

    function writeA(uint input) public{
        a = 10;
    }

    function writB(uint input) public{
        b = 10;
    }

    function suicide(address payable addr) public{
        if (a == 10 && b == 10){
            selfdestruct(addr);
        }
    }
}
