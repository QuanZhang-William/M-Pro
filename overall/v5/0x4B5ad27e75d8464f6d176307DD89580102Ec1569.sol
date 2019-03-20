pragma solidity ^0.5.0;

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external;
    function approve(address spender, uint256 value) external;
    function transferFrom(address from, address to, uint256 value) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract FERToken is ERC20 {

    bool public allowTransfer;

    mapping (address => uint256) public __balanceOf;
    mapping (address => mapping (address => uint256)) public __allowances;

    function balanceOf(address _addr) public view returns (uint256 balance) {
        return __balanceOf[_addr];
    }
    
    function transfer(address _to, uint256 _value) public {
        require(allowTransfer, "Transfer not allowed");
        require(_value > 0, "Negative value not allowed");
        require(_value <= balanceOf(msg.sender), "Insufficient funds");

        __balanceOf[msg.sender] -= _value;
        __balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public {
        require(allowTransfer, "Transfer not allowed");
        require(__allowances[_from][msg.sender] > 0 && _value > 0, "Negative value not allowed");
        require(__allowances[_from][msg.sender] >= _value && __balanceOf[_from] >= _value, "Insufficient funds");

        __balanceOf[_from] -= _value;
        __balanceOf[_to] += _value;
        __allowances[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
    }
    
    function approve(address _spender, uint256 _value) public {
        require(allowTransfer, "Transfer not allowed");

        __allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return __allowances[_owner][_spender];
    }
}

contract MintableFERToken is FERToken {

    string public constant name = "FER Token";
    string public constant symbol = "FER";
    uint8 public constant decimals = 18;
    uint256 private constant __totalSupply = 5000000000000000000000000;   
    address public mintableAddress;

    constructor(address sale_address) public {
        __balanceOf[msg.sender] = __totalSupply;
        mintableAddress = sale_address;
        allowTransfer = true;
    }

    function totalSupply() public view returns (uint256 _totalSupply) {
        _totalSupply = __totalSupply;
    }

    function changeTransfer(bool allowed) external {
        require(msg.sender == mintableAddress, "Sender is not owner in changeTransfer()");
        allowTransfer = allowed;
    }

    function changeOwner(address new_owner) public {
        mintableAddress = new_owner;
    }

    function mintToken(address to, uint256 amount) external {
        require(msg.sender == mintableAddress, "Sender is not owner in mintToken()");

        __balanceOf[msg.sender] -= amount;
        __balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }
}