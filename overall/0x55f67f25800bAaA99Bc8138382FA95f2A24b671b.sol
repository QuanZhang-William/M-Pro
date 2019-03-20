pragma solidity >= 0.5.0 < 0.6.0;
pragma experimental ABIEncoderV2;


contract CertificateFactory {
    
    address public admin = msg.sender;

    modifier onlyAdmin {
        require(admin == msg.sender, "You are not the admin");
        _;
    }
    
    mapping (address => int) public balancesMWh;
    mapping (address => int) public balancesFiat;
    
    mapping(uint => address) public certificateOwners;
    mapping(uint => bool) public certificateExists;
    mapping(address => uint) public certificateCounts;
    mapping(address => mapping(uint => uint)) public ownerCertificates;
    
    mapping(uint => address) public receiptOwners;
    mapping(uint => bool) public receiptExists;
    mapping(address => uint) public receiptCounts;
    mapping(address => mapping(uint => uint)) public ownerReceipts;
    
    struct Receipt {
        uint32 price;
        uint32 timestamp;
        address buyer;
        address seller;
        uint32 MWh;
        uint certificateID;
    }
    uint public receiptID = 1;
    mapping (uint => Receipt) public receipts;

    struct Certificate {
        string energyType;
        string country;
        string company;
        string plant;
        address addrOwner;
        uint32 timestamp;
        uint32 generationTimestamp;
        uint32 MWh;
        bool redeemed;
    }
    uint public certificateID = 1;
    mapping (uint => Certificate) public certificates;

    event LogNewCertificate(uint certificateID, string energyType, string country, string company, string plant, address addrOwner, uint32 timestamp, uint32 price, uint32 MWh);
    event LogRedeemCertificate(uint certificateID);

    function createCertificate(Certificate memory cert) private returns (uint certID) {
        require(cert.MWh > 0);
        
        certID = certificateID++;
        certificateOwners[certID] = cert.addrOwner;
        certificateCounts[cert.addrOwner] += 1;
        uint certIndex = certificateCounts[cert.addrOwner] - 1;
        ownerCertificates[cert.addrOwner][certIndex] = certID;
        balancesMWh[cert.addrOwner] += cert.MWh;
        certificateExists[certID] = true;
        
        cert.timestamp = uint32(now);
     
        certificates[certID] = cert;
        
        emit LogNewCertificate(certificateID, cert.energyType, cert.country, cert.company, cert.plant, cert.addrOwner, cert.timestamp, cert.generationTimestamp, cert.MWh);
        
        return certID;
    }
    
    function newCertificate (string memory energyType, string memory country, string memory company, string memory plant, address addrOwner, uint32 generationTimestamp, uint32 MWh) onlyAdmin public returns (uint certID) {
        Certificate memory cert = Certificate(energyType, country, company, plant, addrOwner, uint32(now), generationTimestamp, MWh, false);
        certID = createCertificate(cert);
        return certID;
    }
    
    function buyCertificate(uint certID, address buyer, uint32 MWh, uint32 price) onlyAdmin public returns (uint newCertID) {
        require(MWh > 0, "MWh value must be positve");
        require(certificates[certID].addrOwner != 0x0000000000000000000000000000000000000000, "Certificate not initialized");
        require(certificates[certID].MWh - MWh >= 0, "MHw amount must be equal or lower than remaing certificate MHw");
        require(certificates[certID].redeemed == false, "Certificate is redeemed");
        
        Certificate memory cert = certificates[certID];
        cert.addrOwner = buyer;
        cert.MWh = MWh;
        
        newCertID = createCertificate(cert);
        
        certificates[certID].MWh -= MWh;
        balancesMWh[certificates[certID].addrOwner] -= MWh;
        
        balancesFiat[certificates[certID].addrOwner] += price;
        balancesFiat[buyer] -= price;
        
        Receipt memory recpt = Receipt(price, uint32(now), buyer, certificates[certID].addrOwner, MWh, certID);

        receipts[receiptID] = recpt;
        receiptOwners[receiptID] = cert.addrOwner;
        receiptCounts[buyer] += 1;
        uint recptIndex = certificateCounts[buyer] - 1;
        ownerReceipts[buyer][recptIndex] = receiptID;
        receiptExists[receiptID] = true;
        receiptID++;
        
        return newCertID;
    }
    
    function redeemCertificate(uint certID) onlyAdmin public returns (bool success) { 
        require(certificates[certID].redeemed == false);
        certificates[certID].redeemed = true;
        emit LogRedeemCertificate(certID);
        
        return true;
    }
    
    function withdraw(address account, uint amount) onlyAdmin public returns (bool success) {
        require(balancesFiat[account] > 0, "balance should be positive");
        require(int(amount) > 0, "amount overflow");
        balancesFiat[account] -= int(amount);
        return true;
    }
    
     
    function settleDebt(address account, uint amount) onlyAdmin public returns (bool success) {
        require(balancesFiat[account] < 0, "balance should be negative");
        require(int(amount) > 0, "amount overflow");
        balancesFiat[account] += int(amount);
        return true;
    }

    function setAdmin(address newAdmin) onlyAdmin public {
        admin = newAdmin;
    }
    
    function removeFromCertificatesList(address owner, uint certID) private {
     for(uint i = 0; ownerCertificates[owner][i] != certID; i++){
       ownerCertificates[owner][i] = 0;
     }
   }
}