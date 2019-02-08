pragma solidity ^0.5.3;

contract Hasher {
      function getEventTopic(string calldata _event) 
      external 
      pure 
      returns (bytes32) 
      {
            bytes memory b = bytes(_event);
            return keccak256(b);
      }
      
      function getFunctionSelector(string calldata _func) 
      external 
      pure 
      returns (bytes memory) 
      {
            return abi.encodeWithSignature(_func);
      }
}