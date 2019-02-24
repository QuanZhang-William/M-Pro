contract Caller {
    uint public a = 0;

    function writeA(uint input) public{
        a = 10;
    }

    function RAB(address payable addr) public{
        if (a == 10){
            selfdestruct(addr);
        }
    }
}
