// SPDX-License-Identifier: No Source
pragma solidity 0.8.19;
import "./profiles/IStorage.sol";
// import "forge-std/console.sol";
contract Storage {
    mapping(address => NameInfo []) public mAddToName;
    mapping(address => bool) public isController;
    address public owner;
    constructor()payable {
        owner = msg.sender;
    }
    modifier onlyOwner{
        require(msg.sender == owner,"only Owner");
        _;
    }
    modifier onlyController {
        require(isController[msg.sender],"not Controller");
        _;
    }
    function setController(address controller) public onlyOwner {
        isController[controller] = true;
    }
    //khi register
    function setInfo(address _owner, string memory _label, uint256 _expire ,uint256 _tokenid)public onlyController{
        mAddToName[_owner].push(NameInfo({
            label:_label,
            expire:_expire,
            tokenid: _tokenid
        }));
    }
    function dropInfo(address _owner, uint256 _tokenid) internal returns(uint256 expire,string memory label){
        uint256 len = mAddToName[_owner].length;
        for (uint256 i=0;i<len;i++){
            if (mAddToName[_owner][i].tokenid ==  _tokenid){
                expire = mAddToName[_owner][i].expire;
                label = mAddToName[_owner][i].label;
                mAddToName[_owner][i] = mAddToName[_owner][len-1];              
                mAddToName[_owner].pop();
                break;
            }
            
        }
    }
    //khi transfer name
    function updateOwner(address _oldOwner, uint256 _tokenid,address _newOwner)public onlyController returns(bool) {
        require(mAddToName[_oldOwner].length >0,"owner does not own this label to transfer");
        (uint256 expire, string memory label) = dropInfo(_oldOwner,_tokenid);
        setInfo(_newOwner,label,expire,_tokenid);
        return true;
    }
    //khi extend name
    function updateExpire(address _owner,string memory _label, uint256 _newExpire)public onlyController returns(bool) {        
        uint256 len = mAddToName[_owner].length;
        require(mAddToName[_owner].length >0,"owner does not own this label");
        for(uint256 i=0;i<len;i++){
            if (keccak256(abi.encodePacked(mAddToName[_owner][i].label)) ==  keccak256(abi.encodePacked(string.concat(_label,".mtd")))){
                 mAddToName[_owner][i].expire = _newExpire;    
                 break;            
            }
            
        }
        return true;
    }
    function getNames(address _owner,uint256 time) public view returns(NameInfo[] memory){
        uint256 len = mAddToName[_owner].length;
        uint256 count;
        for (uint256 i=0;i<len;i++){
            if (mAddToName[_owner][i].expire > time) {
                count++;
            }
        }
        NameInfo[] memory arr = new NameInfo[](count);
        uint256 j=0;
        for (uint256 i=0;i<len;i++){
            if (mAddToName[_owner][i].expire > time) {
                arr[j] = mAddToName[_owner][i];
                j++;
            }
        }
        return arr;
    }
    function getCurrentNames(address _owner) public view returns(NameInfo[] memory){
        uint256 len = mAddToName[_owner].length;
        uint256 count;
        for (uint256 i=0;i<len;i++){
            if (mAddToName[_owner][i].expire > block.timestamp) {
                count++;
            }
        }
        NameInfo[] memory arr = new NameInfo[](count);
        uint256 j=0;
        for (uint256 i=0;i<len;i++){
            if (mAddToName[_owner][i].expire > block.timestamp) {
                arr[j] = mAddToName[_owner][i];
                j++;
            }
        }
        return arr;
    }

}