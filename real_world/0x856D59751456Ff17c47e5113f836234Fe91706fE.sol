pragma solidity  ^0.5.3;

contract Entekhabat {
    uint public rohani;//2
    uint public trump;//1
    
    function vote(uint candidateID) public {
        if(candidateID==2)
            rohani++;
        else if(candidateID==1)
            trump++;
    }
}