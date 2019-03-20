pragma solidity ^0.5.2;

contract szfcMerkleRoot {

    uint64 oneHour= 3600000;

    // hash -> 精确时间戳
    mapping(bytes32 => uint64) hash2timestamp;

    //时间段 (时间戳（以小時为单位）->(hash[])
    mapping(uint64=> bytes32[]) public timestamp2hash;  //date -> merkle root hash

    function push(uint64 _timestamp, bytes32 _root) external{


        require(hash2timestamp[_root] == 0);

        //归结
        uint64 hour_point = _timestamp - _timestamp % oneHour;

        hash2timestamp[_root] = _timestamp;

        bytes32[] storage hashs = timestamp2hash[hour_point];

        hashs.push(_root);

    }


    function get(uint64 _timestamp) public view returns(bytes32[] memory){

        uint64 hour_point = _timestamp - _timestamp % oneHour;

        bytes32[] storage hashs = timestamp2hash[hour_point];

        return hashs;

    }


    function getTimestamp(bytes32 _root) public view returns(uint64){

        return hash2timestamp[_root];

    }

}