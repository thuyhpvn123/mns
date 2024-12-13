//SPDX-License-Identifier: MIT
pragma solidity >=0.8.17 <0.9.0;

import "../registry/ENS.sol";
import "./profiles/ABIResolver.sol";
import "./profiles/AddrResolver.sol";
import "./profiles/ContentHashResolver.sol";
import "./profiles/DNSResolver.sol";
import "./profiles/InterfaceResolver.sol";
import "./profiles/NameResolver.sol";
import "./profiles/PubkeyResolver.sol";
import "./profiles/TextResolver.sol";
import "./profiles/CustomDomainResolver.sol";
import "./Multicallable.sol";
import {ReverseClaimer} from "../reverseRegistrar/ReverseClaimer.sol";
import {INameWrapper} from "../wrapper/INameWrapper.sol";

/**
 * A simple resolver anyone can use; only allows the owner of a node to set its
 * address.
 */
contract PublicResolver is
    Multicallable,
    ABIResolver,
    AddrResolver,
    ContentHashResolver,
    DNSResolver,
    InterfaceResolver,
    NameResolver,
    PubkeyResolver,
    TextResolver,
    ReverseClaimer,
    CustomDomainResolver
{
    ENS immutable ens;
    INameWrapper immutable nameWrapper;
    address immutable trustedETHController;
    address immutable trustedReverseRegistrar;
    address public trustedNameWrapper;
    /**
     * A mapping of operators. An address that is authorised for an address
     * may make any changes to the name that the owner could, but may not update
     * the set of authorisations.
     * (owner, operator) => approved
     */
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * A mapping of delegates. A delegate that is authorised by an owner
     * for a name may make changes to the name's resolver, but may not update
     * the set of token approvals.
     * (owner, name, delegate) => approved
     */
    mapping(address => mapping(bytes32 => mapping(address => bool)))
        private _tokenApprovals;
    address public service;
    address public owner;
    // Logged when an operator is added or removed.
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    // Logged when a delegate is approved or  an approval is revoked.
    event Approved(
        address owner,
        bytes32 indexed node,
        address indexed delegate,
        bool indexed approved
    );
    struct GetInfo {
        address  addr;
        string  avatar;
        string  email;
        string  telegram;
        string  twitter;
        string  discord;
        string  description;
        string  github;
        string  customdomain;
        string  name;
        string  youtube;
        bytes  contenthash;
        string url;
        string ggdrive;
    } 
    constructor(
        ENS _ens,
        INameWrapper wrapperAddress,
        address _trustedETHController,
        address _trustedReverseRegistrar
    ) ReverseClaimer(_ens, msg.sender) payable {
        ens = _ens;
        nameWrapper = wrapperAddress;
        trustedETHController = _trustedETHController;
        trustedReverseRegistrar = _trustedReverseRegistrar;
        owner = msg.sender;
    }
    modifier onlyOwner(){
       require(msg.sender == owner,"not owner");
       _;
    }
    modifier onlyService(){
       require(msg.sender == service,"not service");
       _;
    }
    function setService(address _service) external onlyOwner{
        service = _service;
    }
    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) external {
        require(
            msg.sender != operator,
            "ERC1155: setting approval status for self"
        );

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(
        address account,
        address operator
    ) public view returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev Approve a delegate to be able to updated records on a node.
     */
    function approve(bytes32 node, address delegate, bool approved) external {
        require(msg.sender != delegate, "Setting delegate status for self");

        _tokenApprovals[msg.sender][node][delegate] = approved;
        emit Approved(msg.sender, node, delegate, approved);
    }

    /**
     * @dev Check to see if the delegate has been approved by the owner for the node.
     */
    function isApprovedFor(
        address owner,
        bytes32 node,
        address delegate
    ) public view returns (bool) {
        return _tokenApprovals[owner][node][delegate];
    }

    function isAuthorised(bytes32 node) internal view override returns (bool) {
        
        if (
            msg.sender == trustedETHController ||
            msg.sender == trustedReverseRegistrar ||
            msg.sender == address(nameWrapper)||
            msg.sender == service
        ) {
            return true;
        }
        address owner = ens.owner(node);
        if (owner == address(nameWrapper)) {
            owner = nameWrapper.ownerOf(uint256(node));
        }
        return
            owner == msg.sender ||
            isApprovedForAll(owner, msg.sender) ||
            isApprovedFor(owner, node, msg.sender);
    }
    function getAll(
        bytes32 node
    ) external view returns(
        GetInfo memory getinfo
    ){       
        getinfo.addr = this.addr(node);
        getinfo.avatar = this.text(node,"avatar");
        getinfo.email = this.text(node,"email");
        getinfo.telegram = this.text(node,"org.telegram");
        getinfo.twitter = this.text(node,"com.twitter");
        getinfo.discord = this.text(node,"com.discord");
        getinfo.description = this.text(node,"description");
        getinfo.github = this.text(node,"com.github");
        getinfo.customdomain = this.customdomain(node);
        // getinfo.customdomain = this.text(node,"customdomain");
        getinfo.name = this.text(node,"name");
        getinfo.youtube = this.text(node,"com.youtube");
        getinfo.contenthash = this.contenthash(node);
        getinfo.url = this.text(node,"url");
        getinfo.ggdrive = this.text(node,"ggdrive");
        return(getinfo);
    }
    function supportsInterface(
        bytes4 interfaceID
    )
        public
        view
        override(
            Multicallable,
            ABIResolver,
            AddrResolver,
            ContentHashResolver,
            DNSResolver,
            InterfaceResolver,
            NameResolver,
            PubkeyResolver,
            TextResolver,
            CustomDomainResolver
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceID);
    }
}
