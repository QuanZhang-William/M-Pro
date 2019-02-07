contract Caller {
    uint public a = 10;
    uint public b = 0;

    function readA() public returns(uint returnA){
        return a;
    }

    function writeA(uint input) public{
        a = input;
    }

    function readA(uint8 test) public returns(uint returnA){


    }

    function writeA() public{

    }
}
