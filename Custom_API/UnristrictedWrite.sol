contract UnristrictedWrite {
    uint a = 100;
    uint b = 10;
    function balanceOf(uint _id) {
        a = _id;
        b = 11;
    }
}
