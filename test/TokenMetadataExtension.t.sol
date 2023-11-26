// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC721Rails } from "0xrails/cores/ERC721/ERC721Rails.sol";
import { ERC1155Rails } from "0xrails/cores/ERC1155/ERC1155Rails.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import { Easel } from "../src/Easel.sol";
import { ERC6551Registry } from "../src/ERC6551Registry.sol";
import { ERC6551Account } from "../src/ERC6551Account.sol";
import { TokenFactory } from "groupos/factory/TokenFactory.sol";
import { TokenMetadataExtension } from "../src/extensions/tokenMetadata/tokenMetadataExtension.sol";
import { ITokenMetadataExtension } from "../src/extensions/tokenMetadata/ITokenMetadataExtension.sol";
import { EquippableExtension } from "../src/extensions/equippable2/EquippableExtension.sol";
import { IEquippableExtension } from "../src/extensions/equippable2/IEquippableExtension.sol";
import { RegistryExtension } from "../src/extensions/registry/RegistryExtension.sol";
import { IRegistryExtension } from "../src/extensions/registry/IRegistryExtension.sol";


/// @title TokenMetadataExtensionTest
/// @author frog @0xmcg
/// @notice Tests the 0xRails factory + custom metadata extensions for Noun Citizens.
contract TokenMetadataExtensionTest is Test {
    address public caller = address(1);
    ERC6551Registry public registry;
    ERC6551Account public accountImpl;
    Easel public easel;
    TokenMetadataExtension public tokenMetadataExtension;
    TokenFactory public tokenFactory;
    ERC721Rails public erc721Rails;
    ERC1155Rails public erc1155Rails;
    EquippableExtension public equippableExtension;
    RegistryExtension public registryExtension;
    address payable erc1155tokenContract;
    address payable erc721tokenContract;

    string emptySVG = '<svg width="320" height="320" viewBox="0 0 320 320" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges"><rect width="100%" height="100%" fill="#d5d7e1" /></svg>';

    function setUp() public {
      registry = new ERC6551Registry();
      accountImpl = new ERC6551Account();
      easel = new Easel();
      tokenFactory = new TokenFactory();
      erc721Rails = new ERC721Rails();
      erc1155Rails = new ERC1155Rails();
      equippableExtension = new EquippableExtension();
      registryExtension = new RegistryExtension();
      tokenMetadataExtension = new TokenMetadataExtension(address(easel), address(registry));

      erc1155tokenContract = this.deployTraitContract();
      erc721tokenContract = this.deployCitizenContract();
    }

    function deployCitizenContract() public returns (address payable) {
      vm.startPrank(caller);
      bytes memory addSetupMetadata = abi.encodeWithSelector(
        IExtensions.setExtension.selector, ITokenMetadataExtension.ext_setup.selector, address(tokenMetadataExtension));

      bytes memory addTokenURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, ITokenMetadataExtension.ext_tokenURI.selector, address(tokenMetadataExtension));

      bytes memory addContractURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector,
        ITokenMetadataExtension.ext_contractURI.selector,
        address(tokenMetadataExtension));

      bytes[] memory initCalls = new bytes[](3);
      initCalls[0] = addSetupMetadata;
      initCalls[1] = addTokenURIExtension;
      initCalls[2] = addContractURIExtension;

      bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

      address payable tokenContract = tokenFactory.createERC721(
        payable(erc721Rails),
        caller,
        "Noun Citizens",
        "NPC",
        initData
      );
      vm.stopPrank();

      return tokenContract;
    }

    function deployTraitContract() public returns (address payable) {
      vm.startPrank(caller);
      bytes memory addSetupEquippedExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_setupEquipped.selector, address(equippableExtension)
      );

      bytes memory addGetAllExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_getEquippedTokenIds.selector, address(equippableExtension)
      );

      bytes memory addRegisterTraitExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IRegistryExtension.ext_registerTrait.selector, address(registryExtension)
      );

      bytes memory addGetImageDataExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IRegistryExtension.ext_getImageDataForTrait.selector, address(registryExtension)
      );

      bytes[] memory initCalls = new bytes[](4);
      initCalls[0] = addSetupEquippedExtension;
      initCalls[1] = addGetAllExtension;
      initCalls[2] = addRegisterTraitExtension;
      initCalls[3] = addGetImageDataExtension;


      bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

      address payable tokenContract = tokenFactory.createERC1155(
        payable(erc1155Rails),
        caller,
        "NPC Trait",
        "NPCT",
        initData
      );
      vm.stopPrank();

      return tokenContract;
    }

    function test_TokenURIExtension() public {
      vm.startPrank(caller);
      ITokenMetadataExtension(erc721tokenContract).ext_setup(address(registry), address(easel), erc1155tokenContract, address(accountImpl), block.chainid, bytes32(0));
      assertEq(ERC721Rails(erc721tokenContract).name(), "Noun Citizens");
      assertEq(ERC721Rails(erc721tokenContract).tokenURI(0), emptySVG);
      // assertEq(ERC721Rails(erc721tokenContract).contractURI(), "TEMP_CONTRACT_URI"); // now returns json
      vm.stopPrank();
    }
}
