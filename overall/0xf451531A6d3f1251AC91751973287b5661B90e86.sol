// Generated by Jthereum TEST version!
pragma solidity ^0.5.2;
contract FINNEYToken
{
	// Contract details
	string public name = "FINNEY == 1/1000 of 1 ETH.";
	string public symbol = "FINNEY";
	uint8 public decimals = 18;
	uint256 private ratio = 1000;


	// Will match the amount of ETH held by this contract * 1000.
	uint256 public totalSuppy = 0;

	// All of the balances
	mapping (address => uint256) private balancesByAddress;

	// Buy an amount of FINNEY tokens equal to 1000 * the amount of ETH paid.
	function buy() public payable 
	{
		uint256 numberOfTokensBeingPurchased = ratio * msg.value;

		// Mint the new tokens
		totalSuppy += numberOfTokensBeingPurchased;

		// Compute the new balance for the buyer
		uint256 newBalance = balancesByAddress[msg.sender] + numberOfTokensBeingPurchased;

		// Sanity check
		require(newBalance > balancesByAddress[msg.sender]);

		// Set the balances
		balancesByAddress[msg.sender] = newBalance;


		// Source address ZERO indicates the tokens were minted.
		emit Transfer(address(0), msg.sender, numberOfTokensBeingPurchased);
		emit Purchase(msg.sender, numberOfTokensBeingPurchased);
	}

	// If someone sends some ETH to this contract, give them some FINNEY tokens!
	function () external 
	{
		buy();
	}


	// Redeemed tokens are 'unminted', and will no long exist.
	function redeem(uint256 amount) public 
	{
		// Compute the new balance for the seller
		uint256 newBalance = balancesByAddress[msg.sender] - amount;

		// Sanity check
		require(newBalance < balancesByAddress[msg.sender]);

		// Set the balances
		balancesByAddress[msg.sender] = newBalance;

		// 'unmint' the tokens
		totalSuppy -= amount;

		// Log the transaction
		emit Redeem(msg.sender, amount);

		uint256 amountOfETH = amount / ratio;

		/* Give the seller the appropriate amount of ETH.
		 * (NOTE: Control flow transfer could lead to reentrancy)
		 */


		msg.sender.transfer(amountOfETH);
	}

	function balanceOf(address who) public view returns (uint256) 
	{
		return balancesByAddress[who];
	}

	function transfer(address to, uint256 value) public returns (bool) 
	{
		// Compute the new balances
		uint256 newSenderBalance = balancesByAddress[msg.sender] - value;
		uint256 newToBalance = balancesByAddress[to] + value;

		// Sanity check
		require(balancesByAddress[msg.sender] > value);
		require(newToBalance > balancesByAddress[to]);

		// Set the balances
		balancesByAddress[msg.sender] = newSenderBalance;
		balancesByAddress[to] = newToBalance;

		// Log the transaction
		emit Transfer(msg.sender, to, value);

		return true;
	}

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Purchase(address indexed buyer, uint256 value);
	event Redeem(address indexed seller, uint256 value);
}