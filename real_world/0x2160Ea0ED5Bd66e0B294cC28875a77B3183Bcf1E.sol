pragma solidity 0.5.0;

/*
 * @title Chimalli
 * @notice Storage utility for IPFS hashes that point to secret pieces of a previously split secret.
 * @author Jose Aguinaga (@jjperezaguinaga) <me@jjperezaguinaga.com>
 */
contract Chimalli {

    /*
     * @title LogAddedSecret
     * @notice Event for notifying whenever a secret has been successfully added to our Chimalli
     * @type event
     * @param (address) _secretOwner    = The owner of the secret the chimalli stored
     * @param (bytes32) _ipfsHash       = The IPFS with the location of the secret used
     * @param (bytes32) _secretHash     = The hash of the name of the secret as an identifier
     */
    event LogAddedSecret(address indexed _secretOwner, bytes32 _ipfsHash, bytes32 _secretHash);

    address payable public owner;
    mapping (address => Secret) public secrets;
    mapping (bytes32 => uint256) private indicies;

    struct Secret {
        bytes32 ipfsHash;
        bytes32 nameHash;
    }

    /*
     * @title constructor
     * @notice Our contract constructor, which receives a keeper as a main argument
     * @type constructor
     * @param (address) _owner  = The secret keeper, the only one that can release the contents after request
     * @dev Although it’s convention to make msg.sender the owner, we want to be able to create Chimallis in behalf of other people.
     */
    constructor(address payable _owner) public {
        owner = _owner;
    }

    modifier isOwner() {require(msg.sender == owner, "Only the secret keeper can destroy the chimalli"); _;}

    /*
     * @title store
     * @notice Our storing method for the keeping secrets in our Chimalli
     * @type function
     * @param (bytes32) _ipfsHash   = The IPFS with the location of the encrypted secret
     * @param (bytes32) _nameHash   = The hash of the name of the secret as an identifier 
     */
    function store(bytes32 _ipfsHash, bytes32 _nameHash)
    external
    {
        Secret storage secret = secrets[msg.sender];
        secret.ipfsHash = _ipfsHash;
        secret.nameHash = _nameHash;
        emit LogAddedSecret(msg.sender, _ipfsHash, _nameHash);
    }

    function hasSecret()
    external
    view
    returns (bool)
    {
        Secret memory _secret = secrets[msg.sender];
        return _secret.ipfsHash != 0 && _secret.nameHash != 0;
    }

    /*
     * @title retrieve
     * @notice Our retrieval method for getting back stored secrets within our Chimalli
     * @type function
     * @return (bytes32, bytes32) The location of our IPFS Hash and hash of the name of the secret
     */
    function retrieve()
    external
    view
    returns (bytes32, bytes32)
    {
        return (secrets[msg.sender].ipfsHash, secrets[msg.sender].nameHash);
    }

    /*
     * @title keeper
     * @notice A simple getter for our secret keeper
     * @type function
     * @return (address) The address of the secret keeper.
     */
    function keeper() 
    external
    view
    returns (address)
    {
        return owner;
    }

    /*
     * @title kill
     * @notice Our self destruct method, usable only by a secret keeper
     * @type function
     */
    function kill()
    public
    isOwner
    {
        selfdestruct(owner);
    }
}