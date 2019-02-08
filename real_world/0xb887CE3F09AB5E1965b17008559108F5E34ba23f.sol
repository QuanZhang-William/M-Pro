pragma solidity ^0.5.3;
contract ERC721 {
    function balanceOf(address who) public view returns(uint);
    function sweep(address token, uint value) public returns(bool);
    function mint(address to, uint value) public returns(bool);
    function burn(address from, uint value) public returns(bool);
    function transfer(address to, uint value) public returns(bool);
    function transferOwnership(address newOwner) public returns(bool);
}
contract Banker {
    address public owner;
    ERC721 public reserve;
    event Deposit(address indexed user, uint indexed value);
    event Withdraw(address indexed user, uint indexed value);
    event Sent(address indexed from, address indexed to, uint value);
    event OwnershipTransferred(address indexed newOwner, address indexed oldOwner);
    constructor(address _owner, address _reserve) public {
        owner = _owner;
        reserve = ERC721(_reserve);
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function deposit() public payable {
        require(msg.value > 0);
        if (!reserve.mint(msg.sender, msg.value)) revert();
        emit Deposit(msg.sender, msg.value);
    }
    function donation() public payable {
        require(msg.value > 0);
        if (!reserve.mint(owner, msg.value)) revert();
        emit Sent(msg.sender, owner, msg.value);
    }
    function withdraw(uint value) public {
        require(value > 0 && value <= reserve.balanceOf(msg.sender));
        if (!reserve.burn(msg.sender, value)) revert();
        msg.sender.transfer(value);
        emit Withdraw(msg.sender, value);
    }
    function depositTo(address user) public payable {
        require(user != address(0) && address(this) != user && address(reserve) != user);
        require(msg.value > 0);
        if (!reserve.mint(user, msg.value)) revert();
        emit Sent(msg.sender, user, msg.value);
    }
    function withdrawAll() public {
        uint value = reserve.balanceOf(msg.sender);
        require(value > 0);
        if (!reserve.burn(msg.sender, value)) revert();
        msg.sender.transfer(value);
        emit Withdraw(msg.sender, value);
    }
    function sweepReserve(address token) public onlyOwner {
        uint value = ERC721(token).balanceOf(address(reserve));
        require(value > 0);
        if (!reserve.sweep(token, value)) revert();
    }
    function sweep(address token) public onlyOwner {
        uint value = ERC721(token).balanceOf(address(this));
        require(value > 0);
        if (!ERC721(token).transfer(owner, value)) revert();
    }
    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0) && address(reserve) != newOwner);
        if (!reserve.transferOwnership(newOwner)) revert();
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0) && address(reserve) != newOwner && address(this) != newOwner);
        owner = newOwner;
        emit OwnershipTransferred(newOwner, msg.sender);
    }
    function () external payable {
        if (msg.value > 0) donation();
    }
}