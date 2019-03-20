pragma solidity ^0.4.23;

interface IEthPrice {
  function getExchangeRateInUSD() public view returns (uint256);
  function getExchangeRateInCents() public view returns (uint256);
  function getValueFromDollars(uint256 dollars) public view returns (uint256);
  function getValueFromCents(uint256 cents) public view returns (uint256);
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract ExchangeRate is Ownable, IEthPrice {
  using SafeMath for uint256;

  uint256 constant ETHER_DIV_100 = 10 finney;

  uint256 private weiPerCent;
  uint256 public lastUpdated;

  constructor(uint256 _exchangeRate) {
    weiPerCent = _exchangeRate;
    lastUpdated = now;
  }

  function setExchangeRate(uint256 newExchangeRate, uint256 _lastUpdated) public onlyOwner {
    require(_lastUpdated > lastUpdated && _lastUpdated < now);
    lastUpdated = _lastUpdated;
    weiPerCent = newExchangeRate;
  }

  function getExchangeRateInUSD() public view returns (uint256) {
    return ETHER_DIV_100 / weiPerCent;
  }

  function getExchangeRateInCents() public view returns (uint256) {
    return 1 ether / weiPerCent;
  }

  function getValueFromDollars(uint256 dollars) public view returns (uint256) {
    return weiPerCent.mul(dollars).mul(100);
  }

  function getValueFromCents(uint256 cents) public view returns (uint256) {
    return weiPerCent.mul(cents);
  }
}
