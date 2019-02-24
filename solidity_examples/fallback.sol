pragma solidity ^0.5.0;


contract WeakRandom {
    uint a = 10;
    uint b = 100;


    function () external {
        a = 20;
        if(a == 20){
            a = 10;
        }
    }

    function chooseWinner() public {
        a = 100;
    }
}
