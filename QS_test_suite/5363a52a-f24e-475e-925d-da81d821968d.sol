pragma solidity 0.4.24;

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts/Pool.sol

/**
 * @title Pool
 * @dev Pool contract to create new pool with configurations
 */
contract Pool {

    using SafeMath for uint;
    using SafeMath for uint256;

    uint private constant DEFAULT_GAS_PRICE = 40e9; // 40 Gwei

    enum PoolState {
        // @dev Pool is accepting ETH. Users can refund themselves in this state.
        OPEN,

        // @dev Eth can be refunded to all wallets. State is final.
        REFUNDED,

        // @dev Pool is closed and the funds are locked. No user refunds allowed.
        CLOSED,

        // @dev ETH is transferred out and the funds are locked. No refunds can be processed.
        // State cannot be re-opened.
        PAID,

        // @dev Available tokens are claimable by users.
        COMPLETED
    }

    // PoolState events
    event PoolOpened();
    event PoolAllocationConfigured(uint256 maxPoolAllocation, uint256 minContribution, uint256 maxContribution);
    event PoolClosed();
    event PoolPaidAndAwaitingTokens();
    event PoolCompleted();
    event PoolRefunded();
    event AddedToWhiteList(address participant);
    event RemovedFromWhiteList(address participant);
    event Paid(uint balance, uint poolFeeBalance);
    event TokenContractConfigured(address contractAddress);
    event WithdrawnTokens(address participant, uint tokens);
    event AdminFeeSettled(uint fee);
    event ParticipateContributed(address participant, uint amount);
    event ParticipantWithdrawn(address participant, uint amount);

    PoolState public state;

    struct Participant {
        bool admin;
        bool isWhitelisted;
        bool withdrawnTokens;
        bool exists;
        uint256 balance;
        uint256 tokenAllotted;
    }

    mapping(address => Participant) public participantsInfo;
    address public applicationOwner;
    address public poolOwner;
    address[] public participants;

    uint256 public maxContribution;
    uint256 public minContribution;
    uint256 public maxPoolAllocation;
    uint256 public totalPoolContribution;
    uint256 public poolFee;
    uint256 public totalTokenDrops;

    bool public hasWhitelist;
    bool public autoDistribution;
    bool public lockDestination;
    bool public fundRaised;

    ERC20Basic public erc20Token;

    /**
     * @dev If the pool is whitelisted, verifies the user is whitelisted.
     */
    modifier canDeposit(address _user) {
        if (hasWhitelist) {
            require(participantsInfo[msg.sender].isWhitelisted, "User is not whitelisted!");
        }
        _;
    }

    /**
     * @dev Verifies the address belongs to participant.
     */
    modifier participantOnly() {
        require(checkIfParticipantExist(), "User is not participated!");
        _;
    }

    /**
     * @dev Verifies the address belongs to owner or admin.
     */
    modifier onlyOwnerOrAdmin() {
        require((msg.sender == poolOwner) || (participantsInfo[msg.sender].admin), "Pool owner or admin");
        _;
    }

    /**
     * @dev Verifies the address belongs to owner or admin.
     */
    modifier onlyOwnerOrAdminOrApplicationOwner() {
        require(msg.sender == poolOwner || msg.sender == applicationOwner || participantsInfo[msg.sender].admin, "Pool owner or application owner or admin");
        _;
    }

    /**
     * @dev Verifies the pool is in the OPEN state.
     */
    modifier isOpen() {
        require(state == PoolState.OPEN, "POOL is not OPEN State");
        // Pool is not set to open!
        _;
    }

    /**
     * @dev Verifies the pool is in the CLOSED state.
     */
    modifier isClosed() {
        require(state == PoolState.CLOSED, "POOL is not CLOSED State");
        // Pool is not closed!
        _;
    }

    /**
     * @dev Verifies the pool is in the OPEN or CLOSED state.
     */
    modifier isOpenOrClosed() {
        require(state == PoolState.OPEN || state == PoolState.CLOSED, "POOL is not OPEN or CLOSED State");
        // Pool is not cancelable!
        _;
    }

    /**
     * @dev Verifies the user is able to call a refund.
     */
    modifier isUserRefundable() {
        require((state == PoolState.OPEN || state == PoolState.REFUNDED) && participantsInfo[msg.sender].balance > 0, "Pool is not user refundable!");
        _;
    }

    /**
     * @dev Verifies the pool is in the COMPLETED or PAID state.
     */
    modifier isPaid() {
        require(state == PoolState.PAID || state == PoolState.COMPLETED, "Pool is COMPLETED or PAID");
        // Pool is not awaiting or completed!
        _;
    }

    /**
     * @dev Verifies the pool is in the COMPLETED state.
     */
    modifier isCompleted() {
        require(state == PoolState.COMPLETED, "Pool is COMPLETED");
        // Pool is not completed!
        _;
    }

    constructor(
        address _applicationOwner,
        address[] _admins,
        uint256 _maxPoolAllocation,
        uint256 _maxContribution,
        uint256 _minContribution,
        uint256 _poolFee,
        uint256 _totalTokenDrops,
        bool _hasWhitelist,
        bool _autoDistribution,
        bool _lockDestination
    )
    public
    payable {
        applicationOwner = _applicationOwner;
        poolOwner = msg.sender;

        addAdmins(_admins);
        setPoolToOpen();
        setPoolAllocation(_maxPoolAllocation, _minContribution, _maxContribution);
        totalTokenDrops = _totalTokenDrops;
        autoDistribution = _autoDistribution;

        poolFee = _poolFee;
        lockDestination = _lockDestination;
        hasWhitelist = _hasWhitelist;
    }

    /**
     * @dev Adds the specified address to list of whitelisted.
     * @param _participants The address of new whitelisted participant.
     */
    function addAddressesToWhitelist(address[] _participants) external onlyOwnerOrAdmin {
        for (uint i = 0; i < participants.length; i++) {
            Participant storage participantInfo = participantsInfo[_participants[i]];
            participantInfo.isWhitelisted = false;
        }

        for (i = 0; i < _participants.length; i++) {
            participantInfo = participantsInfo[_participants[i]];
            participantInfo.isWhitelisted = true;
        }

        participants = _participants;
    }

    /**
     * @dev Adds the specified address to list of whitelisted.
     * @param _participant The address of new whitelisted participant.
     */
    function addToWhitelist(address _participant) external onlyOwnerOrAdmin {
        Participant storage participantInfo = participantsInfo[_participant];
        participantInfo.isWhitelisted = true;
        participants.push(_participant);

        emit AddedToWhiteList(_participant);
    }

    /**
     * @dev Removes the specified address to list of whitlisted.
     * @param _participant The address of whitelisted participant to be removed.
     */
    function removeFromWhitelist(address _participant) external onlyOwnerOrAdmin {
        Participant storage participantInfo = participantsInfo[_participant];
        participantInfo.isWhitelisted = false;

        emit RemovedFromWhiteList(_participant);
    }

    /**
     * @dev Set min and max contribution changes
     */
    function setPoolAllocation(
        uint256 _maxPoolAllocation,
        uint256 _minimumContribution,
        uint256 _maximumContribution)
    public
    onlyOwnerOrAdmin isOpen
    {
        require(_minimumContribution <= _maximumContribution, "Minimum contribution should be less than max contribution!");
        require(_maximumContribution <= _maxPoolAllocation, "Max contribution should be less than max allocation!");

        maxPoolAllocation = _maxPoolAllocation;
        minContribution = _minimumContribution;
        maxContribution = _maximumContribution;

        emit PoolAllocationConfigured(maxPoolAllocation, minContribution, maxContribution);
    }

    /**
     * @dev Set Token Contract Address to confirm correct tokens have been transferred
     */
    function setTokenContract(address _contractAddress) public payable onlyOwnerOrAdmin isPaid {
        erc20Token = ERC20Basic(_contractAddress);

        emit TokenContractConfigured(_contractAddress);

        setTokenAllocation();
    }

    /**
     * @dev Distribute tokens for each token drop.
     */
    function distributeTokens() public payable onlyOwnerOrAdmin {
        setTokenAllocation();
    }

    /**
     * @dev Contribute ETH to Pool
     */
    function contribute() public payable canDeposit(msg.sender) isOpen {
        Participant storage participant = participantsInfo[msg.sender];
        require(msg.value > 0, "Contribution shouldn't be zero");

        uint contributionSum = totalPoolContribution.add(msg.value);

        require(msg.value >= minContribution, "Contribution should be greater than minimum contribution");
        require(msg.value <= maxContribution, "Contribution should be less than maximum contribution");
        require(contributionSum <= maxPoolAllocation, "Contribution should not exceed the maximum pool allocation");

        if (participant.exists) {
            uint balanceSum = participant.balance.add(msg.value);
            require(balanceSum <= maxContribution, "Contribution should be less than maximum contribution");
        } else {
            participant.exists = true;
            participants.push(msg.sender);
        }

        participant.balance = participant.balance.add(msg.value);

        // Updated the total pool value
        totalPoolContribution = totalPoolContribution.add(msg.value);

        // Update fund raised status
        updateFundRaised();

        emit ParticipateContributed(msg.sender, msg.value);
    }

    /**
     * @dev Withdraw contributed ETH
     */
    function withdrawContribution()
    public
    participantOnly
    isUserRefundable
    {
        Participant storage participant = participantsInfo[msg.sender];

        uint contributionBalance = participant.balance;
        totalPoolContribution = totalPoolContribution.sub(contributionBalance);
        participant.balance = 0;

        msg.sender.transfer(contributionBalance);

        emit ParticipantWithdrawn(msg.sender, contributionBalance);
    }

    /**
     * @dev Withdraw part of contributed ETH
     */
    function withdrawPartialContribution(uint _withdrawalAmount) public participantOnly isUserRefundable {
        Participant storage participant = participantsInfo[msg.sender];
        uint contributionBalance = participant.balance;

        require(_withdrawalAmount <= contributionBalance, "withdrawal amount should be lesser than contribution balance");

        totalPoolContribution = totalPoolContribution.sub(_withdrawalAmount);
        participant.balance = contributionBalance - _withdrawalAmount;

        msg.sender.transfer(_withdrawalAmount);

        emit ParticipantWithdrawn(msg.sender, _withdrawalAmount);
    }

    /**
     * @dev Transfer funds to poolOwner address
     */
    function transferFund() public isClosed onlyOwnerOrAdmin {
        uint totalContribution = address(this).balance;

        uint poolFeeBalance = totalContribution.mul(poolFee).div(100000);
        uint remainingBalance = totalContribution.sub(poolFeeBalance);

        if (autoDistribution) {
            uint autoDistributionGasFee = getAutoDistributionFees(DEFAULT_GAS_PRICE, participants.length, totalTokenDrops);
            remainingBalance = remainingBalance.sub(autoDistributionGasFee);
        }

        if (!(state == PoolState.PAID)) {
            setPoolToPaid();
            msg.sender.transfer(remainingBalance);
        }

        emit Paid(remainingBalance, poolFeeBalance);
    }

    /**
     * @dev Withdraw tokens after pool is complete
     */
    function withdrawERC20() public isCompleted {
        require(checkIfParticipantExist(), "Participant Exists");
        require(
            !participantsInfo[msg.sender].withdrawnTokens && participantsInfo[msg.sender].tokenAllotted > 0,
            "Participant Contributed"
        );

        uint allocatedTokens = participantsInfo[msg.sender].tokenAllotted;
        participantsInfo[msg.sender].tokenAllotted = 0;
        participantsInfo[msg.sender].withdrawnTokens = true;

        erc20Token.transfer(msg.sender, allocatedTokens);

        emit WithdrawnTokens(msg.sender, allocatedTokens);
    }

    /**
     * @dev Get Contributor Token Balance
     */
    function getContributorTokenBalance() public view returns (uint balance, uint alloc) {
        Participant storage participant = participantsInfo[msg.sender];
        uint totalTokenBalance = erc20Token.balanceOf(address(this));
        uint tokenAllocation = participant.balance.mul(totalTokenBalance).div(totalPoolContribution);

        return (totalTokenBalance, tokenAllocation);
    }

    /**
     * @dev Gets Total pool contribution value
     */
    function getPoolValue() public view returns (uint) {
        return totalPoolContribution;
    }

    /**
     * @dev Gets pool settings
     */
    function getPoolSettings() public view returns (uint, uint, uint, uint, uint, uint, bool, bool, uint) {
        return (totalPoolContribution,
        maxPoolAllocation,
        minContribution,
        maxContribution,
        poolFee,
        totalTokenDrops,
        hasWhitelist,
        autoDistribution,
        uint(state)
        );
    }

    /**
     * @dev Gets Auto distribution value
     */
    function getAutoDistributionFees(uint _gasPrice, uint _participantCount, uint _totalTokenDrops) public pure returns(uint) {
        return _gasPrice.mul(_participantCount).mul(_totalTokenDrops).mul(150000);
    }

    /**
     * @dev Check if participant has already participated
     */
    function checkIfParticipantExist() public view returns (bool) {
        return participantsInfo[msg.sender].exists;
    }

    /**
     * @notice Allows the admin to set the state of the pool to OPEN.
     * @dev Requires that the sender is an admin, and the pool is currently CLOSED.
     */
    function setPoolToOpen() public onlyOwnerOrAdmin {
        state = PoolState.OPEN;
        emit PoolOpened();
    }

    /**
     * @notice Allows the admin to set the state of the pool to CLOSED.
     * @dev Requires that the sender is an admin, and the contract is currently OPEN.
     */
    function setPoolToClosed() public onlyOwnerOrAdmin isOpen {
        state = PoolState.CLOSED;
        emit PoolClosed();
    }

    /**
     * @notice Cancels the project and sets the state of the pool to REFUNDED.
     * @dev Requires that the sender is an admin, and the contract is currently OPEN or CLOSED.
     */
    function setPoolToRefunded() public onlyOwnerOrAdminOrApplicationOwner isOpenOrClosed {
        state = PoolState.REFUNDED;
        emit PoolRefunded();
    }

    /**
     * @dev Sets the pool to PAID.
     */
    function setPoolToPaid() internal {
        state = PoolState.PAID;
        emit PoolPaidAndAwaitingTokens();
    }

    /**
     * @dev Sets the pool to COMPLETED.
     */
    function setPoolToCompleted() internal {
        state = PoolState.COMPLETED;
        emit PoolCompleted();
    }

    /**
     * @dev Update fund raised
     */
    function updateFundRaised() internal isOpen {
        if (totalPoolContribution == maxPoolAllocation) {
            fundRaised = true;

            state = PoolState.CLOSED;
            emit PoolClosed();
        }
    }

    /**
     * @dev Adds the specified address to list of admins.
     * @param _admins The addresses of new admins.
     */
    function addAdmins(address[] _admins) internal {
        for (uint i = 0; i < _admins.length; i++) {
            addAdmin(_admins[i]);
        }
    }

    /**
     * @dev Adds the specified address to list of admins.
     * @param _newAdmin The address of new admin.
     */
    function addAdmin(address _newAdmin) internal {
        participantsInfo[_newAdmin].admin = true;
        participantsInfo[_newAdmin].exists = true;
        participantsInfo[_newAdmin].isWhitelisted = true;
        participants.push(_newAdmin);
    }

    /**
     * @dev Allocate tokens to each participants
     */
    function setTokenAllocation() internal onlyOwnerOrAdmin isPaid {
        uint totalTokenBalance = erc20Token.balanceOf(address(this));

        require(totalTokenBalance > 0, "Token balance shouldn't be zero");

        for (uint i = 0; i < participants.length; i++) {
            Participant storage participant = participantsInfo[participants[i]];
            participant.tokenAllotted = participant.balance.mul(totalTokenBalance).div(totalPoolContribution);
        }

        setPoolToCompleted();

        payOutAdminFee();

        if (autoDistribution) {
            withdrawTokensForAll();
        }
    }

    /**
     * @dev Pay out admin fee
     */
    function payOutAdminFee() internal isCompleted {
        uint totalContribution = address(this).balance;

        poolOwner.transfer(totalContribution);

        emit AdminFeeSettled(totalContribution);
    }

    /**
     * @dev Withdraw tokens for all participants automatically
     */
    function withdrawTokensForAll() internal isCompleted {
        for (uint i = 0; i < participants.length; i++) {
            Participant storage participant = participantsInfo[participants[i]];

            uint allocatedTokens = participant.tokenAllotted;
            participant.tokenAllotted = 0;
            participant.withdrawnTokens = true;

            if (allocatedTokens != 0) {
                erc20Token.transfer(participants[i], allocatedTokens);
                emit WithdrawnTokens(participants[i], allocatedTokens);
            }
        }
    }
}

// File: contracts/Application.sol

/**
 * @title Application
 * @dev Main Application Contract to Create New Pool
 */
contract Application {

    address public applicationOwner;
    bool public isOpen = true;
    address[] poolContracts;

    event NewPoolDeployed(address newPoolAddress);

    /**
    * @dev Reverts if not in subscription time range.
    */
    modifier onlyWhileOpen {
        // solium-disable-next-line security/no-block-members
        require(isOpen, "Only within a valid subscription period");
        _;
    }

    /**
     * @dev Verifies the address belongs to owner.
     */
    modifier onlyApplicationOwner() {
        require(msg.sender == applicationOwner, "Only Application Owner Accessible");
        _;
    }

    /**
     * @dev Constructor for Application contract take owner tho can close or open the contract.
     * @param _applicationOwner Address of application owner who can close or open the Application Contract
     */
    constructor(address _applicationOwner) public {
        applicationOwner = _applicationOwner;
    }

    function setClosed(bool _isOpen) public onlyApplicationOwner {
        isOpen = _isOpen;
    }

    /**
    * @dev Extend parent behavior requiring to be within contributing period
    * @param _poolOwner Address of pool owner
    * @param _admins Addresses of pool admins
    * @param _maxPoolAllocation The total pool allocation value
    * @param _maxContribution The maximum contribution value
    * @param _minContribution The minimum contribution value
    * @param _poolFee The admin pool fee value
    * @param _hasWhitelist Check is whitelist enabled
    * @param _autoDistribution Check is autoDistribution enabled
    * @param _lockDestination Check is lockDestination enabled
    */
    function createPool(
        address _poolOwner,
        address[] _admins,
        uint _maxPoolAllocation,
        uint _maxContribution,
        uint _minContribution,
        uint _poolFee,
        uint _totalTokenDrops,
        bool _hasWhitelist,
        bool _autoDistribution,
        bool _lockDestination)
    public
    onlyWhileOpen
    payable
    returns (address)
    {
        // Added this restriction in Application Contract
		// Explanation: Once this is true, I am assigning poolOwner = msg.sender in Pool.sol
        require(_poolOwner == msg.sender, "New pool should be created from only poolOwner's address");

        address pool = new Pool(
            applicationOwner,
            _admins,
            _maxPoolAllocation,
            _maxContribution,
            _minContribution,
            _poolFee,
            _totalTokenDrops,
            _hasWhitelist,
            _autoDistribution,
            _lockDestination
        );

        poolContracts.push(pool);

        emit NewPoolDeployed(pool);

        return pool;
    }
}
