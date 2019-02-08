pragma solidity ^0.5.3;
contract Sender {
    event Sent(address indexed sender, address indexed recipient, uint indexed amount);
    constructor() public {}
    function total(uint[] memory a) internal pure returns(uint) {
        uint b;
        uint c;
        while (b < a.length) {
            if (a[b] > 0) c += a[b];
            b++;
        }
        return c;
    }
    function batchTransfer(address[] memory recipients, uint[] memory values) public payable {
        uint length = recipients.length;
        uint remaining = msg.value;
        uint i;
        if (recipients.length > values.length) length = values.length;
        while (i < length) {
            if (recipients[i] != address(0) && address(this) != recipients[i] && values[i] > 0 && values[i] <= remaining) {
                address(uint160(recipients[i])).transfer(values[i]);
                remaining -= values[i];
                emit Sent(msg.sender, recipients[i], values[i]);
            }
            i++;
        }
        if (remaining > 0) msg.sender.transfer(remaining);
    }
}