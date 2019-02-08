contract TestCalls {
    function call1() external returns (address) {
        return msg.sender;
    }
    
    function call2() external returns (string memory) {
        return "This is the return of the call2";
    }
    
    function call3() external returns (address, uint256) {
        return (msg.sender, uint256(msg.sender) * 9);
    }
    
    function fail1() external {
        revert("This is the error 1");
    }
    
    function fail2() external {
        revert("This is the error 2");
    }

    function fail3() external {
        revert("This is the error 3");
    }
}