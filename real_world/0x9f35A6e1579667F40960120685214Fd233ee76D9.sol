// https://github.com/ConsenSys/uport-registry
pragma solidity 0.5.0;

contract ProfileRegistry{
    uint public version;
    address public previousPublishedVersion;
    mapping(bytes32 => mapping(address => mapping(address => bytes32))) public registry;

    constructor(address _previousPublishedVersion) public {
        version = 1;
        previousPublishedVersion = _previousPublishedVersion;
    }

    event Set(
        bytes32 indexed registrationIdentifier,
        address indexed issuer,
        address indexed subject,
        uint updatedAt
    );

  //create or update
    function set(bytes32 registrationIdentifier, address subject, bytes32 value) public {
        emit Set(registrationIdentifier, msg.sender, subject, now);
        registry[registrationIdentifier][msg.sender][subject] = value;
    }

    function get(bytes32 registrationIdentifier, address issuer, address subject) public view returns(bytes32) {
        return registry[registrationIdentifier][issuer][subject];
    }
}