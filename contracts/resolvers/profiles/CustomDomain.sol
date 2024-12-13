// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../../utils/NameHash.sol";
import "../PublicResolver.sol";
contract DomainVerification {
    using NamehashLibrary for string;
    PublicResolver public resolver;
    struct Domain {
        string name;
        address owner;
        uint256 verificationCode;
        bool isVerified;
    }
    mapping(address =>mapping(string => Domain)) public domains; //mapping owner => name => Domain
    mapping(bytes32 => string) public mCustomDomainToName;
    event DomainRegistered(address indexed user, string domainName, uint256 code);
    event DomainVerified(address indexed user, string domainName);
    address public owner; 
    address public controller;
    mapping(string => address) public mDomainToSc;
    constructor()payable {
        owner = msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender == owner,"Only Owner can call");
        _;
    }

    modifier onlyController(){
        require(msg.sender == controller,"Only Controller can call");
        _;
    }
    function SetController(address _controller) public onlyOwner{
        controller = _controller;
    }
    function SetDefaultResolver(address _resolver) public onlyOwner {
        require(
            address(_resolver) != address(0),
            "ReverseRegistrar: Resolver address must not be 0"
        );
        resolver = PublicResolver(_resolver);
    }

    // Register a domain and generate a verification code
    function registerDomain(string memory domainName,string memory label) public returns(uint256){
        // bool exist = PublicResolver(resolver).checkCustomDomainExist(domainName);
        // require(!exist,"custom domain existed");
        if (domains[msg.sender][label].isVerified ){
            require(keccak256(abi.encodePacked(domains[msg.sender][label].name)) != 
            keccak256(abi.encodePacked(domainName)),"domain name was verified");
        }
        uint256 verificationCode = uint256(keccak256(abi.encodePacked(domainName, msg.sender, block.timestamp))) % 10000; // Generate a 4-digit code
        domains[msg.sender][label] = Domain(domainName,msg.sender, verificationCode, false);
        emit DomainRegistered(msg.sender, domainName, verificationCode);
        return verificationCode;

    }

    // Verify the domain by checking the provided code
    function verifyDomain(string memory domainName, uint256 code, address domainOwner,string memory label) public onlyController returns(bool){
        require(checkDomain(domainName,code,domainOwner,label),"Domain name mismatch or Verification code mismatch.");
        domains[domainOwner][label].isVerified = true;
        setCustomDomain(domainName,label);
        emit DomainVerified(domainOwner, domainName);
        mCustomDomainToName[keccak256(abi.encodePacked(domainName))] = label;
        return true;
    }
    function checkDomain(string memory domainName, uint256 code, address domainOwner,string memory label)public view returns(bool){
        if (keccak256(abi.encodePacked(domains[domainOwner][label].name)) != keccak256(abi.encodePacked(domainName)) || 
           domains[domainOwner][label].verificationCode != code)
        {
            return false;
        }
        return true;
    }
    function setCustomDomain(string memory domainName,string memory label)internal {
        require(address(resolver) != address(0),"custom domain resolver has not been set");
        bytes32 node = NamehashLibrary.namehash(label);
        PublicResolver(resolver).setCustomDomain(node, domainName);
    }

    // Get the verification code for the registered domain
    function getVerificationCode(string memory label) public view returns (uint256) {
        return domains[msg.sender][label].verificationCode;
    }

    // Check if the domain is verified
    function isDomainVerified(address user,string memory label) public view returns (bool) {
        return domains[user][label].isVerified;
    }
    function getDomainInfo(string memory _customDomain) public view returns(PublicResolver.GetInfo memory getinfo){
        string memory label = mCustomDomainToName[keccak256(abi.encodePacked(_customDomain))];
        bytes32 node = NamehashLibrary.namehash(label);
        getinfo = resolver.getAll(node);
    }
    //goi contract nay o chain thi can gui 10MTD
    function createSc(string memory _customDomain)external payable returns(address sc){
        require(mDomainToSc[_customDomain] == address(0),"already created sc");
        string memory label = mCustomDomainToName[keccak256(abi.encodePacked(_customDomain))];
        sc = address(new InfoCustomDomain(address(resolver),label));
        mDomainToSc[_customDomain] = sc;
    }

}
contract InfoCustomDomain{
    PublicResolver public resolver;
    string public label;
    constructor(address _resolver,string memory _label) payable{
        resolver = PublicResolver(_resolver);
        label = _label;

    }

    function getInfoDomain() public view returns(PublicResolver.GetInfo memory getinfo){
        bytes32 node = NamehashLibrary.namehash(label);
        getinfo = resolver.getAll(node);
    }

}