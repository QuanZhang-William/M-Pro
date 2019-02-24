contract Caller {
    uint public a = 0;
    uint public b = 0;

    function internal_writeA(uint input) private{
        a = 10;
    }

    modifier onlyOwner{
      if(a != 100) revert();
      _;
    }

    function readA() onlyOwner public {

    }

    function writeA(uint input) public{
        internal_writeA(input);
    }

    function writB(uint input) public{
        b = 10;
    }

    function readB_private() private{
        if (b == 100){

        }
    }

    function readB() public{
        readB_private();
    }

    function readAB(uint input) public{
        if (a == 10 && b == 10){

        }
    }
}
