pragma solidity ^0.4.24;

// File: contracts/ERC20Interface.sol

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
  function totalSupply() public constant returns (uint);
  function balanceOf(address tokenOwner) public constant returns (uint balance);
  function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
  function transfer(address to, uint tokens) public returns (bool success);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);

  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// File: contracts/util/DormantQueue.sol

contract DormantQueue
{
  uint32 dormantTime = 1 minutes;

  struct DormantToken {
    uint amount;
    uint32 activeTime;
  }

  struct Queue {
    DormantToken[100] data;
    uint front;
    uint back;
  }

  /// @dev the number of elements stored in the queue.
  function length(Queue storage q) internal view returns (uint) {
    return q.back - q.front;
  }

  /// @dev the number of elements this queue can hold
  function capacity(Queue storage q) internal view returns (uint) {
    return q.data.length - 1;
  }

  /// @dev push a new element to the back of the queue
  function push(Queue storage q, uint token) internal
  {
    if (((q.back + 1) % q.data.length) == q.front)
      return; // throw;
    q.data[q.back].amount = token;
    q.data[q.back].activeTime = uint32(now) + dormantTime;
    q.back = (q.back + 1) % q.data.length;
  }

  /// @dev remove and return the element at the front of the queue
  function popActive(Queue storage q) internal returns (uint r)
  {
    if ((q.back == q.front) || (q.data[q.front].activeTime > now))
      return; // throw;
    r = q.data[q.front].amount;
    delete q.data[q.front];
    q.front = (q.front + 1) % q.data.length;
  }
  
  function countActive(Queue storage q) internal view returns (uint) {
    uint amount = 0;
    uint ptr = q.front;
    while((ptr != q.back) && (q.data[ptr].activeTime <= now)) {
      amount += q.data[ptr].amount;
      ptr = (ptr + 1) % q.data.length;
    }
    return amount;
  }
}

// File: contracts/util/Owned.sol

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
  address public owner;
  address public newOwner;

  event OwnershipTransferred(address indexed _from, address indexed _to);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner, "Sender is not the owner!");
    _;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    newOwner = _newOwner;
  }
  
  function acceptOwnership() public {
    require(msg.sender == newOwner, "Sender is not the new owner!");
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    newOwner = address(0);
  }
}

// File: contracts/util/SafeMath.sol

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
  function safeAdd(uint a, uint b) public pure returns (uint c) {
    c = a + b;
    require(c >= a, "This addition will cause overflow!");
  }

  function safeSub(uint a, uint b) public pure returns (uint c) {
    require(b <= a, "This substraction will cause unsigned integer underflow!");
    c = a - b;
  }

  function safeMul(uint a, uint b) public pure returns (uint c) {
    c = a * b;
    require(a == 0 || c / a == b, "This multiplication will cause overflow!");
  }
  
  function safeDiv(uint a, uint b) public pure returns (uint c) {
    require(b > 0, "Negative divisor or division by zero!");
    c = a / b;
  }
}

// File: contracts/HappyToken.sol

// ----------------------------------------------------------------------------
// 'HAPPY' token contract
//
// Deployed to : HappyTeamWallet
// Symbol      : HPT
// Name        : Happy Token
// Total supply: 1000000000
// Decimals    : 18
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
  function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract HappyToken is ERC20Interface, Owned, SafeMath, DormantQueue {
  address public happyTeamWallet;
  string public symbol;
  string public  name;
  uint8 public decimals;
  uint public _totalSupply;

  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;
  mapping(address => uint) powerBalances;
  mapping(address => Queue) dormantLists;


  // ------------------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------------------
  constructor(address _happyTeamWallet) public {
    happyTeamWallet = _happyTeamWallet;
    symbol = "HPT";
    name = "Happy Token";
    decimals = 18;
    _totalSupply = 1000000000000000000000000000;
    balances[happyTeamWallet] = _totalSupply;
    emit Transfer(address(0), happyTeamWallet, _totalSupply);
  }


  // ------------------------------------------------------------------------
  // Total supply
  // ------------------------------------------------------------------------
  function totalSupply() public view returns (uint) {
    return _totalSupply - balances[address(0)];
  }


  // ------------------------------------------------------------------------
  // Get the token balance for account tokenOwner
  // ------------------------------------------------------------------------
  function balanceOf(address tokenOwner) public view returns (uint balance) {
    return balances[tokenOwner];
  }


  // ------------------------------------------------------------------------
  // Transfer the balance from token owner's account to to account
  // - Owner's account must have sufficient balance to transfer
  // - 0 value transfers are allowed
  // ------------------------------------------------------------------------
  function transfer(address to, uint tokens) public returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], tokens);
    balances[to] = safeAdd(balances[to], tokens);
    emit Transfer(msg.sender, to, tokens);
    return true;
  }


  // ------------------------------------------------------------------------
  // Token owner can approve for spender to transferFrom(...) tokens
  // from the token owner's account
  //
  // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
  // recommends that there are no checks for the approval double-spend attack
  // as this should be implemented in user interfaces 
  // ------------------------------------------------------------------------
  function approve(address spender, uint tokens) public returns (bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    return true;
  }


  // ------------------------------------------------------------------------
  // Transfer tokens from the from account to the to account
  // 
  // The calling account must already have sufficient tokens approve(...)-d
  // for spending from the from account and
  // - From account must have sufficient balance to transfer
  // - Spender must have sufficient allowance to transfer
  // - 0 value transfers are allowed
  // ------------------------------------------------------------------------
  function transferFrom(address from, address to, uint tokens) public returns (bool success) {
    balances[from] = safeSub(balances[from], tokens);
    allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
    balances[to] = safeAdd(balances[to], tokens);
    emit Transfer(from, to, tokens);
    return true;
  }


  // ------------------------------------------------------------------------
  // Returns the amount of tokens approved by the owner that can be
  // transferred to the spender's account
  // ------------------------------------------------------------------------
  function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
    return allowed[tokenOwner][spender];
  }


  // ------------------------------------------------------------------------
  // Token owner can approve for spender to transferFrom(...) tokens
  // from the token owner's account. The spender contract function
  // receiveApproval(...) is then executed
  // ------------------------------------------------------------------------
  function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
    return true;
  }


  // ------------------------------------------------------------------------
  // Don't accept ETH
  // ------------------------------------------------------------------------
  function () public payable {
    revert();
  }


  // ------------------------------------------------------------------------
  // Owner can transfer out any accidentally sent ERC20 tokens
  // ------------------------------------------------------------------------
  function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
    return ERC20Interface(tokenAddress).transfer(owner, tokens);
  }

  // Development of POWER concept

  function switchTokenToPower(uint tokens) public returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], tokens);
    powerBalances[msg.sender] = safeAdd(powerBalances[msg.sender], tokens);
    return true;
  }

  function powerBalanceOf(address tokenOwner) public view returns (uint powerBalance) {
    return powerBalances[tokenOwner];
  }

  function switchPowerToToken(uint powers) public returns (bool success) {
    powerBalances[msg.sender] = safeSub(powerBalances[msg.sender], powers);
    push(dormantLists[msg.sender], powers);
    return true;
  }

  function countClaimableToken() public view returns (uint) {
    return countActive(dormantLists[msg.sender]);
  }

  function claimToken() public returns (bool success) {
    if (countActive(dormantLists[msg.sender]) > 0) {
      uint tokens = popActive(dormantLists[msg.sender]);
      balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
      return true;
    }
    return false;
  } 
}
