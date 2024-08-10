// SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import { Test, console2 } from "forge-std/Test.sol";
// import { ERC721Rails } from "0xrails/cores/ERC721/ERC721Rails.sol";
// import { ERC1155Rails } from "0xrails/cores/ERC1155/ERC1155Rails.sol";
// import { IERC1155Rails } from "0xrails/cores/ERC1155/interface/IERC1155Rails.sol";
// import { IExtensions } from "0xrails/extension/interface/IExtensions.sol";
// import { Multicall } from "openzeppelin-contracts/utils/Multicall.sol";
// import { Easel } from "../src/Easel.sol";
// import { ERC6551Registry } from "../src/ERC6551Registry.sol";
// import { ERC6551Account } from "../src/ERC6551Account.sol";
// import { TokenFactory } from "groupos/factory/TokenFactory.sol";
// import { BaseMetadataExtension } from "../src/extensions/baseMetadata/BaseMetadataExtension.sol";
// import { IBaseMetadataExtension } from "../src/extensions/baseMetadata/IBaseMetadataExtension.sol";
// import { TraitMetadataExtension } from "../src/extensions/traitMetadata/TraitMetadataExtension.sol";
// import { ITraitMetadataExtension } from "../src/extensions/traitMetadata/ITraitMetadataExtension.sol";
// import { EquippableExtension } from "../src/extensions/equippable/EquippableExtension.sol";
// import { IEquippableExtension } from "../src/extensions/equippable/IEquippableExtension.sol";
// import { RegistryExtension } from "../src/extensions/registry/RegistryExtension.sol";
// import { IRegistryExtension } from "../src/extensions/registry/IRegistryExtension.sol";
// import { InitializerMintController } from "../src/modules/InitializerMintController.sol";
// import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
// import { IEasel } from "../src/interfaces/IEasel.sol";

// /// @title InitializerMintControllerTest
// /// @author frog @0xmcg
// /// @notice Tests the InitializerMintController
// /// forge t --mc InitializerMintControllerTest -vvv
// contract InitializerMintControllerTest is Test {
//     address public caller = address(1);
//     address public fake = address(2);
//     ERC6551Registry public registry;
//     ERC6551Account public accountImpl;
//     Easel public easel;
//     BaseMetadataExtension public baseMetadataExtension;
//     TokenFactory public tokenFactoryImpl;
//     TokenFactory public tokenFactoryProxy;
//     ERC721Rails public erc721Rails;
//     EquippableExtension public equippableExtension;
//     RegistryExtension public registryExtension;
//     InitializerMintController public initializerMintController;
//     address payable erc721tokenContract;
//     bytes32 salt = 0x00000000;
//     string public file;
//     uint8 paletteIndex = 0;

//     struct Trait {
//       bytes rleBytes;
//       string filename;
//     }


//     function setUp() public {
//       registry = new ERC6551Registry();
//       accountImpl = new ERC6551Account();
//       easel = new Easel();
//       erc721Rails = new ERC721Rails();
//       equippableExtension = new EquippableExtension();
//       registryExtension = new RegistryExtension();
//       baseMetadataExtension = new BaseMetadataExtension(address(easel), address(registry));

//       tokenFactoryImpl = new TokenFactory();
//       tokenFactoryProxy = TokenFactory(address(new ERC1967Proxy(address(tokenFactoryImpl), '')));
//       tokenFactoryProxy.initialize(caller, fake, address(erc721Rails), address(erc1155Rails));
//       erc721tokenContract = this.deployCitizenContract();

//       IBaseMetadataExtension(erc721tokenContract).ext_setup(
//         address(registry),
//         address(easel),
//         erc1155tokenContract,
//         address(accountImpl),
//         block.chainid,
//         bytes32(0)
//       );
//     }

//     function deployCitizenContract() public returns (address payable) {
//       vm.startPrank(caller);
//       bytes memory addSetupMetadata = abi.encodeWithSelector(
//         IExtensions.setExtension.selector, IBaseMetadataExtension.ext_setup.selector, address(baseMetadataExtension));

//       bytes memory addTokenURIExtension = abi.encodeWithSelector(
//         IExtensions.setExtension.selector, IBaseMetadataExtension.ext_tokenURI.selector, address(baseMetadataExtension));

//       bytes memory addContractURIExtension = abi.encodeWithSelector(
//         IExtensions.setExtension.selector,
//         IBaseMetadataExtension.ext_contractURI.selector,
//         address(baseMetadataExtension));

//       bytes[] memory initCalls = new bytes[](3);
//       initCalls[0] = addSetupMetadata;
//       initCalls[1] = addTokenURIExtension;
//       initCalls[2] = addContractURIExtension;

//       bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

//       address payable tokenContract = tokenFactoryProxy.createERC721(
//         payable(erc721Rails),
//         salt,
//         caller,
//         "Noun Citizens",
//         "NPC",
//         initData
//       );
//       vm.stopPrank();

//       return tokenContract;
//     }

//     function test_Complete() public {
//       vm.startPrank(caller);
//       uint256 tokenId = 0;
//       address tbaAddress = registry.account(address(accountImpl), bytes32(0), block.chainid, address(erc721tokenContract), tokenId);
//       IERC1155Rails(address(erc1155tokenContract)).mintTo(tbaAddress, 1, 1);

//       IEquippableExtension(address(erc1155tokenContract)).ext_addTokenId(tbaAddress, 1, 0);
//       assertEq(ERC721Rails(erc721tokenContract).name(), "Noun Citizens");
//       assertEq(ERC721Rails(erc721tokenContract).tokenURI(tokenId), headGlassesSVG);
//       // assertEq(ERC721Rails(erc721tokenContract).contractURI(), "TEMP_CONTRACT_URI");

//       // 1155 NFT rendering
//       assertEq(ERC1155Rails(erc1155tokenContract).uri(1), glassesSVG);
//       vm.stopPrank();
//     }
// }
