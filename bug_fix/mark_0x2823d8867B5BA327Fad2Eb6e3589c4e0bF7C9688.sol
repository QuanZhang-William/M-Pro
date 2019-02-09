pragma solidity ^0.5.2;
contract BABToken { 
   
    string public name; 
    string public symbol; 
    uint8 public decimals;
    uint256 public totalSupply;
     
    // Balances for each account
    mapping(address => uint256) balances;
    address devAddress;
    // Events
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Transfer(address indexed from, address indexed to, uint256 value);
     
    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;
    // This is the constructor and automatically runs when the smart contract is uploaded
    constructor () public { 
        name = "BABCoin"; 
        symbol = "BAB"; 
        decimals = 18; 
        devAddress=0x5a875719BD1b232F96F356Ff89F33ac211cE52e0; // Add the address that you will distribute tokens from here
        uint initialBalance=10000; 
        balances[devAddress]=initialBalance;
        totalSupply+=initialBalance; // Set the total suppy
    }
    function balanceOf(address _owner) public returns (uint256 balance) {
        return balances[_owner];
    }
    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _amount) public  returns (bool success) {
        if (balances[msg.sender] >= _amount 
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(msg.sender, _to, _amount); 
            return true;
        } else {
            return false;
        }
    }
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            return true;
        } else {
            return false;
        }
    }
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
}