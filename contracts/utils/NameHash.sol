// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library NamehashLibrary {
    function namehash(string memory _label) internal pure returns (bytes32) {
        // Append "mtd" to the input label
        string memory fullName = string(abi.encodePacked(_label, ".mtd"));
        
        bytes32 node = 0x0;
        
        if (bytes(fullName).length == 0) {
            return node;
        }

        string[] memory labels = split(fullName, '.');

        for (uint i = labels.length; i > 0; i--) {
            node = keccak256(abi.encodePacked(node, keccak256(abi.encodePacked(labels[i - 1]))));
        }

        return node;
    }

    function split(string memory _base, string memory _value) internal pure returns (string[] memory) {
        bytes memory _baseBytes = bytes(_base);
        uint256 count = 1;
        for (uint256 i = 0; i < _baseBytes.length; i++) {
            if (_baseBytes[i] == bytes(_value)[0]) {
                count++;
            }
        }

        string[] memory splitArr = new string[](count);
        uint256 j = 0;
        uint256 lastIndex = 0;

        for (uint256 i = 0; i < _baseBytes.length; i++) {
            if (_baseBytes[i] == bytes(_value)[0]) {
                splitArr[j] = substring(_base, lastIndex, i);
                j++;
                lastIndex = i + 1;
            }
        }

        splitArr[j] = substring(_base, lastIndex, _baseBytes.length);
        return splitArr;
    }

    function substring(string memory str, uint256 startIndex, uint256 endIndex) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }
}