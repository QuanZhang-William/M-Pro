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
        secrets[msg.sender] = (
            Secret({
            ipfsHash: _ipfsHash,
            nameHash: _nameHash
            })
        );
        
        emit LogAddedSecret(msg.sender, _ipfsHash, _nameHash);
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

/*
 * @title Codex
 * @notice Storage manager for Chimalli type of contracts.
 * @author Jose Aguinaga (@jjperezaguinaga) <me@jjperezaguinaga.com>
 */
contract Codex {
    address public owner;
    mapping (address => Chimalli[]) public codex;

    /*
     * @title LogChimalliCreated
     * @notice Event for notifying whenever a chimalli has been successfully added to our Codex
     * @type event
     * @param (Chimalli) _chimalli  = The address of the newly created chimalli contract
     * @param (address) _address    = The address of the owner of the newly created chimalli
     */
    event LogChimalliCreated(Chimalli _chimalli, address _address);

    /*
     * @title constructor
     * @notice Our contract constructor, which receives no argument
     * @type constructor
     */
    constructor() public {
        owner = msg.sender;
    }

    /*
     * @title createChimalli
     * @notice Our chimalli factory method, allows us to create Chimalli contracts on demand
     * @type function
     * @param (address) _address   = The address of the Chimalli’s secret keeper
     */
    function createChimalli(address payable _address) 
    external
    {
        Chimalli chimalli = new Chimalli(_address);
        codex[msg.sender].push(chimalli);
        emit LogChimalliCreated(chimalli, _address);
    }

    /*
     * @title getCodexLength
     * @notice Our codex getter for seeing how many Chimallis per contract we have.
     * @type function
     * @param (address) _address = The address of the Chimalli’s secret keeper
     * @return (uint) The amount of Chimallis stored in our Codex per owner.
     */
    function getCodexLength(address _address)
    public
    view
    returns (uint) {
        return codex[_address].length;
    }

    /*
     * @title getChimalli
     * @notice Our codex getter for seeing the address of a specific chimalli.
     * @type function
     * @param (uint) _index = The index of the Chimalli’s contract we want to obtain per sender.
     * @return (Chimalli) The address of the sender’s Chimalli’s contract within our Codex.
     */
    function getChimalli(uint _index)
    public
    view
    returns (Chimalli) {
        return codex[msg.sender][_index];
    }
}