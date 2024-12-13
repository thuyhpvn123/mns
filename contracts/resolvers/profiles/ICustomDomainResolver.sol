// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface ICustomDomainResolver {
    event CustomDomainChanged(bytes32 indexed node, string domain);

    /**
     * Returns the customDomain associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated customDomain.
     */
    function customdomain(bytes32 node) external view returns (string memory);
}
