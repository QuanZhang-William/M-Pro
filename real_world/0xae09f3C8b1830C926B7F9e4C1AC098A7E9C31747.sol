pragma solidity ^0.5.0;

contract TxRelay {

    // この nonce は署名したアカウントがこの contract にアクセスした回数を記録する
    mapping(address => uint) public nonce;

    /*
     * @dev Relays meta transactions
     * @param sigV, sigR, sigS ECDSA signature on some data to be forwarded
     * @param destination Location the meta-tx should be forwarded to
     * @param data The bytes necessary to call the function in the destination contract.
     * @param sender address of sender who originally signed data
     */
    function relayMetaTx(
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS,
        address destination,
        bytes memory data,
        address sender
    ) public {

        // use EIP 191
        // 0x19 :: version :: relay :: sender :: nonce :: destination :: data
        bytes32 h = keccak256(abi.encodePacked(byte(0x19), byte(0), this, sender, nonce[sender], destination, data));
        address addressFromSig = ecrecover(h, sigV, sigR, sigS);

        // ここで sender と signature から復元した address がマッチしているかをチェック
        require(sender == addressFromSig, "success");

        // nonce を increment する
        nonce[sender]++;

        // 別コントラクトの method を call する
        // callcode では無いので msg.sender にはこのコントラクトの address が入る
        (bool success, ) = destination.call(data);
        require(success, "success");
    }
}