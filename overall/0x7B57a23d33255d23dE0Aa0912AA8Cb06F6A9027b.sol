pragma solidity >=0.5.0 <0.6.0;

contract RaidenChairPuzzle {
    string public raiden_commit = "00b1fb76f468157d19c4fda30fc5aae007a0ad13";
    bytes32 answerPuzzle1 = 0x21c0107378acb490e7190da71596effe409c128f08adcc5467b293f1f3a66431;
    bytes32 answerPuzzle2 = 0xda3d5e3ff21d74304e18e0e9e92572242c9e9f7e01b2f5e271bbcb2324564cbe;
    
    event Answered(string _answerPuzzle1, string _answerPuzzle2, string name);
    event Challenged(string _answerPuzzle1, string _answerPuzzle2, string name);
    
    function getPuzzle1() external pure returns(string memory) {
        return 'What is flippable but yet the same? A small key that unlocked the resolution door. The answer lies in a private sheet and in plain sight. One word. Lowercase.';
    }
    
    function getPuzzle2() external pure returns(string memory) {
        return 'Mediated transfer with 3 refunds: A-B-C-B-D-E-D-B-F-G. We are node B. We receive a SecretReveal. How many SendSecretReveal messages do we send in the current mediator.state_transition, to whom and in what order in the queue? Answer has the form `<number><first_node><second_node><third_node>…`. E.g. `17ABCD`';
    }
    
    function answer(string calldata _answerPuzzle1, string calldata _answerPuzzle2, string calldata name) external {
        require(answerPuzzle1 == hash(_answerPuzzle1));
        require(answerPuzzle2 == hash(_answerPuzzle2));
        emit Answered(_answerPuzzle1, _answerPuzzle2, name);
    }
    
    function challenge(string calldata _answerPuzzle1, string calldata _answerPuzzle2, string calldata name) external {
        emit Challenged(_answerPuzzle1, _answerPuzzle2, name);
    }
    
    function hash(string memory smth) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(smth));
    }
}