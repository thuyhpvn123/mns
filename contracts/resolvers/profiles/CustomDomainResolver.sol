// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "../ResolverBase.sol";
import "./ICustomDomainResolver.sol";

abstract contract CustomDomainResolver is ICustomDomainResolver, ResolverBase {
    mapping(uint64 => mapping(bytes32 => string)) versionable_domains;
    // string [] public customDomainArr;

    /**
     * Sets the customDomain associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param domain The customDomain to set
     */
    function setCustomDomain(
        bytes32 node,
        string calldata domain
    ) external virtual authorised(node) {
        // bool exist = checkCustomDomainExist(domain);
        // require(!exist,"custom domain existed");
        // customDomainArr.push(domain);
        versionable_domains[recordVersions[node]][node] = domain;
        emit CustomDomainChanged(node, domain);
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

    /**
     * Returns the customDomain associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated customDomain.
     */
    function customdomain(
        bytes32 node
    ) external view virtual override returns (string memory) {
        return versionable_domains[recordVersions[node]][node];
    }

    function supportsInterface(
        bytes4 interfaceID
    ) public view virtual override returns (bool) {
        return
            interfaceID == type(ICustomDomainResolver).interfaceId ||
            super.supportsInterface(interfaceID);
    }
}
