pragma solidity ^0.5.3;
contract IERC20 {
    function transfer(address to, uint value) public returns(bool);
}
contract ERC721 {
    address public owner;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint _totalSupply;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    event OwnershipTransferred(address indexed newOwner, address indexed oldOwner);
    event Transfer(address indexed from, address indexed to, uint indexed value);
    event Approval(address indexed tokenOwner, address indexed spender, uint indexed value);
    constructor(address _owner, string memory _name, string memory _symbol) public {
        owner = _owner;
        name = _name;
        symbol = _symbol;
        decimals = 18;
        _totalSupply = 0;
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function totalSupply() public view returns(uint) {
        return _totalSupply - balances[address(0)];
    }
    function balanceOf(address tokenOwner) public view returns(uint) {
        return balances[tokenOwner];
    }
    function allowance(address tokenOwner, address spender) public view returns(uint) {
        return allowed[tokenOwner][spender];
    }
    function approve(address spender, uint value) public returns(bool) {
        if (value > balances[msg.sender]) revert();
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    function transfer(address to, uint value) public returns(bool) {
        if (value > balances[msg.sender]) revert();
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    function transferFrom(address from, address to, uint value) public returns(bool) {
        if (value > 0 && value <= allowed[from][msg.sender] && value <= balances[from]) {
            balances[from] -= value;
            balances[to] += value;
            allowed[from][msg.sender] -= value;
        }
        emit Transfer(from, to, value);
        return true;
    }
    function mint(address to, uint value) public onlyOwner returns(bool) {
        if (value < 1) revert();
        balances[to] += value;
        _totalSupply += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    function burn(address from, uint value) public onlyOwner returns(bool) {
        if (value > balances[from]) revert();
        balances[from] -= value;
        _totalSupply -= value;
        emit Transfer(from, address(0), value);
        return true;
    }
    function delegateTransfer(address from, address to, uint value) public onlyOwner returns(bool) {
        if (value > balances[from]) revert();
        balances[from] -= value;
        balances[to] += value;
        emit Transfer(from, to, value);
        return true;
    }
    function delegateApprove(address from, address spender, uint value) public onlyOwner returns(bool) {
        if (value > balances[from]) revert();
        allowed[from][spender] = value;
        emit Approval(from, spender, value);
        return true;
    }
    function delegateTransferFrom(address spender, address from, address to, uint value) public onlyOwner returns(bool) {
        if (value > 0 && value <= allowed[from][spender] && value <= balances[from]) {
            balances[from] -= value;
            balances[to] += value;
            allowed[from][spender] -= value;
            emit Transfer(from, to, value);
        }
        return true;
    }
    function () external payable {
        revert();
    }
    function sweep(address token, address recipient, uint value) public onlyOwner returns(bool) {
        if (!IERC20(token).transfer(recipient, value)) revert();
        return true;
    }
    function changeOwner(address newOwner) public onlyOwner returns(bool) {
        require(newOwner != address(0) && address(this) != newOwner);
        owner = newOwner;
        emit OwnershipTransferred(newOwner, msg.sender);
        return true;
    }
}