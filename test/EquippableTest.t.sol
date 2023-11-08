// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC721Rails } from "0xrails/cores/ERC721/ERC721Rails.sol";
import {IExtensions} from "0xrails/extension/interface/IExtensions.sol";
import {Multicall} from "openzeppelin-contracts/utils/Multicall.sol";
import { TokenFactory } from "groupos/factory/TokenFactory.sol";
import { TokenMetadataExtension } from "../src/extensions/tokenMetadataExtension.sol";
import { ITokenMetadataExtension } from "../src/extensions/ITokenMetadataExtension.sol";
import { EquippableExtension } from "../src/extensions/EquippableExtension.sol";
import { IEquippableExtension } from "../src/extensions/IEquippableExtension.sol";
import { Equippable } from "../src/extensions/Equippable.sol";


/// @title EquippableExtensionTest
/// @author frog @0xmcg
/// @notice Tests behavior of the equippable extension
contract EquippableExtensionTest is Test {
    address public caller = address(1);
    Equippable equippable = new Equippable();
    EquippableExtension public equippableExtension = new EquippableExtension(address(equippable));
    TokenFactory public tokenFactory = new TokenFactory();
    ERC721Rails public erc721Rails = new ERC721Rails();
    address payable token;

    function setUp() public {
      bytes memory addSetupEquippedExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_setupEquipped.selector, address(equippableExtension)
      );

      bytes memory addGetAllExtension = abi.encodeWithSelector(
        IExtensions.setExtension.selector, IEquippableExtension.ext_getEquippedTokenIds.selector, address(equippableExtension)
      );

      bytes[] memory initCalls = new bytes[](2);
      initCalls[0] = addSetupEquippedExtension;
      initCalls[1] = addGetAllExtension;

      bytes memory initData = abi.encodeWithSelector(Multicall.multicall.selector, initCalls);

      token = tokenFactory.createERC721(
        payable(erc721Rails),
        caller,
        "Noun Citizens",
        "NPC",
        initData
      );
    }

    function test_TokenSetupSanityChecke() public {
      assertEq(ERC721Rails(token).name(), "Noun Citizens");
    }

    function test_GetEquippedTokenIdShouldBeEmpty() public {
      assertEq(IEquippableExtension(address(equippableExtension)).ext_getEquippedTokenIds(caller).length, 0);
    }

    function test_SetupEquipped() public {
      uint256[] memory tokenIds = new uint256[](2);
      tokenIds[0] = 1;
      tokenIds[1] = 2;
      IEquippableExtension(address(equippableExtension)).ext_setupEquipped(caller, tokenIds);
      assertEq(IEquippableExtension(address(equippableExtension)).ext_getEquippedTokenIds(caller).length, 2);
    }

    function test_ReplaceTokenIdsViaSetupEquipped() public {
      uint256[] memory tokenIds = new uint256[](2);
      tokenIds[0] = 1;
      tokenIds[1] = 2;
      IEquippableExtension(address(equippableExtension)).ext_setupEquipped(caller, tokenIds);
      assertEq(IEquippableExtension(address(equippableExtension)).ext_getEquippedTokenIds(caller).length, 2);
      assertEq(IEquippableExtension(address(equippableExtension)).ext_getEquippedTokenIds(caller)[0], 1);
      assertEq(IEquippableExtension(address(equippableExtension)).ext_getEquippedTokenIds(caller)[1], 2);

      uint256[] memory tokenIds2 = new uint256[](2);
      tokenIds2[0] = 3;
      tokenIds2[1] = 4;
      IEquippableExtension(address(equippableExtension)).ext_setupEquipped(caller, tokenIds2);
      assertEq(IEquippableExtension(address(equippableExtension)).ext_getEquippedTokenIds(caller).length, 2);
      assertEq(IEquippableExtension(address(equippableExtension)).ext_getEquippedTokenIds(caller)[0], 3);
      assertEq(IEquippableExtension(address(equippableExtension)).ext_getEquippedTokenIds(caller)[1], 4);
    }
}
