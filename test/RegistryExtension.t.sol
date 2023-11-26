// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { TokenFactory } from "groupos/factory/TokenFactory.sol";
import { ERC1155Rails } from "0xrails/cores/ERC1155/ERC1155Rails.sol";
import { RegistryExtension } from "../src/extensions/registry/RegistryExtension.sol";
import { IRegistryExtension } from "../src/extensions/registry/IRegistryExtension.sol";
import { Multicall } from "openzeppelin-contracts/utils/Multicall.sol";
import { IExtensions } from "0xrails/extension/interface/IExtensions.sol";


/// @title RegistryExtensionTest
/// @author frog @0xmcg
/// @notice Tests for TraitRegistry contract.
contract RegistryExtensionTest is Test {
    TokenFactory public tokenFactory = new TokenFactory();
    ERC1155Rails public erc1155Rails = new ERC1155Rails();
    RegistryExtension public registryExtension = new RegistryExtension();
    address payable token;
    address public caller = address(1);


    function setUp() public {
      vm.startPrank(caller);
      bytes memory addRegisterTraitExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IRegistryExtension.ext_registerTrait.selector, address(registryExtension)
      );

      bytes memory addGetImageDataExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IRegistryExtension.ext_getImageDataForTrait.selector, address(registryExtension)
      );

      bytes[] memory initCalls = new bytes[](2);
      initCalls[0] = addRegisterTraitExtension;
      initCalls[1] = addGetImageDataExtension;

      bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);
      token = tokenFactory.createERC1155(payable(erc1155Rails), caller, "NPC Trait", "NPCT", initData);
      vm.stopPrank();
    }

    function test_ext_registerTraitAndGetData() public {
      vm.startPrank(caller);
      bytes memory rleBytes = abi.encodePacked(uint8(1), uint8(2), uint8(3));
      IRegistryExtension(token).ext_registerTrait(rleBytes, "name");

      assertEq(IRegistryExtension(token).ext_getImageDataForTrait(1), rleBytes);
      vm.stopPrank();
    }


}
