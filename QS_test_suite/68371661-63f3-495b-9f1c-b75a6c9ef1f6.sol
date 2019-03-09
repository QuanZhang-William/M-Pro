pragma solidity ^0.4.24;

contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

contract Destructible is Ownable {

  function destroy() public onlyOwner {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) public onlyOwner {
    selfdestruct(_recipient);
  }
}

contract Activatable is Ownable {
    event Deactivate(address indexed _sender);
    event Activate(address indexed _sender);

    bool public active = false;

    modifier whenActive() {
        require(active, "Room status must be active to call this function");
        _;
    }

    modifier whenNotActive() {
        require(!active, "Room status must be inactive to call this function");
        _;
    }

    function deactivate() public whenActive onlyOwner {
        active = false;
        emit Deactivate(msg.sender);
    }

    function activate() public whenNotActive onlyOwner {
        active = true;
        emit Activate(msg.sender);
    }

}


contract Room is Destructible, Pausable, Activatable {

    mapping (uint => bool) public rewardSent;

    event Deposited(
        address indexed _depositor,
        uint _depositedValue
    );

    event RewardSent(
        address indexed _dest,
        uint _reward,
        uint _id
    );

    event RefundedToOwner(
        address indexed _dest,
        uint _refundedBalance
    );

    constructor(address _creator) public payable {
        owner = _creator;
    }

    function deposit() external payable whenNotPaused {
        require(msg.value > 0, "Deposited value must be larger than 0");
        emit Deposited(msg.sender, msg.value);
    }

    function sendReward(uint _reward, address _dest, uint _id) external onlyOwner {
        require(!rewardSent[_id], "Reward had been already sent to the selected question");
        require(_reward > 0, "Reward must be larger than 0");
        require(address(this).balance >= _reward, "Contract must have larger balance than amount of reward");
        require(_dest != owner, "Owner cannot send reward to oneself");

        rewardSent[_id] = true;
        _dest.transfer(_reward);
        emit RewardSent(_dest, _reward, _id);
    }

    function refundToOwner() external whenNotActive onlyOwner {
        require(address(this).balance > 0, "Contract balance must be larger than 0");

        uint refundedBalance = address(this).balance;
        owner.transfer(refundedBalance);
        emit RefundedToOwner(msg.sender, refundedBalance);
    }
}

contract RoomFactory is Destructible, Pausable {

    event RoomCreated(
        address indexed _creator,
        address _room,
        uint _depositedValue
    );

    function createRoom() external payable whenNotPaused {
        address newRoom = (new Room).value(msg.value)(msg.sender);
        emit RoomCreated(msg.sender, newRoom, msg.value);
    }
}