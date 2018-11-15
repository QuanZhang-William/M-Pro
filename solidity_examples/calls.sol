contract Test{
    mapping(uint256 => uint256) items;

    function add (uint256 a, uint256 b) public{
        items[a] = b;
    }

}
