// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "../ResolverBase.sol";
import "./ITextResolver.sol";
import "forge-std/console.sol";
abstract contract TextResolver is ITextResolver, ResolverBase {
    mapping(uint64 => mapping(bytes32 => mapping(string => string))) versionable_texts;
    // string [] public customDomainArr;
    /**
     * Sets the text data associated with an ENS node and key.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param key The key to set.
     * @param value The text data value to set.
     */
    function setText(
        bytes32 node,
        string calldata key,
        string calldata value
    ) external virtual authorised(node) {
        // if (keccak256(abi.encodePacked(key)) == keccak256(abi.encodePacked("customdomain"))){
        //     bool exist = checkCustomDomainExist(value);
        //     require(!exist,"custom domain existed");
        //     customDomainArr.push(value);
        // }
        versionable_texts[recordVersions[node]][node][key] = value;
        emit TextChanged(node, key, key, value);
    }
    // function checkCustomDomainExist(string memory _customDomain)public view returns(bool exist){
    //     uint256 len = customDomainArr.length;
    //     if (len == 0) {
    //         return exist;
    //     }
    //     for(uint256 i=0; i<len; i++ ){
    //         if(keccak256(abi.encodePacked(_customDomain)) == keccak256(abi.encodePacked(customDomainArr[i]))){
    //             exist = true;
    //             return exist;
    //         }
    //     } 
    //     exist = false;
    // }
    function setBatchText(
        bytes32 node,
        string[] calldata keys,
        string[] calldata values
    )external virtual authorised(node){
        require(keys.length == values.length,"lengths of array not equal");
        for(uint256 i=0; i< keys.length;i++ ){
            versionable_texts[recordVersions[node]][node][keys[i]] = values[i];
            emit TextChanged(node, keys[i], keys[i], values[i]);
        }
    }
    /**
     * Returns the text data associated with an ENS node and key.
     * @param node The ENS node to query.
     * @param key The text data key to query.
     * @return The associated text data.
     */
    function text(
        bytes32 node,
        string calldata key
    ) external view virtual override returns (string memory) {
        return versionable_texts[recordVersions[node]][node][key];
    }

    function supportsInterface(
        bytes4 interfaceID
    ) public view virtual override returns (bool) {
        return
            interfaceID == type(ITextResolver).interfaceId ||
            super.supportsInterface(interfaceID);
    }
}
