pragma solidity 0.8.19;
struct NameInfo {
    string label;
    uint256 expire;
    uint256 tokenid;
}
interface IStorage{
    function setInfo(address _owner, string memory _label, uint256 _expire ,uint256 _tokenid)external ;
    function updateOwner(address _oldOwner, uint256 _tokenid,address _newOwner)external returns(bool);
    function updateExpire(address _owner,string memory _label, uint256 _newExpire)external  returns(bool) ;
    function getNames(address _owner) external view returns(NameInfo[] memory);
}