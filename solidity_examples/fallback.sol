pragma solidity ^0.5.0;


contract WeakRandom {
    uint a = 10;
    uint b = 100;

    //function test() public{
    //    a = 100;
    //}

    function () payable external {
        a = 20;
        if(a == 20){
            a = 30;
        }
        //chooseWinner();
    }

    function chooseWinner() private {
        a = 100;
    }
}
