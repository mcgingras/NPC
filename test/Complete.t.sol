// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Multicall} from "../lib/openzeppelin-contracts/contracts/utils/Multicall.sol";
import { TokenFactory } from "groupos/factory/TokenFactory.sol";
import { ERC721Rails } from "0xrails/cores/ERC721/ERC721Rails.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";
import { ERC6551Registry } from "../src/ERC6551Registry.sol";
import { ERC6551Account } from "../src/ERC6551Account.sol";
import { Easel } from "../src/Easel.sol";
import { Equippable } from "../src/extensions/equippable/Equippable.sol";
import { EquippableExtension } from "../src/extensions/equippable/EquippableExtension.sol";
import { IEquippableExtension } from "../src/extensions/equippable/IEquippableExtension.sol";
import { TokenMetadataExtension } from "../src/extensions/metadata/TokenMetadataExtension.sol";
import { ITokenMetadataExtension } from "../src/extensions/metadata/ITokenMetadataExtension.sol";

/// @title CompleteTest
/// @author frog @0xmcg
/// @notice This is an "end-to-end" test of the whole system working together.
/// -------------------------------------------------------------------------
/// Tests for:
/// - Mint new NPCs
/// - Create a TBA
/// - Mint new traits (with a variety of different mint controllers (modules))
/// - Render SVG (tokenURI)
/// - Equip / unequip traits
/// - Transfer (guard)
contract CompleteTest is Test {
    ERC6551Registry public registry = new ERC6551Registry();
    ERC6551Account public simpleAccountImplementation= new ERC6551Account();
    Easel public easel = new Easel();
    Equippable public equippable = new Equippable();
    EquippableExtension public equippableExtension = new EquippableExtension(address(equippable));
    TokenMetadataExtension public tokenMetadataExtension = new TokenMetadataExtension(address(easel), address(registry));
    TokenFactory public tokenFactory = new TokenFactory();
    ERC721Rails public erc721Rails = new ERC721Rails();
    address public caller = address(1);
    address public receiver = address(2);
    bytes32 public salt = bytes32(0);

    function setUp() public {
      vm.startPrank(caller);
      address payable citizenContract = this.createCitizenContract();
      vm.stopPrank();
    }

    function createCitizenContract() public returns (address payable) {
      vm.startPrank(caller);

      bytes memory addSetupEquippedExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_setupEquipped.selector, address(equippableExtension)
      );

      bytes memory addGetAllExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_getEquippedTokenIds.selector, address(equippableExtension)
      );

      bytes memory addTokenURIMetadataExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, ITokenMetadataExtension.ext_tokenURI.selector, address(tokenMetadataExtension)
      );

      bytes[] memory initCalls = new bytes[](3);
      initCalls[0] = addSetupEquippedExtension;
      initCalls[1] = addGetAllExtension;
      initCalls[2] = addTokenURIMetadataExtension;

      bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

      address payable token = tokenFactory.createERC721(
        payable(erc721Rails),
        caller,
        "Noun Citizens",
        "NPC",
        initData
      );

      return token;

      vm.stopPrank();
    }
}
