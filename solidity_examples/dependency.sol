contract Caller {
    uint public a = 10;
    uint public b = 0;
    uint public c = 2;

    function readA() public returns(uint returnA){
        if (c > 10){

        }
        return a;
    }

    function writeA(uint input) public{
        c = input;
        a = input;
    }

    function readB() public returns(uint returnA){
        return b;
    }

    function writB(uint input) public{
        if (input > 10){
            b = 100;
        }else{
            b = 30;
        }
    }
}
