contract BecToken{
    /**
    * Public variables of the token
    * The following variables are OPTIONAL vanities. One does not have to include them.
    * They allow one to customise the token contract & in no way influences the core functionality.
    * Some wallets/interfaces might not even bother to look at this information.
    */
    string public name = "BeautyChain";
    string public symbol = "BEC";
    string public version = '1.0.0';
    uint8 public c = 18;

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     */
    constructor() public {
        c=10;
    }

    function () external {
        //if ether is sent to this address, send it back.
        revert();
    }
}
