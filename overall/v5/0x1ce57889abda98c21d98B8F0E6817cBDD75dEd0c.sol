pragma solidity ^0.5.3;
contract ERC20 {
    function balanceOf(address who) public view returns(uint);
    function mint(address tokenOwner, uint value) public returns(bool);
    function burn(address tokenOwner, uint value) public returns(bool);
    function sweep(address token, uint value) public returns(bool);
}
contract ERC20Control {
    address public admin;
    ERC20 public asset;
    event Converted(address indexed user, address indexed fromToken, address indexed toToken, uint fromAmount, uint toAmount);
    constructor(address _admin, address _asset) public {
        admin = _admin;
        asset = ERC20(_asset);
    }
    function () external payable {
        donation();
    }
    function donation() public payable {
        asset.mint(admin, msg.value);
        emit Converted(msg.sender, address(0), address(asset), msg.value, 0);
        emit Converted(admin, address(0), address(asset), 0, msg.value);
    }
    function purchase() public payable {
        asset.mint(msg.sender, msg.value);
        emit Converted(msg.sender, address(0), address(asset), msg.value, msg.value);
    }
    function sell(uint amount) public {
        require(amount > 0);
        if (asset.burn(msg.sender, amount)) {
            msg.sender.transfer(amount);
            emit Converted(msg.sender, address(asset), address(0), amount, amount);
        }
    }
    function sellAll() public {
        uint amount = asset.balanceOf(msg.sender);
        if (asset.burn(msg.sender, amount)) {
            msg.sender.transfer(amount);
            emit Converted(msg.sender, address(0), address(asset), amount, amount);
        }
    }
    function sweep(address token) public {
        require(msg.sender == admin);
        asset.sweep(token, ERC20(token).balanceOf(address(asset)));
    }
    function changeAdmin(address _admin) public payable {
        require(msg.sender == admin);
        require(_admin != address(0) && _admin != address(asset) && address(this) != admin);
        uint adminBalance = asset.balanceOf(admin);
        if (asset.burn(admin, adminBalance)) {
            if (asset.mint(_admin, adminBalance)) {
                admin = _admin;
                emit Converted(msg.sender, address(asset), address(0), adminBalance, 0);
                emit Converted(_admin, address(0), address(asset), 0, adminBalance);
            }
        }
    }
}