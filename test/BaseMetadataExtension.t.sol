// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC721Rails } from "0xrails/cores/ERC721/ERC721Rails.sol";
import { ERC1155Rails } from "0xrails/cores/ERC1155/ERC1155Rails.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Easel } from "../src/Easel.sol";
import { ERC6551Registry } from "../src/ERC6551Registry.sol";
import { ERC6551Account } from "../src/ERC6551Account.sol";
import { TokenFactory } from "groupos/factory/TokenFactory.sol";
import { BaseMetadataExtension } from "../src/extensions/baseMetadata/BaseMetadataExtension.sol";
import { IBaseMetadataExtension } from "../src/extensions/baseMetadata/IBaseMetadataExtension.sol";
import { EquippableExtension } from "../src/extensions/equippable/EquippableExtension.sol";
import { IEquippableExtension } from "../src/extensions/equippable/IEquippableExtension.sol";
import { RegistryExtension } from "../src/extensions/registry/RegistryExtension.sol";
import { IRegistryExtension } from "../src/extensions/registry/IRegistryExtension.sol";


/// @title BaseMetadataExtensionTest
/// @author frog @0xmcg
/// @notice Tests the 0xRails factory + custom metadata extensions for Noun Citizens.
contract BaseMetadataExtensionTest is Test {
    address public caller = address(1);
    address public fake = address(2);
    ERC6551Registry public registry;
    ERC6551Account public accountImpl;
    Easel public easel;
    BaseMetadataExtension public baseMetadataExtension;
    TokenFactory public tokenFactoryImpl;
    TokenFactory public tokenFactoryProxy;
    ERC721Rails public erc721Rails;
    ERC1155Rails public erc1155Rails;
    EquippableExtension public equippableExtension;
    RegistryExtension public registryExtension;
    address payable erc1155tokenContract;
    address payable erc721tokenContract;
    bytes32 salt = 0x00000000;

    string emptySVG = 'data:application/json;base64,eyJuYW1lIjogIk5QQyAjMCIsICJkZXNjcmlwdGlvbiI6ICJOb3VuIFBsYXlhYmxlIENoYXJhY3RlciIsICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUIzYVdSMGFEMGlNekl3SWlCb1pXbG5hSFE5SWpNeU1DSWdkbWxsZDBKdmVEMGlNQ0F3SURNeU1DQXpNakFpSUhodGJHNXpQU0pvZEhSd09pOHZkM2QzTG5jekxtOXlaeTh5TURBd0wzTjJaeUlnYzJoaGNHVXRjbVZ1WkdWeWFXNW5QU0pqY21semNFVmtaMlZ6SWo0OGNtVmpkQ0IzYVdSMGFEMGlNVEF3SlNJZ2FHVnBaMmgwUFNJeE1EQWxJaUJtYVd4c1BTSWpaRFZrTjJVeElpQXZQand2YzNablBnPT0ifQ==';

    function setUp() public {
      registry = new ERC6551Registry();
      accountImpl = new ERC6551Account();
      easel = new Easel();
      erc721Rails = new ERC721Rails();
      erc1155Rails = new ERC1155Rails();
      equippableExtension = new EquippableExtension();
      registryExtension = new RegistryExtension();
      baseMetadataExtension = new BaseMetadataExtension(address(easel), address(registry));
      tokenFactoryImpl = new TokenFactory();
      tokenFactoryProxy = TokenFactory(address(new ERC1967Proxy(address(tokenFactoryImpl), '')));
      tokenFactoryProxy.initialize(caller, fake, address(erc721Rails), address(erc1155Rails));

      erc1155tokenContract = this.deployTraitContract();
      erc721tokenContract = this.deployCitizenContract();
    }

    function deployCitizenContract() public returns (address payable) {
      vm.startPrank(caller);
      bytes memory addSetupMetadata = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IBaseMetadataExtension.ext_setup.selector, address(baseMetadataExtension));

      bytes memory addTokenURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IBaseMetadataExtension.ext_tokenURI.selector, address(baseMetadataExtension));

      bytes memory addContractURIExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector,
        IBaseMetadataExtension.ext_contractURI.selector,
        address(baseMetadataExtension));

      bytes[] memory initCalls = new bytes[](3);
      initCalls[0] = addSetupMetadata;
      initCalls[1] = addTokenURIExtension;
      initCalls[2] = addContractURIExtension;

      bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

      address payable tokenContract = tokenFactoryProxy.createERC721(
        payable(erc721Rails),
        salt,
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

      address payable tokenContract = tokenFactoryProxy.createERC1155(
        payable(erc1155Rails),
        salt,
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
      IBaseMetadataExtension(erc721tokenContract).ext_setup(address(registry), address(easel), erc1155tokenContract, address(accountImpl), block.chainid, bytes32(0));
      assertEq(ERC721Rails(erc721tokenContract).name(), "Noun Citizens");
      assertEq(ERC721Rails(erc721tokenContract).tokenURI(0), emptySVG);
      // assertEq(ERC721Rails(erc721tokenContract).contractURI(), "TEMP_CONTRACT_URI"); // now returns json
      vm.stopPrank();
    }
}
