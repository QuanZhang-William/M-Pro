contract Suicide {

  uint256 a = 10;
  function kill(address addr) {
    selfdestruct(addr);
  }

}
