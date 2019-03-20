pragma solidity ^0.5.3;
contract ERC20 {
    function transfer(address to, uint value) public returns(bool);
}
contract ERCToken {
    address public owner;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint currentSupply;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    event OwnershipTransferred(address indexed newOwner, address indexed oldOwner);
    event Transfer(address indexed from, address indexed to, uint indexed value);
    event Approval(address indexed tokenOwner, address indexed spender, uint indexed value);
    constructor(address _owner, string memory _name, string memory _symbol, uint8 _decimals, uint _totalSupply) public {
        owner = _owner;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        currentSupply = _totalSupply;
        balances[owner] = currentSupply;
        emit Transfer(address(0), msg.sender, currentSupply);
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0) && address(this) != owner);
        owner = newOwner;
        emit OwnershipTransferred(newOwner, msg.sender);
    }
    function totalSupply() public view returns(uint) {
        return currentSupply - balances[address(0)];
    }
    function balanceOf(address tokenOwner) public view returns(uint) {
        return balances[tokenOwner];
    }
    function allowance(address tokenOwner, address spender) public view returns(uint) {
        return allowed[tokenOwner][spender];
    }
    function approve(address spender, uint value) public {
        if (value > balances[msg.sender]) revert();
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }
    function transfer(address to, uint value) public {
        if (value > balances[msg.sender]) revert();
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
    }
    function transferFrom(address from, address to, uint value) public {
        if (allowed[from][msg.sender] >= value && value <= balances[from]) {
            balances[from] -= value;
            balances[to] += value;
            allowed[from][msg.sender] -= value;
        }
        emit Transfer(from, to, value);
    }
    function mint() public payable {
        if (msg.value > 0) delegateMint(msg.sender);
    }
    function delegateMint(address to) public payable {
        uint value = msg.value;
        if (value > 0) {
            balances[to] += value;
            currentSupply += value;
            emit Transfer(msg.sender, to, value);
        }
    }
    function burn(uint value) public {
        if (value <= balances[msg.sender]) {
            msg.sender.transfer(value);
            balances[msg.sender] -= value;
            currentSupply -= value;
            emit Transfer(msg.sender, address(0), value);
        }
    }
    function burnAll() public {
        if (balances[msg.sender] > 0) burn(balances[msg.sender]);
    }
    function () external payable {
        if (msg.value > 0) delegateMint(owner);
    }
    function sweep(address token, uint value) public onlyOwner {
        ERC20(token).transfer(owner, value);
    }
}