pragma solidity ^0.4.24;


contract Bank {

    mapping(address => uint256) accounts;

    function deposit() payable public {
        accounts[msg.sender] += msg.value;
    }

    function withdrawAll() public {
        msg.sender.call.value(accounts[msg.sender])();

        accounts[msg.sender] = 0;
    }

    /*
     * Get ETH balance of the contract
     */
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getAccountBalance() public view returns(uint256) {
        return accounts[msg.sender];
    }
}