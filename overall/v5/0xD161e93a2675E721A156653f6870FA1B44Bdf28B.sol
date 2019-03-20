pragma solidity >=0.4.22 <0.6.0;

contract PigBank{
    
    mapping (address=>address) public pigs;
    
    function createPig(uint256 numberOfFinneysWeekly,uint256 numbersOfWeeks) public payable{
        require(pigs[msg.sender]==address(0),'only one pig at a time');
        MoneyPig pig = (new MoneyPig).value(msg.value)(numberOfFinneysWeekly,numbersOfWeeks,msg.sender);
        pigs[msg.sender] = address(pig);
        emit PigCreated(msg.sender,numberOfFinneysWeekly,numbersOfWeeks);
        
    }
    
    function getPig() public view returns(address){
        return pigs[msg.sender];
    }
    
    function goToHeavens(address owner) public{
        require(address(pigs[owner]).balance == 0);
        pigs[owner] = address(0);
    }
    
    event PigCreated(address indexed owner, uint256 numberOfFinneysWeekly, uint256 numberOfWeeks);
}

contract MoneyPig {
    
    uint32 public constant NUMBER_OF_SECONDS_IN_WEEK=24*7*3600;
    
    struct WalletData{
        address payable owner;
        uint32 numberOfFinneysWeekly;
        uint8 numbersOfWeeks;
        uint64 lastPayment;
    }
    
    WalletData data;
    PigBank public bank;
    
    constructor(uint256 numberOfFinneysWeekly,uint256 numbersOfWeeks,  address _owner) public payable{
        require(msg.value==numberOfFinneysWeekly*(1 finney));
        bank = PigBank(msg.sender);
        data.owner = address(uint256(_owner));
        data.numbersOfWeeks = uint8(numbersOfWeeks);
        data.numberOfFinneysWeekly = uint32(numberOfFinneysWeekly);
        data.lastPayment = getNow();
    }
    
    function numberOfWeeksToTheEnd() public view returns(uint8){
        return data.numbersOfWeeks;
    }
    
    function numberOfFinneysWeekly() public view returns(uint32){
        return data.numberOfFinneysWeekly;
    }
    
    function getNow() public view returns(uint64){
        return uint64(now*3000);
    }
    
    function numberOfWeeksSinceLast() public view returns(uint8){
        return uint8((getNow()-data.lastPayment)/NUMBER_OF_SECONDS_IN_WEEK);
    }
    
    function feedThePig() public payable{
        require(numberOfWeeksSinceLast()>0,'feed the pig only once a week');
        require(msg.value==uint256(data.numberOfFinneysWeekly)*(1 finney),'too much or too little ether');
        //punishment
        if(numberOfWeeksSinceLast()>1){
            data.numbersOfWeeks = (255-numberOfWeeksSinceLast()<data.numbersOfWeeks)?255:data.numbersOfWeeks+numberOfWeeksSinceLast();
            emit PigFeeded(data.owner,data.numbersOfWeeks);
        }
        data.lastPayment = getNow();
        if(data.numbersOfWeeks>1){
            data.numbersOfWeeks = data.numbersOfWeeks-1;
        }else{
            address _b = address(bank);
            address payable _owner = data.owner;
            selfdestruct(_owner);
            PigBank(_b).goToHeavens(_owner);
        } 
    }
    
    event PigFeeded(address indexed owner, uint256 numbersOfWeeks);
    
}