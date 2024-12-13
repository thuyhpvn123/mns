// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "../ResolverBase.sol";
import "./INameResolver.sol";
// import "forge-std/console.sol";
abstract contract NameResolver is INameResolver, ResolverBase {
    mapping(uint64 => mapping(bytes32 => string)) versionable_names;
    mapping(uint64 => mapping(bytes32 => string[]))versionable_namesArr;

    mapping(uint64 => mapping(bytes32 => string[]))versionable_subnamesArr;
    /**
     * Sets the name associated with an ENS node, for reverse records.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     */
    function setName(
        bytes32 node,
        string calldata newName
    ) external virtual authorised(node) {
        versionable_names[recordVersions[node]][node] = newName;
        emit NameChanged(node, newName);
    }
    function setNameArr(
        bytes32 node,
        string calldata newName
    ) external virtual authorised(node) {
        versionable_namesArr[recordVersions[node]][node].push(newName);
    }
    function dropName(
        bytes32 node,  //address.addr.reverse
        string calldata _name //fullname: thuy.mtd
    )external authorised(node) {
        string[] storage arrName = versionable_namesArr[recordVersions[node]][node];
        for(uint256 i=0; i < arrName.length; i++) {
            if(keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked(arrName[i]))){
                _removeElementByPop(arrName,i);
            }
            break;
        }
        string[] storage arrSubName = versionable_subnamesArr[recordVersions[node]][node];
        for(uint256 i=0; i < arrName.length; i++) {
            if(keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked(arrSubName[i]))){
                _removeElementByPop(arrSubName,i);
            }
            break;
        }
    }
     function _removeElementByPop(string[] storage list, uint index) internal returns(bool) {
        require(index < list.length,'index is over list number'); // Invalid Index

        // Swap current element at index to last element of list
        list[index] = list[list.length - 1];

        // Pop last element
        list.pop();
        return true;
    }
    function setSubNameArr(
        bytes32 node,
        string calldata newSubName
    ) external virtual authorised(node) {
        versionable_subnamesArr[recordVersions[node]][node].push(newSubName);
    }
    function getSubNames(bytes32 node) view public returns(string[] memory subnamesArr) {
        subnamesArr = versionable_subnamesArr[recordVersions[node]][node];
        return subnamesArr;
    }

    function getNames(bytes32 node) view public returns(string[] memory namesArr) {
        namesArr = versionable_namesArr[recordVersions[node]][node];
        return namesArr;
    }   
    function getAllNames(bytes32 node)view public returns(string[] memory namesArr) {
        string[] memory namesArr = versionable_namesArr[recordVersions[node]][node];
        string[] memory subnamesArr = versionable_subnamesArr[recordVersions[node]][node];
        uint totalLength = namesArr.length + subnamesArr.length;
        string[] memory mergedArray = new string[](totalLength);
        for (uint i = 0; i < namesArr.length; i++) {
            mergedArray[i] = namesArr[i];
        }
        for (uint j = 0; j < subnamesArr.length; j++) {
            mergedArray[namesArr.length + j] = subnamesArr[j];
        }
        return mergedArray;
    }
     /**
     * Returns the name associated with an ENS node, for reverse records.
     * Defined in EIP181.
     * @param node The ENS node to query.
     * @return The associated name.
     */
    function name(
        bytes32 node
    ) external view virtual override returns (string memory) {
        return versionable_names[recordVersions[node]][node];
    }

    function supportsInterface(
        bytes4 interfaceID
    ) public view virtual override returns (bool) {
        return
            interfaceID == type(INameResolver).interfaceId ||
            super.supportsInterface(interfaceID);
    }
}
