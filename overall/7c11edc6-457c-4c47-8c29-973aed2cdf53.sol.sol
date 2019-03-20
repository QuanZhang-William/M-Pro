//integer_overflow_minimal.sol
//Single transaction overflow
//Post-transaction effect: overflow escapes to publicly-readable storage

pragma solidity ^0.4.19;

contract BenchmarkOverflow {
    uint public count = 1;

    function run(uint256 input) public {
        count -= input;
    }
}


//integer_overflow_mapping_sym_1.sol

contract BenchmarkOverflowMapping {
    mapping(uint256 => uint256) map;

    function init(uint256 k, uint256 v) public {
        map[k] -= v;
    }
}

//reentrancy_dao.sol

contract BenchmarkReentrancy {
    mapping (address => uint) credit;
    uint balance;

    function withdrawAll() public {
        uint oCredit = credit[msg.sender];
        if (oCredit > 0) {
            balance -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require (callResult);
            credit[msg.sender] = 0;
        }
    }

    function deposit() public payable {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }
}