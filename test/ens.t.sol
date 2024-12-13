// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ENSRegistry} from "../contracts/registry/ENSRegistry.sol";
import {BaseRegistrarImplementation} from "../contracts/ethregistrar/BaseRegistrarImplementation.sol";
import {IBaseRegistrar} from "../contracts/ethregistrar/IBaseRegistrar.sol";
import {DummyOracle} from "../contracts/ethregistrar/DummyOracle.sol";
import {AggregatorInterface} from "../contracts/ethregistrar/StablePriceOracle.sol";
import {StablePriceOracle} from "../contracts/ethregistrar/StablePriceOracle.sol";
import {ReverseRegistrar} from "../contracts/reverseRegistrar/ReverseRegistrar.sol";
import {StaticMetadataService} from "../contracts/wrapper/StaticMetadataService.sol";
import {IMetadataService} from "../contracts/wrapper/IMetadataService.sol";
import {NameWrapper} from "../contracts/wrapper/NameWrapper.sol";
import {ETHRegistrarController} from "../contracts/ethregistrar/ETHRegistrarController.sol";
import {PublicResolver} from "../contracts/resolvers/PublicResolver.sol";
import {IPriceOracle} from "../contracts/ethregistrar/IETHRegistrarController.sol";
import {INameWrapper} from "../contracts/wrapper/INameWrapper.sol";
import {Storage} from "../contracts/resolvers/Storage.sol";
import  "../contracts/resolvers/profiles/IStorage.sol";
import  "../contracts/resolvers/profiles/CustomDomain.sol";

contract CounterTest is Test {
    ENSRegistry public ENS;
    BaseRegistrarImplementation public REGISTRAR;
    DummyOracle public DUMMYORACLE;
    StablePriceOracle public PRICEORACLE;
    ReverseRegistrar public REVERSEREGISTRAR;
    StaticMetadataService public STATICMETADATA;
    NameWrapper public NAMEWRAPPER;
    ETHRegistrarController public CONTROLLER;
    PublicResolver public RESOLVER;
    Storage public STORAGE;
    DomainVerification public CUSTOMDOMAIN;
    address public Deployer = address(0x1510);
    bytes32 public baseNode = 0x5d51f7be71608b15a476a7755e3eba23f59b90507c31a9d029cb98afee8536f8;//namehash của mtd
    bytes32 public ZERO_NODE = 0x0000000000000000000000000000000000000000000000000000000000000000;
    bytes32 public REVERSE_LABELHASH = 0xdec08c9dbbdd0890e300eb5062089b2d4b1c40e3673bbccb5423f7b37dcf9a9c;  //keccak của reverse
    bytes32 public REVERSE_NODEHASH = 0xa097f6721ce401e757d1223a763fef49b8b5f90bb18567ddb86fd205dff71d34;
    bytes32 public ADDR_HASH = 0xe5e14487b78f85faa6e1808e89246cf57dd34831548ff2e6097380d98db2504a;
    uint256[] public _rentPrices = [0, 0, 4, 2, 1];
    uint256 public _MINCOMMITMENTAGE = 6;
    uint256 public _MAXCOMMITMENTAGE = 86400;
    uint256 public currentTime = 1706683205;
    bytes32 public MTDHash = 0x1d762f12d73c53a2dfc38a124ae63612f55d0effc2adb139742105e93020fbbf;//keccak256 cua mtd
    // address public buyer = 0x97126B71376F7e55fBA904FdaA9dF0dBd396612f;
        address public buyer = 0xB50b908fFd42d2eDb12b325e75330c1AaAf35dc0;
        // address public buyer = 0xA3A5BACd6eEc01b3C62B3e8b3338C316Be1ca257;

    // address public buyer2 = 0x83CEC343cFc7A6644C1547277d26D7A621FDc40C;
    // address public buyer = 0x9A263aeFC8E2d406A5026aA711193F2dA48D248b;
    // address public resolver = 0x64797E510643C3F468da41674Abbbf024DC816C5;
    address public resolver = 0xdDCC7748046E1b4De4705005718aC03e87870424;
    uint256 duration = 31536000; //365days
    // bytes32 secret = 0x015b73b9315cf8b3da79de5b57c63acd858bade8b6b127bf227365d8af655f9a;
    bytes32 secret = 0x880e9db1cccf0b4257e665acb31c5e3d78d875605137f070cf7e61c9a5283f67;
            // bytes32 nameToAdd = 0x83751ad776d4dde75065572af3ce4cf62a24718b6ad289a8df3c2f3a4aa479bc;// gondar.mtd
        bytes32 nameToAdd = 0x89af762833850ef6b2631e09121bb833e52b04892560a3651082fc274e5d4113;// ooooo.mtd
        // bytes32 nameToAdd = 0x9810c9c0d71c5e1bdb736ca4bf5618962bdb76bb63753e40e96ec301b8e769b6; //'aabc.mtd'
        // bytes32 nameToAdd = 0x04b48f33b391431cb49b33880bfa22e5390636d2207fcfcd5b5d4aa504802932; //'aabc.mtd'
        // bytes32 nameToAdd = 0x04309b834495c9b0137934784171b37257079e572ccb8deeee4cdc964a087d7e; //'aabc.mtd'
        // bytes32 nameToAdd = 0xa82fa4753832f958b7bdf152c354d70df4b8fcf238613dcc97479f196e698a73; //'aabc.mtd'
        // bytes32 nameToAdd = 0x94e8e0d934fb961d72cb103a4baf2a64be1e3825e1d3357c0e5087d579f4b8e3; //'aabc.mtd'
        // bytes32 nameToAdd = 0x573bbf302521b5473b6703a6507f3e71970944d66df0a1654a579afe78cb582f; //'aabc.mtd'
        // bytes32 nameToAdd = 0x095ed220aa9da1a7c6f5cc7e375a2b57247582c6fe8ea434615d12a692be9aa0; //'aabc.mtd'
        //  bytes32 nameToAdd = 0x2328abbddefafec7201372ed5748b11beb07e288bc2b53e43d410df0c6c799c8; //'aabc.mtd'
        //   bytes32 nameToAdd = 0x3854fc090ae804b0102604486c01c2e51613b0e2a99f6d861b907d0c9ac69c7f; //'aabc.mtd'
        //   bytes32 nameToAdd = 0x348ddc6489c960363b8a64b94c34c2ff76af0aeeec9ed988b52577a5ddaf4e3e; //'aabc.mtd'
        //   bytes32 nameToAdd = 0xe9c345836cc099c44dee21dd0b6825890ee039a5bfabf5215cd98ef553ac5f99; //'aabc.mtd'
        //   bytes32 nameToAdd = 0x3ec0347d44289d79b808807eb0fc6270ebba57c20f1d434def86e8af5c0f8e6e; //'aabc.mtd'
        //   bytes32 nameToAdd = 0xfc2067381c0b2ee228453fb56efc9caf6d2925af66d4d62d397c23163b6e0c6b; //'aabc.mtd'
            // bytes32 nameToAdd = 0xac48e1abd33b08fed398400c14d932c736530fa1cc9650ba3a6114ce189bfd05; //'aabc.mtd'
            // bytes32 nameToAdd = 0x0d83a8037bdb8f391dd5b92a463e26854b9250f675381758e3c8f48b57d83336; //'aabc.mtd'
            // bytes32 nameToAdd = 0xcee27eb2b3a43c7688ee001041d158176536143184008b43a37145db2083b345; //'aabc.mtd'
            // bytes32 nameToAdd = 0x4f081404092549275ac3123191cf39af1b8e74291d59261b4743af2abbce35aa; //'aabc.mtd'
            // bytes32 nameToAdd = 0xb1f1da0a3eff035a8c15405a161d8f9b5d07f414bea26eb3ab1c98580ca07544; //'aabc.mtd'
            // bytes32 nameToAdd = 0x095ed220aa9da1a7c6f5cc7e375a2b57247582c6fe8ea434615d12a692be9aa0; //'aabc.mtd'

        // string  nameSet = 'gondar';
        string  nameSet = 'ooooo';
        // string  nameSet = 'aabc';
        //  string nameSet = 'dongwallet6';
        // string memory nameSet = 'thuythanh';
        // string memory nameSet = 'gggg';
        // string memory nameSet = 'pppp';
        // string memory nameSet = 'hhhh';
        // string memory nameSet = 'rrrr';
        // string memory nameSet = '1111';
        // string memory nameSet = '2222';
        // string memory nameSet = '333';
        // string memory nameSet = '4444';
        // string memory nameSet = '5555';
        // string memory nameSet = '6666';
        // string memory nameSet = '7777';
        // string memory nameSet = '8888';
        // string memory nameSet = '9999';
        // string memory nameSet = 'nnnn';
        // string memory nameSet = 'eeee';
        // string memory nameSet = 'ffff';
        // string memory nameSet = 'rrrr';
    event NameRenewed(
            string name,
            bytes32 indexed label,
            uint256 cost,
            uint256 expires,
            address owner 
    );
    constructor(){
        vm.warp(currentTime);
        vm.startPrank(Deployer);
        ENS = new ENSRegistry();
        REGISTRAR = new BaseRegistrarImplementation(ENS,baseNode);
        DUMMYORACLE =  new DummyOracle(3_000_000_000);
        PRICEORACLE = new StablePriceOracle(AggregatorInterface(address(DUMMYORACLE)),_rentPrices);
        REVERSEREGISTRAR = new ReverseRegistrar(ENS);
        ENS.setSubnodeOwner(ZERO_NODE,REVERSE_LABELHASH,Deployer);
        ENS.setSubnodeOwner(REVERSE_NODEHASH,ADDR_HASH,address(REVERSEREGISTRAR));
        STATICMETADATA = new StaticMetadataService("https://ens.domains");
        NAMEWRAPPER = new NameWrapper(ENS,IBaseRegistrar(address(REGISTRAR)),IMetadataService(address(STATICMETADATA)));
        CONTROLLER = new ETHRegistrarController(REGISTRAR,IPriceOracle(address(PRICEORACLE)),60,840,REVERSEREGISTRAR,INameWrapper(address(NAMEWRAPPER)),ENS);
        RESOLVER = new PublicResolver(ENS,INameWrapper(address(NAMEWRAPPER)),address(CONTROLLER),address(REVERSEREGISTRAR));
        REVERSEREGISTRAR.setDefaultResolver(address(RESOLVER));
        ENS.setSubnodeOwner(ZERO_NODE,MTDHash,address(REGISTRAR));
        NAMEWRAPPER.setController(address(CONTROLLER),true);
        REGISTRAR.addController(address(NAMEWRAPPER));
        REVERSEREGISTRAR.setController(address(CONTROLLER),true);
        STORAGE = new Storage();
        STORAGE.setController(address(NAMEWRAPPER));
        NAMEWRAPPER.setStorage(address(STORAGE));
        bytes memory bytesCodeCall = abi.encodeCall(
            NAMEWRAPPER.setController,
            (address(CONTROLLER),true)
        );
        console.log("setController: ");
        console.logBytes(bytesCodeCall);
        console.log(
            "-----------------------------------------------------------------------------"
        );
        NAMEWRAPPER.setReverseRegistrar(address(REVERSEREGISTRAR));
        CUSTOMDOMAIN = new DomainVerification();
        CUSTOMDOMAIN.SetController(Deployer);// address admin cua service 
        CUSTOMDOMAIN.SetDefaultResolver(address(RESOLVER));
        RESOLVER.setService(address(CUSTOMDOMAIN));

        // bytes memory args = abi.encode(0x1510151015101510151015101510151015101510,0x1510151015101510151015101510151015101510,0x1510151015101510151015101510151015101510);
        // bytes memory bytecode = abi.encodePacked(vm.getCode("PublicResolver.sol:PublicResolver"), args); //chay duoc
        // bytes memory bytecode = abi.encodePacked(vm.getCode("ENSRegistry.sol:ENSRegistry:0.8.22"), args);//ko chay duoc

        // bytes memory bytecode = abi.encodePacked(vm.getCode("PublicResolver:0.8.18"), args);
        // console.log("BYTECODE---------------------");
        // console.logBytes(bytecode);
        // bytes memory code = vm.getDeployedCode("ENSRegistry.sol");
        // console.log("---------------------------------DEPLOYED-CODE--------------------------");
        // console.logBytes(code);
        // console.log("------------------------------------------------------------------------");

        vm.stopPrank();
    }

    function testRegister() public {
        //test register ooooo.mtd
        vm.warp(currentTime);
        vm.startPrank(buyer);
        vm.deal(buyer,100 ether);
        bytes[] memory data = new bytes[](2) ;
        bytes memory bytesCodeCall = abi.encodeCall(
            RESOLVER.setAddr,
            (nameToAdd,
            buyer
            )
        );
        data[0] = bytesCodeCall;
        // console.log("setAddr: ");
        // console.logBytes(bytesCodeCall);
        // console.log(
        //     "-----------------------------------------------------------------------------"
        // );
        // bytes32 addToname = 0x877c27542678090e0cb69f572ab2801a061bd39c67f6d633cad6026f3d2a43d3;// 9A263aeFC8E2d406A5026aA711193F2dA48D248b.addr.reverse
        // bytes32 addToname = 0xebdf4e139ac78e481b1f0bf4fb7c619c56b8ef4e8b7689895a5d313d6912ff93;// db4a64a668cB5E9f60CA26eB538dbFC6684B989D.addr.reverse
        bytes32 addToname = 0xd34c8a2314c323c8f5b55f29f4d7e2564c1fd59b5c59c44d343329915e6fc64d;// B50b908fFd42d2eDb12b325e75330c1AaAf35dc0.addr.reverse
        // bytes32 addToname = 0xc7ed75fed262132b91369808612dfd8428ca86af4b5c7f7e12abf3ad941c1a1b;// 83CEC343cFc7A6644C1547277d26D7A621FDc40C.addr.reverse
        // bytes32 addToname = 0xe10228eb8f9ccddc47694ef0ffc21e69dd6866ce5ee3ade06f9051629ca2721a;// a3a5bacd6eec01b3c62b3e8b3338c316be1ca257.addr.reverse

        bytesCodeCall = abi.encodeCall(
            RESOLVER.setText,
            (nameToAdd,
            "email",
            "thuy@yahoo.com.vn"
            )
        );
        data[1] = bytesCodeCall;
        // console.log("setText: ");
        // console.logBytes(bytesCodeCall);
        // console.log(
        //     "-----------------------------------------------------------------------------"
        // );
        bytes32 commitment = CONTROLLER.makeCommitment(
            nameSet,
            buyer,
            duration,
            secret,
            address(RESOLVER),
            data,
            true,
            0
        );
        bytes32 commitment1 = CONTROLLER.makeCommitment(
            nameSet,
            buyer,
            duration,
            secret,
            resolver,
            data,
            true,
            0
        );
        // bytesCodeCall = abi.encodeCall(
        //     CONTROLLER.makeCommitment,
        //     (nameSet,
        //     buyer,
        //     duration,
        //     secret,
        //     resolver,
        //     data,
        //     true,
        //     0)
        // );

        // console.log("makeCommitment: ");
        // console.logBytes(bytesCodeCall);
        // console.log(
        //     "-----------------------------------------------------------------------------"
        // );
        CONTROLLER.commit(commitment);
        bytesCodeCall = abi.encodeCall(
            CONTROLLER.commit,
            commitment1
        );

        console.log("commit: ");
        console.logBytes(bytesCodeCall);
        console.log(
            "-----------------------------------------------------------------------------"
        );

        vm.warp(currentTime+100);

        CONTROLLER.register{value:10**18 wei}(
            nameSet,
            buyer,
            duration,
            secret,
            address(RESOLVER),
            data,
            true,
            0
        );
        vm.stopPrank();
        bytesCodeCall = abi.encodeCall(
            CONTROLLER.register,
             (nameSet,
            buyer,
            duration,
            secret,
            resolver,
            data,
            true,
            0)
        );
        console.log("register: ");
        console.logBytes(bytesCodeCall);
        console.log(
            "-----------------------------------------------------------------------------"
        );
        string memory name = RESOLVER.name(addToname);
        console.log("name:",name);
        bytesCodeCall = abi.encodeCall(
            RESOLVER.name,
            addToname
        );
        console.log("name input: ");
        console.logBytes(bytesCodeCall);
        console.log(
            "-----------------------------------------------------------------------------"
        );   
        // address add = RESOLVER.addr(nameToAdd);
        // console.log("buyer addr:",add);
        // console.log(
        //     "-----------------------------------------------------------------------------"
        // ); 
        // string memory text = RESOLVER.text(nameToAdd,"email");
        // console.log("text:",text);
        // bytesCodeCall = abi.encodeCall(
        //     RESOLVER.text,
        //     (nameToAdd,
        //     "email")
        // );
        // console.log("text input: ");
        // console.logBytes(bytesCodeCall);
        // console.log(
        //     "-----------------------------------------------------------------------------"
        // );   
        // (string memory text1,address payable addr1,bytes memory contenthash1,string memory name1) = RESOLVER.getAll(nameToAdd,"email");
        // console.log("text1: %s, addr1 %v,name1 %s",text1,addr1,name1);
        // bytesCodeCall = abi.encodeCall(
        //     RESOLVER.getAll,
        //     (nameToAdd,
        //     "email")
        // );
        // console.log("getAll input: ");
        // console.logBytes(bytesCodeCall);
        // console.log(
        //     "-----------------------------------------------------------------------------"
        // );  
        // //ENS-setSubnodeOwner namehash-addr.reverse to reverseregistrar
        // address reverseregistrar = 0x1510151015101510151015101510151015101510;
        // bytesCodeCall = abi.encodeCall(
        //     ENS.setSubnodeOwner,
        //     (0xa097f6721ce401e757d1223a763fef49b8b5f90bb18567ddb86fd205dff71d34,
        //     0xe5e14487b78f85faa6e1808e89246cf57dd34831548ff2e6097380d98db2504a,
        //     reverseregistrar)
        // );
        // console.log("setSubnodeOwner: ");
        // console.logBytes(bytesCodeCall);
        // console.log(
        //     "-----------------------------------------------------------------------------"
        // );  
        // bytesCodeCall = abi.encodeCall(
        //     ENS.owner,
        //     nameToAdd
        // );
        // address owner = ENS.owner(nameToAdd);
        // console.log("owner: ",owner);
        // console.log("owner of oooooooo.mtd: ");
        // console.logBytes(bytesCodeCall);
        // console.log("nameWrapper:",address(NAMEWRAPPER));
        // bool kq = ENS.recordExists(nameToAdd);
        // console.log("exist: ",kq);
        // bytesCodeCall = abi.encodeCall(
        //     ENS.recordExists,
        //     nameToAdd
        // );
        // console.log("exist:");
        // console.logBytes(bytesCodeCall);
        // console.log(
        //     "-----------------------------------------------------------------------------"
        // );  
        IPriceOracle.Price memory price = CONTROLLER.rentPrice(nameSet,31536000);
        console.log("price:",price.base);
        // bytesCodeCall = abi.encodeCall(
        //     CONTROLLER.rentPrice,
        //     (nameSet,
        //     31536000
        //     )
        // );
        // console.log("rentPrice:");
        // console.logBytes(bytesCodeCall);
        bytes32 labelhash = keccak256(abi.encodePacked(nameSet));//labelhash(ooooo)
        // console.log("labelhash la:",uint256(keccak256(abi.encodePacked("uuuu"))));
        
        uint256 expiretime = REGISTRAR.nameExpires(uint256(labelhash));
        console.log("expire la:",expiretime);
        bytesCodeCall = abi.encodeCall(
            REGISTRAR.nameExpires,
            // uint256(labelhash)
            uint256(keccak256(abi.encodePacked("uuuu")))
        );
        console.log("expire:");
        console.logBytes(bytesCodeCall);

        // Register2(addToname);
        // GetAll(nameToAdd);
        // RegisterSubnode1(nameToAdd,addToname);
        // RegisterSubnode2(nameToAdd,addToname);
        // SetName(addToname);
        // SetTTL(nameToAdd);
        getStorage(price);
        VerifyCustomDomain();
        // vm.startPrank(buyer);     
        // RESOLVER.setContenthash(nameToAdd,bytes("test"));
        // bytes memory kq = RESOLVER.contenthash(nameToAdd);
        // assertEq(bytes("test"),kq,"should equal");
        // bytesDataCall = abi.encodeCall(
            // RESOLVER.setContenthash,
            // (nameToAdd,
            // bytes("test")
            // )
        // );
        // RESOLVER.setText(nameToAdd,"customdomain","a.com");
        // string memory kq1 = RESOLVER.text(nameToAdd,"customdomain");
        // assertEq(kq1,"a.com","should equal");

        // bool dm2 = RESOLVER.checkCustomDomainExist("b.com");
        // assertEq(dm2,true,"should equal");
        // dm2 = RESOLVER.checkCustomDomainExist("a.com");
        // assertEq(dm2,true,"should equal");

        vm.stopPrank();
    }
    function VerifyCustomDomain()public{
        vm.startPrank(buyer);
        string memory domain = "34.93.102.218:8888";
        uint256 code = CUSTOMDOMAIN.registerDomain(domain,nameSet);
        assert(code>0);
        bytes memory bytesCodeCall = abi.encodeCall(
            CUSTOMDOMAIN.registerDomain,
            (domain,
            nameSet
            )
        );
        console.log("registerDomain:");
        console.logBytes(bytesCodeCall);
        uint256 codeCheck = CUSTOMDOMAIN.getVerificationCode(nameSet);
        assertEq(code,codeCheck,"should be equal");
        vm.stopPrank();
        vm.startPrank(Deployer);
        codeCheck = CUSTOMDOMAIN.getVerificationCode(nameSet);
        assert(codeCheck == 0);
        CUSTOMDOMAIN.verifyDomain(domain,code,buyer,nameSet);
        vm.stopPrank();
        bool kq = CUSTOMDOMAIN.isDomainVerified(buyer,nameSet);
        assertEq(kq,true,"should be true");
        kq = CUSTOMDOMAIN.isDomainVerified(Deployer,nameSet);
        assertEq(kq,false,"should be false");
        string memory customdomain = RESOLVER.customdomain(nameToAdd);
        assertEq(customdomain,domain,"should be same");
        bytesCodeCall = abi.encodeCall(
            RESOLVER.customdomain,0x1e86319de67c21319e99d924a3a0cfb09229c8bb9ddee6d7554c35beca1c6bce);
        console.log("customdomain:");
        console.logBytes(bytesCodeCall);
        PublicResolver.GetInfo memory getinfo = RESOLVER.getAll(nameToAdd);
        assertEq(getinfo.customdomain,domain,"should be same");
        bytesCodeCall = abi.encodeCall(
            RESOLVER.getAll,0x31525088f39ddcdc5dfba8c6d464f3f570ff6c319724461e3b19f78e8fe47327);
        console.log("getAll:");
        console.logBytes(bytesCodeCall);
        PublicResolver.GetInfo memory infoFromDomain = CUSTOMDOMAIN.getDomainInfo(domain);
        bytesCodeCall = abi.encodeCall(
            CUSTOMDOMAIN.getDomainInfo,"mygvq.org");
        console.log("getDomainInfo:");
        console.logBytes(bytesCodeCall);

        assertEq(infoFromDomain.customdomain,domain,"should equal");
        assertEq(infoFromDomain.email,"thuy@yahoo.com.vn","should be equal");
        //update fee
        address sc = CUSTOMDOMAIN.createSc(domain);
        console.log("sc:",sc);
        PublicResolver.GetInfo memory info = InfoCustomDomain(sc).getInfoDomain();
        console.log("info.customdomain:",info.customdomain);
        console.log("info.email:",info.email);
    }
    function getStorage(IPriceOracle.Price memory price)public{
        //test setInfo
        address newBuyer = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        NameInfo[] memory names = STORAGE.getNames(newBuyer,currentTime);
        assertEq(0,names.length,"should equal");

        names = STORAGE.getNames(buyer,currentTime);
        assertEq(1,names.length,"should equal");
        assertEq(string.concat(nameSet,".mtd"),names[0].label,"should equal");
        console.log(
            "-----------------------------------------------------------------------------"
        );  
        bytes memory bytesCodeCall = abi.encodeCall(
            STORAGE.getNames,
            (buyer,
            block.timestamp
            )
        );
        console.log("getNames:");
        console.logBytes(bytesCodeCall);
        uint256 expire = currentTime+100+duration;
        assertEq(expire,names[0].expire);
        uint256 tokenid = names[0].tokenid;
        //test updateOwner

        vm.startPrank(buyer);
        NAMEWRAPPER.approve(newBuyer,uint256(names[0].tokenid));
        NAMEWRAPPER.safeTransferFrom(
            buyer,
            newBuyer,
            uint256(names[0].tokenid),
            1,
            bytes("")
        );
        names = STORAGE.getNames(buyer,currentTime);
        assertEq(0,names.length,"should equal");
        names = STORAGE.getNames(newBuyer,currentTime);
        assertEq(1,names.length,"should equal");
        console.log("name la:",names[0].label);
        assertEq(string.concat(nameSet,".mtd"),names[0].label,"should equal");
        assertEq(expire,names[0].expire, "expire should equal");
        assertEq(tokenid,names[0].tokenid);
        //test  updateExpire
        vm.startPrank(Deployer);
        vm.deal(Deployer,100 ether);
        vm.expectEmit(true, true, true, true);
        emit NameRenewed(nameSet,keccak256(bytes(nameSet)),10**18,expire+100,newBuyer);
        CONTROLLER.renew{value:10**18 wei}(nameSet,100);
        names = STORAGE.getNames(newBuyer,currentTime);
        assertEq(expire+100,names[0].expire,"expire renew should equal");
        vm.stopPrank();
        console.log(
            "-----------------------------------------------------------------------------"
        );  
        bytesCodeCall = abi.encodeCall(
            CONTROLLER.renew,
            (nameSet,
            31536000
            )
        );
        console.log("renew:");
        console.logBytes(bytesCodeCall);
    }
    function SetTTL(bytes32 nameToAdd)public{
        vm.startPrank(buyer);
        NAMEWRAPPER.setTTL(nameToAdd,5);
        uint64 ttl = ENS.ttl(nameToAdd);
        console.log("ttl:",ttl);
        vm.stopPrank();
    }
    function SetName(bytes32 addToname) public {
        vm.startPrank(buyer);
        string memory newName = "newName.mtd";
        RESOLVER.setName(addToname, newName);
        string memory name = RESOLVER.name(addToname);
        console.log(" new name:",name);
        vm.stopPrank();
    }
    function Register2(bytes32 addToname) public {
        bytes32 nameToAdd = 0x9810c9c0d71c5e1bdb736ca4bf5618962bdb76bb63753e40e96ec301b8e769b6; //'aabc.mtd'
        vm.startPrank(buyer);
        string memory nameSet = 'aabc';
        bytes[] memory data = new bytes[](1) ;
        bytes memory bytesCodeCall = abi.encodeCall(
            RESOLVER.setAddr,
            (nameToAdd,
            buyer
            )
        );
        data[0] = bytesCodeCall;
        bytes32 commitment = CONTROLLER.makeCommitment(
            nameSet,
            buyer,
            duration,
            secret,
            address(RESOLVER),
            data,
            true,
            0
        );
        CONTROLLER.commit(commitment);
        vm.warp(currentTime+200);
        CONTROLLER.register{value:10**18 wei}(
            nameSet,
            buyer,
            duration,
            secret,
            address(RESOLVER),
            data,
            true,
            0
        );
        string[] memory namesArr = RESOLVER.getNames(addToname);
        console.log("name length:",namesArr.length);
        console.log("name 1:,",namesArr[0]);
        console.log("name 2:,",namesArr[1]);
        console.log(
            "-----------------------------------------------------------------------------"
        );  
        // RESOLVER.setText(nameToAdd,"customdomain","b.com");
        // string memory kq1 = RESOLVER.text(nameToAdd,"customdomain");
        // assertEq(kq1,"b.com","should equal");
        vm.stopPrank();

    }
    function RegisterSubnode1(bytes32 parentNode,bytes32 addToname) public {
        vm.startPrank(buyer);
        string memory label="test";
        address owner=buyer;
        uint64 ttl=0;
        uint32 fuses=0;
        uint64 expiry=uint64(currentTime + 200 + duration);// expiry max = parent node expiry =currentTime + 100 + duration
        NAMEWRAPPER.setSubnodeRecord(
            parentNode,
            label,
            owner,
            address(RESOLVER),
            ttl,
            fuses,
            expiry
        );
        vm.stopPrank();
        string[] memory namesArr = RESOLVER.getSubNames(addToname);
        console.log("subname length lan1:",namesArr.length);
        console.log("name 1:,",namesArr[0]);
        console.log(
            "-----------------------------------------------------------------------------"
        );  
         bytes memory bytesCodeCall = abi.encodeCall(
            NAMEWRAPPER.setSubnodeRecord,
             (parentNode,
            label,
            owner,
            resolver,
            ttl,
            fuses,
            expiry)
        );
        console.log("setSubnodeRecord input: ");
        console.logBytes(bytesCodeCall);
        console.log(
            "-----------------------------------------------------------------------------"
        ); 
        getStorageSubnode1(buyer);
    }
    function getStorageSubnode1(address buyer)public{
        //test setInfo
        address newBuyer = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        NameInfo[] memory names1 = STORAGE.getNames(newBuyer,currentTime);
        assertEq(0,names1.length,"should equal");

        NameInfo[] memory names = STORAGE.getNames(buyer,currentTime);
        assertEq(2,names.length,"should equal");
        assertEq("dongwallet6.mtd",names[0].label,"should equal");
        assertEq("test.dongwallet6.mtd",names[1].label,"should equal");

        uint256 expire = currentTime+100+duration; // expiry max = parent node expiry =currentTime + 100 + duration
        assertEq(expire,names[0].expire);
        uint256 tokenid = names[1].tokenid;
        //test updateOwner

        vm.startPrank(buyer);
        NAMEWRAPPER.approve(newBuyer,uint256(names[1].tokenid));
        NAMEWRAPPER.safeTransferFrom(
            buyer,
            newBuyer,
            uint256(names[1].tokenid),
            1,
            bytes("")
        );
        names = STORAGE.getNames(buyer,currentTime);
        assertEq(1,names.length,"should equal");
        assertEq("dongwallet6.mtd",names[0].label,"should equal");
        names = STORAGE.getNames(newBuyer,currentTime);
        assertEq(1,names.length,"should equal");
        assertEq("test.dongwallet6.mtd",names[0].label,"should equal");
        assertEq(tokenid,names[0].tokenid);
        // //test  updateExpire
        CONTROLLER.renew{value:10**18 wei}("dongwallet6",100);
        names = STORAGE.getNames(newBuyer,currentTime);
        assertEq(expire+100,names[0].expire,"expire renew should equal");
        vm.stopPrank();
    }

    function RegisterSubnode2(bytes32 parentNode,bytes32 addToname) public {
        vm.startPrank(buyer);
        string memory label="mmm";
        address owner=buyer;
        address resolver=address(RESOLVER);
        uint64 ttl=0;
        uint32 fuses=0;
        uint64 expiry=1111111;
        NAMEWRAPPER.setSubnodeRecord(
            parentNode,
            label,
            owner,
            resolver,
            ttl,
            fuses,
            expiry
        );
        vm.stopPrank();
        string[] memory namesArr = RESOLVER.getSubNames(addToname);
        console.log("subname length lan 2:",namesArr.length);
        console.log("name 1:,",namesArr[0]);
        console.log("name 2:,",namesArr[1]);
        console.log(
            "-----------------------------------------------------------------------------"
        );  
        string[] memory allnamesArr = RESOLVER.getAllNames(addToname);
        console.log("all names :",allnamesArr.length);
        console.log("name 1:,",allnamesArr[0]);
        console.log("name 2:,",allnamesArr[1]);
        console.log("name 3:,",allnamesArr[2]);
        console.log("name 4:,",allnamesArr[3]);

    }

    function GetAll (bytes32 nameToAdd)public {
        RESOLVER.getAll(nameToAdd);
        // console.log("email:,",email);
        // console.log("addr1:",addr2);

        bytes memory bytesCodeCall = abi.encodeCall(
            RESOLVER.getAll,nameToAdd
        );
        console.log("getAll input: ");
        console.logBytes(bytesCodeCall);
        console.log(
            "-----------------------------------------------------------------------------"
        ); 

    }

}
