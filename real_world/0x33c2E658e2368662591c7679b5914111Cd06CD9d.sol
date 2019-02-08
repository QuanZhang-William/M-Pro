pragma solidity ^0.5.2;

///TODO: Tie the ammount required to the address instead of the entire smart contract
///TODO: Allow for several swaps at the same time
contract Token {
    function transfer(address _receiver, uint amount) public returns (bool);
    function balanceOf(address receiver)public returns(uint);
    function approve(address spender, uint tokens) public returns (bool);
    function transferFrom(address from, address to, uint tokens) public returns (bool);

}

/**
 *
 * @dev Implementation of a deterministic swap contract
 *
 * This implementation allows for tokens to exchange token in a trustless predetermined way
 * A naive implmentation of Token atomic swaps
 *
 */
contract Swap{
    // Keeps track of all the swaps that have been carried out
  	atomicSwapList [] public swaps;     

    //Keeps track of the latest swap for each address
    mapping (address => uint) public swap;

    // Keeps track of which users have contributed which amount of tokens to the smart contract
    mapping (address => tokensInAddress) public tokensHeld;


    address private owner;


    constructor () public {
        owner = msg.sender;
    }

    // Structure to store all the necessary information for any given swap
  	struct atomicSwapList{
        //Lead data
  	    Token lead;
  	    uint leadAmount;
  		Token tokenLeadContract;
  		bool leadHasAmount;
        uint leadExpectedAmount;
        Token leadExpectedContract;

        //Follow data
  	    Token follow;
        uint followAmount;
      	Token tokenFollowSC;
        bool followHasAmount;
        uint followExpectedAmount;
        Token followExpectedContract;

      //Swap Metadata
  		uint ratio;
      bool completed;
  	}

    /**
    *  @dev Structure to keep track of what user has contributed what ammount of which token
    */
    struct tokensInAddress{
      uint amount;
      address tokenAddress;
    }

    /**
     * @dev The swap function is called independently of whther the calling user is the Lead or the follower
     * @dev This allows for a higher usability and internal order matching so user dont have to communicate expictely to get orders fullfilled
     * @param _amount The amount the Lead is giving to the Follower
     * @param _receiver The predetermined follower
     * @param _tokenLeadContract The token smart contract the lead is putting forward
     * @param _expectedAmount The amount the lead is expecting for his tokens
     * @param _expectedSC The token type expected
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
  	function atomicSwap
    (
      uint _amount,
      address _receiver,
      address _tokenLeadContract,
      uint _expectedAmount,
      address _expectedSC
    )
    public
    {
        //Set up the check struct to be the one of the receiver to determine whether theres an initiated swap
        //mistake is 100% here
        uint check = swaps.length++ ;
        uint receive = swap[_receiver];
        atomicSwapList storage uniqueSwap = swaps[check];
        atomicSwapList storage receiver = swaps[receive];

        //This check determines whether a function caller has been involved in a swap before or in the case he has whether he is not currently involved in one
        //The receiving has never participated in a swap 
        //OR the receiver has participate but the latest one is marked as completed 
        //OR the msg.sender has nver participated in a swap 
        //OR The msg.sender latest swap is completed then we are allowed to create a new swap
        //if one of the conditions are met we create a swap in the last position of the swaps array
        
        if ((swap[_receiver] == 0)||(receiver.completed==true)){
            if (check == 0){
                check = 1 ;
            }
            else{
                //Store the state of the swaps and make sure both are on the same page
                swap[msg.sender] = check;
                swap[_receiver] = check;
                uniqueSwap = swaps[check];
    
                //Lead Confirmed Data
                uniqueSwap.lead = Token(msg.sender);
                uniqueSwap.leadAmount = _amount;
            	uniqueSwap.tokenLeadContract = Token(_tokenLeadContract);
                uniqueSwap.leadExpectedAmount = _expectedAmount;
                uniqueSwap.leadExpectedContract = Token(_expectedSC);
    
                //Follow Confirmed Data
                uniqueSwap.follow = Token(_receiver);
    
                //We probably want to call this somewhere else doe cause right now its redundant, maybe in the place of the secure chack thing in the safe transfer function contract
                tokensInAddress storage userTokens = tokensHeld[msg.sender];
                userTokens.tokenAddress = _tokenLeadContract;
                userTokens.amount = _amount;
                
                uniqueSwap.tokenLeadContract.transferFrom(msg.sender, address(this), _amount);
                //Approve the withdrawal of tokens
                //Require theres enough balance in the SC to continue
                //require(userTokens.tokenAddress == _tokenLeadContract);
                //require(userTokens.amount == _amount) ;
            }

        //else the user is assigned as the follower
        }else{
            if((receiver.follow == Token(msg.sender)) && (uniqueSwap.completed == false)){
  			    follow(_amount, _receiver, _tokenLeadContract, _expectedAmount, _expectedSC);
            }
  		}
  	}

    /**
     * @dev The swap function is called by the SC in case it determines the  caller of Swap is the follower it works like swap but assigns vcalues to the structure part
     * @dev of its counterpart "Follower". This allows for a higher usability and internal order matching so user dont have to communicate expictely to get orders fullfilled
     * @param _amount The amount the Lead is giving to the Follower
     * @param _receiver The predetermined follower
     * @param _tokenFollowContract The token smart contract the follower is putting forward
     * @param _expectedAmount The amount the lead is expecting for his tokens
     * @param _expectedContract The token type expected
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
  	function follow
    (
      uint _amount,
      address _receiver,
      address _tokenFollowContract,
      uint _expectedAmount,
      address _expectedContract
    )
    internal
    {
        //Make sure we are in the same Swap as our counterpart
    	uint swapIndex = swap[_receiver];
    	atomicSwapList storage uniqueSwap = swaps[swapIndex];
        //Follow confirmed data
    	uniqueSwap.follow = Token(msg.sender);
    	uniqueSwap.followAmount = _amount;
    	uniqueSwap.tokenFollowSC= Token(_tokenFollowContract);
        uniqueSwap.followExpectedAmount = _expectedAmount;
        uniqueSwap.followExpectedContract = Token(_expectedContract);

        //Require theres enough balance in the SC to continue
        require(tokensHeld[msg.sender].tokenAddress == _tokenFollowContract);
        require(tokensHeld[msg.sender].amount == _amount);


        uniqueSwap.tokenFollowSC.transferFrom(msg.sender, address(this), _amount);

        //Metadata
    	uniqueSwap.ratio = (uniqueSwap.leadAmount/uniqueSwap.followAmount);

        //Check we are on the same atomic swap or revert otherwise
    	if
    	(
            (uniqueSwap.followAmount == uniqueSwap.leadExpectedAmount)
            && (uniqueSwap.leadAmount == uniqueSwap.followExpectedAmount)
            && (uniqueSwap.tokenFollowSC == uniqueSwap.leadExpectedContract)
            && (uniqueSwap.tokenLeadContract == uniqueSwap.followExpectedContract)
        )
        {
        //We send over receiver to restore the correct swap instance
    	    distribute(_receiver);
    	}else{
            revert();
      }
  	}


    function registerTokenArrival(
        uint _amount,
        address _tokenLeadContract
    ) 
    internal
    {
          tokensHeld[msg.sender].tokenAddress = _tokenLeadContract;
            tokensHeld[msg.sender].amount = _amount;
    }
    /**
     * @dev The distribute function is called by the SC to distibute the coins its holding to each perosn in the swap
     * @param _receiver The predetermined follower to detemine the index of the swaps array we have to access
     */

  	function distribute(address _receiver)internal {
  		uint swapIndex = swap[_receiver];
      //TODO: Determine whether the users are actually holding any of the coins they claim they have, and if not revert
      //Call the Correct index back
  		atomicSwapList storage uniqueSwap = swaps[swapIndex];

      //Distribute the correct amount of tokens to each party
  		uniqueSwap.tokenLeadContract.transfer(address(uniqueSwap.follow), uniqueSwap.leadAmount);
  		uniqueSwap.tokenFollowSC.transfer(address(uniqueSwap.lead),uniqueSwap.followAmount);
      //Complete the swap
      uniqueSwap.completed = true;
  	}
}