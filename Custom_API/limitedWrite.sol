contract UnristrictedWrite {
    address public owner;
    uint public manager;

    constructor(bytes32 _name) public {
        owner = msg.sender;
        manager = 5;
    }

    modifier only_owner(){
        require(msg.sender == owner);
        _;
    }

    function updateManager() public only_owner{
        manager = 10;
    }

}
