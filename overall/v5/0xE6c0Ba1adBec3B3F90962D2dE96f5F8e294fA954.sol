pragma solidity ^0.5.3;
contract IERC20 {
    function transfer(address to, uint value) public returns(bool);
}
contract IERC721 {
    function name() public view returns(string memory);
    function symbol() public view returns(string memory);
    function decimals() public view returns(uint8);
    function totalSupply() public view returns(uint);
    function balanceOf(address who) public view returns(uint);
    function allowance(address tokenOwner, address spender) public view returns(uint);
    function mint(address recipient, uint value) public returns(bool);
    function burn(address tokenOwner, uint value) public returns(bool);
    function delegateApprove(address tokenOwner, address spender, uint value) public returns(bool);
    function delegateTransfer(address tokenOwner, address to, uint value) public returns(bool);
    function delegateTransferFrom(address spender, address tokenOwner, address to, uint value) public returns(bool);
    function sweep(address token, address recipient, uint value) public returns(bool);
}
contract ERC20 {
    address public owner;
    IERC721 public asset;
    event OwnershipTransferred(address indexed newOwner, address indexed oldOwner);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed tokenOwner, address indexed spender, uint value);
    constructor(address _owner, address _asset) public {
        owner = _owner;
        asset = IERC721(_asset);
        emit Transfer(address(asset), owner, 0);
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function name() public view returns(string memory) {
        return asset.name();
    }
    function symbol() public view returns(string memory) {
        return asset.symbol();
    }
    function decimals() public view returns(uint8) {
        return asset.decimals();
    }
    function totalSupply() public view returns(uint) {
        return asset.totalSupply();
    }
    function balanceOf(address who) public view returns(uint) {
        return asset.balanceOf(who);
    }
    function allowance(address tokenOwner, address spender) public view returns(uint) {
        return asset.allowance(tokenOwner, spender);
    }
    function approve(address spender, uint value) public {
        if (!asset.delegateApprove(msg.sender, spender, value)) revert();
        emit Approval(msg.sender, spender, value);
    }
    function transfer(address to, uint value) public {
        if (!asset.delegateTransfer(msg.sender, to, value)) revert();
        emit Transfer(msg.sender, to, value);
    }
    function transferFrom(address from, address to, uint value) public {
        if (!asset.delegateTransferFrom(msg.sender, from, to, value)) revert();
        emit Transfer(from, to, value);
    }
    function mint() public payable {
        if (!asset.mint(msg.sender, msg.value)) revert();
        emit Transfer(address(0), msg.sender, msg.value);
    }
    function burn(uint value) public {
        if (!asset.burn(msg.sender, value)) revert();
        msg.sender.transfer(value);
        emit Transfer(msg.sender, address(0), value);
    }
    function sweepERC721(address token, uint value) public onlyOwner {
        if (!asset.sweep(token, owner, value)) revert();
    }
    function sweep(IERC20 token, uint value) public onlyOwner {
        if (!token.transfer(owner, value)) revert();
    }
    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0) && address(asset) != newOwner && address(this) != newOwner);
        owner = newOwner;
    }
    function () external payable {
        if (msg.value > 0) {
            if (!asset.mint(owner, msg.value)) revert();
            emit Transfer(msg.sender, owner, msg.value);
        }
    }
}